import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import axios from 'axios';

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';

export interface ChatRequest {
  message: string;
  wilayah?: string;
  farmerId?: string;
}

export interface ChatResponse {
  reply: string;
  wilayah: string;
  tools_used?: string[];
}

@Injectable()
export class AiService {
  /**
   * Proxy pesan ke Python AI microservice.
   * Hanya bisa dipanggil setelah AuthGuard + FarmerGuard memverifikasi user.
   */
  async chat(req: ChatRequest): Promise<ChatResponse> {
    try {
      const response = await axios.post<ChatResponse>(
        `${AI_SERVICE_URL}/chat`,
        {
          message: req.message,
          wilayah: req.wilayah ?? 'Lembang',
          farmer_id: req.farmerId,
        },
        { timeout: 60_000 }, // 60 detik — LLM bisa lambat
      );
      return response.data;
    } catch (err: any) {
      if (err.code === 'ECONNREFUSED') {
        throw new HttpException(
          'Layanan AI sedang tidak aktif. Coba beberapa saat lagi.',
          HttpStatus.SERVICE_UNAVAILABLE,
        );
      }
      if (err.response?.status === 500) {
        throw new HttpException(
          'AI gagal memproses pertanyaan. Coba ulangi.',
          HttpStatus.BAD_GATEWAY,
        );
      }
      throw new HttpException(
        err.message ?? 'Terjadi kesalahan pada layanan AI.',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  /** Health check ke Python AI service */
  async healthCheck(): Promise<Record<string, unknown>> {
    try {
      const response = await axios.get(`${AI_SERVICE_URL}/health`, {
        timeout: 5_000,
      });
      return response.data;
    } catch {
      return { status: 'offline', service: 'satutani-ai' };
    }
  }

  /** Daftar wilayah yang didukung */
  async getWilayah(): Promise<Record<string, unknown>> {
    try {
      const response = await axios.get(`${AI_SERVICE_URL}/wilayah`, {
        timeout: 5_000,
      });
      return response.data;
    } catch {
      return {
        wilayah: ['Lembang', 'Bandung Kota', 'Bekasi', 'Tasikmalaya', 'Cianjur', 'Sukabumi'],
        total: 6,
        source: 'fallback',
      };
    }
  }

  /**
   * Generate TTS audio via ElevenLabs API
   */
  async generateTts(text: string): Promise<Buffer> {
    const apiKey = process.env.ELEVENLABS_API_KEY;
    const voiceId = process.env.ELEVENLABS_VOICE_ID || 'pFZP5JQG7iQjIQuC4Bku'; // default
    const modelId = process.env.ELEVENLABS_MODEL_ID || 'eleven_multilingual_v2';
    
    if (!apiKey) {
      throw new HttpException(
        'ElevenLabs API key is not configured.',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
    
    try {
      const response = await axios.post(
        `https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`,
        {
          text,
          model_id: modelId,
          voice_settings: {
            stability: 0.5,
            similarity_boost: 0.75,
          },
        },
        {
          headers: {
            'xi-api-key': apiKey,
            'Content-Type': 'application/json',
          },
          responseType: 'arraybuffer', // Important to get raw binary data
        },
      );
      
      return Buffer.from(response.data);
    } catch (err: any) {
      throw new HttpException(
        err.response?.data?.detail?.message || 'Failed to generate speech with ElevenLabs',
        HttpStatus.BAD_GATEWAY,
      );
    }
  }
}
