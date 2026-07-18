import { Injectable } from '@nestjs/common';

export interface Komoditas {
  commodity: string;
  nama_lokal: string;
  temp_min: number;
  temp_max: number;
  rain_min: number;
  rain_max: number;
  humidity_min: number;
  humidity_max: number;
  growing_days: number;
  yield_ton_per_ha: number;
  harga_base: number;
  kategori: string;
}

const KNOWLEDGE_BASE: Komoditas[] = [
  // ── Hortikultura ──────────────────────────────────────────────────────────
  { commodity:'cabai',          nama_lokal:'Cabai Merah',    temp_min:18,temp_max:27,rain_min:600, rain_max:1250,humidity_min:60,humidity_max:80,growing_days:120,yield_ton_per_ha:15,harga_base:35000, kategori:'hortikultura' },
  { commodity:'cabai_rawit',    nama_lokal:'Cabai Rawit',    temp_min:20,temp_max:30,rain_min:500, rain_max:1200,humidity_min:60,humidity_max:80,growing_days:110,yield_ton_per_ha:10,harga_base:40000, kategori:'hortikultura' },
  { commodity:'tomat',          nama_lokal:'Tomat',          temp_min:18,temp_max:25,rain_min:400, rain_max:800, humidity_min:60,humidity_max:80,growing_days:100,yield_ton_per_ha:20,harga_base:8000,  kategori:'hortikultura' },
  { commodity:'terong',         nama_lokal:'Terong Ungu',    temp_min:22,temp_max:30,rain_min:500, rain_max:1000,humidity_min:65,humidity_max:80,growing_days:90, yield_ton_per_ha:25,harga_base:6000,  kategori:'hortikultura' },
  { commodity:'timun',          nama_lokal:'Mentimun',       temp_min:21,temp_max:30,rain_min:200, rain_max:400, humidity_min:60,humidity_max:80,growing_days:45, yield_ton_per_ha:20,harga_base:4500,  kategori:'hortikultura' },
  { commodity:'buncis',         nama_lokal:'Buncis',         temp_min:16,temp_max:24,rain_min:300, rain_max:500, humidity_min:60,humidity_max:75,growing_days:60, yield_ton_per_ha:12,harga_base:7000,  kategori:'hortikultura' },
  { commodity:'kacang_panjang', nama_lokal:'Kacang Panjang', temp_min:24,temp_max:32,rain_min:500, rain_max:1000,humidity_min:60,humidity_max:80,growing_days:60, yield_ton_per_ha:10,harga_base:7000,  kategori:'hortikultura' },
  // ── Sayuran daun ──────────────────────────────────────────────────────────
  { commodity:'kangkung',       nama_lokal:'Kangkung',       temp_min:25,temp_max:30,rain_min:500, rain_max:900, humidity_min:75,humidity_max:85,growing_days:27, yield_ton_per_ha:8, harga_base:3000,  kategori:'sayuran_daun' },
  { commodity:'bayam',          nama_lokal:'Bayam',          temp_min:18,temp_max:25,rain_min:100, rain_max:200, humidity_min:60,humidity_max:75,growing_days:30, yield_ton_per_ha:6, harga_base:4000,  kategori:'sayuran_daun' },
  { commodity:'sawi',           nama_lokal:'Sawi Hijau',     temp_min:20,temp_max:28,rain_min:200, rain_max:400, humidity_min:60,humidity_max:80,growing_days:40, yield_ton_per_ha:10,harga_base:4000,  kategori:'sayuran_daun' },
  { commodity:'selada',         nama_lokal:'Selada',         temp_min:15,temp_max:20,rain_min:250, rain_max:500, humidity_min:60,humidity_max:80,growing_days:45, yield_ton_per_ha:15,harga_base:8000,  kategori:'sayuran_daun' },
  // ── Umbi ──────────────────────────────────────────────────────────────────
  { commodity:'wortel',         nama_lokal:'Wortel',         temp_min:15,temp_max:22,rain_min:200, rain_max:400, humidity_min:60,humidity_max:75,growing_days:100,yield_ton_per_ha:25,harga_base:6000,  kategori:'umbi' },
  { commodity:'kentang',        nama_lokal:'Kentang',        temp_min:15,temp_max:20,rain_min:500, rain_max:700, humidity_min:60,humidity_max:80,growing_days:100,yield_ton_per_ha:20,harga_base:10000, kategori:'umbi' },
  { commodity:'bawang_merah',   nama_lokal:'Bawang Merah',   temp_min:18,temp_max:25,rain_min:350, rain_max:550, humidity_min:50,humidity_max:70,growing_days:90, yield_ton_per_ha:10,harga_base:25000, kategori:'umbi' },
  // ── Pangan ────────────────────────────────────────────────────────────────
  { commodity:'jagung',         nama_lokal:'Jagung',         temp_min:21,temp_max:30,rain_min:500, rain_max:1200,humidity_min:50,humidity_max:80,growing_days:75, yield_ton_per_ha:12,harga_base:4000,  kategori:'pangan' },
  { commodity:'padi',           nama_lokal:'Padi Sawah',     temp_min:22,temp_max:30,rain_min:1200,rain_max:2000,humidity_min:70,humidity_max:90,growing_days:120,yield_ton_per_ha:6, harga_base:5000,  kategori:'pangan' },
  // ── Buah ──────────────────────────────────────────────────────────────────
  { commodity:'stroberi',       nama_lokal:'Stroberi',       temp_min:14,temp_max:24,rain_min:600, rain_max:1200,humidity_min:70,humidity_max:85,growing_days:90, yield_ton_per_ha:15,harga_base:45000, kategori:'buah' },
  { commodity:'semangka',       nama_lokal:'Semangka',       temp_min:22,temp_max:32,rain_min:300, rain_max:600, humidity_min:60,humidity_max:80,growing_days:80, yield_ton_per_ha:20,harga_base:5000,  kategori:'buah' },
  { commodity:'melon',          nama_lokal:'Melon',          temp_min:20,temp_max:30,rain_min:200, rain_max:400, humidity_min:60,humidity_max:80,growing_days:75, yield_ton_per_ha:18,harga_base:9000,  kategori:'buah' },
  { commodity:'pisang',         nama_lokal:'Pisang',         temp_min:25,temp_max:35,rain_min:1200,rain_max:2500,humidity_min:70,humidity_max:90,growing_days:300,yield_ton_per_ha:30,harga_base:3000,  kategori:'buah' },
];

@Injectable()
export class CommoditiesService {
  findAll(kategori?: string): Komoditas[] {
    if (kategori) {
      return KNOWLEDGE_BASE.filter((k) => k.kategori === kategori);
    }
    return KNOWLEDGE_BASE;
  }

  findBySlug(slug: string): Komoditas | undefined {
    return KNOWLEDGE_BASE.find((k) => k.commodity === slug);
  }

  findKategori(): string[] {
    return [...new Set(KNOWLEDGE_BASE.map((k) => k.kategori))];
  }

  getKnowledgeBase(): Komoditas[] {
    return KNOWLEDGE_BASE;
  }
}
