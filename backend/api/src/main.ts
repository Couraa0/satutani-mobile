import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix('api');
  app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
  app.enableCors({
    origin: '*',
  });

  await app.listen(process.env.PORT ?? 4000);
  console.log(`API berjalan di port ${process.env.PORT ?? 4000}`);
}
bootstrap();

#test