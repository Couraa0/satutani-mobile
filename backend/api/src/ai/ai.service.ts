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
}
