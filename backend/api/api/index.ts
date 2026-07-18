import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from '../src/app.module';
import { ExpressAdapter } from '@nestjs/platform-express';
import express from 'express';

const server = express();

let cachedApp: any = null;

async function bootstrap() {
  if (!cachedApp) {
    try {
      console.log('Bootstrapping NestJS application on Vercel...');
      if (!process.env.DATABASE_URL) {
        console.error('DATABASE_URL environment variable is missing!');
      }
      
      const app = await NestFactory.create(AppModule, new ExpressAdapter(server));
      app.setGlobalPrefix('api');
      app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
      app.enableCors({
        origin: '*',
      });
      await app.init();
      cachedApp = app;
      console.log('NestJS application bootstrapped successfully.');
    } catch (error) {
      console.error('Failed to bootstrap NestJS application:', error);
      throw error;
    }
  }
  return server;
}

export default async function handler(req: any, res: any) {
  await bootstrap();
  server(req, res);
}
