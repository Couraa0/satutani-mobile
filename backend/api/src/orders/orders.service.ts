import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  async findByConsumer(consumerId: string) {
    return this.prisma.order.findMany({
      where: { consumerId },
      include: { trackingSteps: { orderBy: { stepOrder: 'asc' } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findByFarmer(farmerId: string) {
    return this.prisma.order.findMany({
      where: { farmerId },
      include: {
        consumer: { select: { id: true, name: true, phone: true } },
        trackingSteps: { orderBy: { stepOrder: 'asc' } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: { trackingSteps: { orderBy: { stepOrder: 'asc' } } },
    });
    if (!order) throw new NotFoundException('Pesanan tidak ditemukan');
    return order;
  }

  async create(consumerId: string, dto: any) {
    return this.prisma.order.create({
      data: {
        ...dto,
        consumerId,
        trackingSteps: {
          create: [
            { stepOrder: 1, title: 'Pesanan Dikonfirmasi', isActive: true },
            { stepOrder: 2, title: 'Dipanen & Disiapkan' },
            { stepOrder: 3, title: 'Dalam Pengiriman' },
            { stepOrder: 4, title: 'Diterima' },
          ],
        },
      },
      include: { trackingSteps: true },
    });
  }

  async updateStatus(id: string, farmerId: string, status: string) {
    const order = await this.prisma.order.findFirst({ where: { id, farmerId } });
    if (!order) throw new NotFoundException('Pesanan tidak ditemukan');

    return this.prisma.order.update({
      where: { id },
      data: { status: status as any },
    });
  }
}
