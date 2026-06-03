import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  async findAll(params: { category?: string; search?: string; limit?: number; offset?: number }) {
    const { category, search, limit = 20, offset = 0 } = params;

    return this.prisma.product.findMany({
      where: {
        isAvailable: true,
        ...(category && { category }),
        ...(search && { name: { contains: search, mode: 'insensitive' } }),
      },
      include: {
        farmer: { select: { id: true, name: true, avatarUrl: true } },
        categoryRef: true,
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
      skip: offset,
    });
  }

  async findOne(id: string) {
    const product = await this.prisma.product.findUnique({
      where: { id },
      include: {
        farmer: {
          select: { id: true, name: true, avatarUrl: true },
          include: { farmerProfile: true },
        },
        categoryRef: true,
        reviews: {
          include: { consumer: { select: { id: true, name: true, avatarUrl: true } } },
          orderBy: { createdAt: 'desc' },
          take: 10,
        },
      },
    });

    if (!product) throw new NotFoundException('Produk tidak ditemukan');
    return product;
  }

  async findByFarmer(farmerId: string) {
    return this.prisma.product.findMany({
      where: { farmerId },
      include: { categoryRef: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(farmerId: string, dto: any) {
    return this.prisma.product.create({
      data: { ...dto, farmerId },
    });
  }

  async update(id: string, farmerId: string, dto: any) {
    const product = await this.prisma.product.findFirst({ where: { id, farmerId } });
    if (!product) throw new NotFoundException('Produk tidak ditemukan');

    return this.prisma.product.update({ where: { id }, data: dto });
  }

  async remove(id: string, farmerId: string) {
    const product = await this.prisma.product.findFirst({ where: { id, farmerId } });
    if (!product) throw new NotFoundException('Produk tidak ditemukan');

    return this.prisma.product.delete({ where: { id } });
  }
}
