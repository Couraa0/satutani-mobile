import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
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
    return this.prisma.$transaction(async (tx) => {
      const product = await tx.product.findUnique({
        where: {
          id: dto.productId,
        },
        include: {
          farmer: true,
        },
      });

      if (!product) {
        throw new NotFoundException('Produk tidak ditemukan');
      }

      if (!product.isAvailable) {
        throw new BadRequestException('Produk sudah tidak tersedia');
      }

      const quantity = new Prisma.Decimal(dto.quantity);

      if (quantity.lte(0)) {
        throw new BadRequestException('Jumlah pembelian tidak valid');
      }

      if (product.stock.lt(quantity)) {
        throw new BadRequestException(
          `Stok tidak mencukupi. Sisa stok ${product.stock}`,
        );
      }

      const newStock = product.stock.minus(quantity);

      await tx.product.update({
        where: {
          id: product.id,
        },
        data: {
          stock: newStock,
          isAvailable: newStock.gt(0),
        },
      });

      const order = await tx.order.create({
        data: {
          consumerId,

          productId: product.id,

          productName: product.name,

          productImageUrl:
            product.imageUrls.length > 0 ? product.imageUrls[0] : '',

          farmerId: product.farmerId,

          farmerName: product.farmer.name,

          quantity,

          unit: product.unit,

          pricePerUnit: product.price,

          shippingCost: new Prisma.Decimal(dto.shippingCost ?? 0),

          deliveryMethod: dto.deliveryMethod,

          trackingSteps: {
            create: [
              {
                stepOrder: 1,
                title: 'Pesanan Dikonfirmasi',
                isActive: true,
              },
              {
                stepOrder: 2,
                title: 'Dipanen & Disiapkan',
              },
              {
                stepOrder: 3,
                title: 'Dalam Pengiriman',
              },
              {
                stepOrder: 4,
                title: 'Diterima',
              },
            ],
          },
        },

        include: {
          trackingSteps: true,
        },
      });

      return order;
    });
  }

  async updateStatus(id: string, farmerId: string, status: string) {
    const order = await this.prisma.order.findFirst({
      where: { id, farmerId },
    });
    if (!order) throw new NotFoundException('Pesanan tidak ditemukan');

    return this.prisma.order.update({
      where: { id },
      data: { status: status as any },
    });
  }
}
