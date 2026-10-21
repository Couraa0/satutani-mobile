import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Request,
  Res,
  StreamableFile,
  UseGuards,
} from '@nestjs/common';
import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { AiService } from './ai.service';
import { AuthGuard } from '../auth/auth.guard';
import { FarmerGuard } from '../auth/farmer.guard';
import type { Response } from 'express';

class ChatDto {
  @IsString()
  @IsNotEmpty()
  message: string;

  @IsString()
  @IsOptional()
  wilayah?: string;
}

@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  /**
   * POST /api/ai/chat
   * Eksklusif untuk petani (AuthGuard + FarmerGuard).
   * Meneruskan pesan ke Python AI microservice.
   */
  @Post('chat')
  @UseGuards(AuthGuard, FarmerGuard)
  @HttpCode(HttpStatus.OK)
  async chat(@Request() req, @Body() body: ChatDto) {
    return this.aiService.chat({
      message: body.message,
      wilayah: body.wilayah,
      farmerId: req.user.id,
    });
  }

  /**
   * GET /api/ai/wilayah
   * Publik — daftar wilayah yang didukung AI.
   */
  @Get('wilayah')
  async getWilayah() {
    return this.aiService.getWilayah();
  }

  /**
   * GET /api/ai/health
   * Status Python AI microservice.
   */
  @Get('health')
  async health() {
    return this.aiService.healthCheck();
  }

  /**
   * POST /api/ai/tts
   * Generate text-to-speech using ElevenLabs (Proxy)
   */
  @Post('tts')
  @HttpCode(HttpStatus.OK)
  async generateTts(
    @Body('text') text: string,
    @Res({ passthrough: true }) res: Response,
  ) {
    if (!text) {
      return { error: 'Text is required' };
    }
    
    const audioBuffer = await this.aiService.generateTts(text);
    
    res.set({
      'Content-Type': 'audio/mpeg',
      'Content-Length': audioBuffer.length,
    });
    
    return new StreamableFile(audioBuffer);
  }
}
