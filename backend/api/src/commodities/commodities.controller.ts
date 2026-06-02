import { Controller, Get, NotFoundException, Param, Query } from '@nestjs/common';
import { CommoditiesService } from './commodities.service';

@Controller('commodities')
export class CommoditiesController {
  constructor(private readonly commoditiesService: CommoditiesService) {}

  /**
   * GET /api/commodities
   * Daftar semua komoditas. Bisa difilter dengan ?kategori=hortikultura
   */
  @Get()
  findAll(@Query('kategori') kategori?: string) {
    const data = this.commoditiesService.findAll(kategori);
    return {
      data,
      total: data.length,
      kategori: kategori ?? 'semua',
    };
  }

  /**
   * GET /api/commodities/kategori
   * Daftar semua kategori komoditas yang tersedia.
   */
  @Get('kategori')
  findKategori() {
    return {
      data: this.commoditiesService.findKategori(),
    };
  }

  /**
   * GET /api/commodities/:slug
   * Detail satu komoditas berdasarkan slug (misal: cabai, jagung, stroberi).
   */
  @Get(':slug')
  findOne(@Param('slug') slug: string) {
    const item = this.commoditiesService.findBySlug(slug);
    if (!item) {
      throw new NotFoundException(`Komoditas '${slug}' tidak ditemukan.`);
    }
    return item;
  }
}
