import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  // ── Users ─────────────────────────────────────────────────────────────────

  async getAllUsers(params: { role?: string; limit?: number; offset?: number }) {
    const { role, limit = 20, offset = 0 } = params;
    return this.prisma.profile.findMany({
      where: role ? { role: role as any } : undefined,
      include: { farmerProfile: true },
      orderBy: { createdAt: 'desc' },
      take: limit,
      skip: offset,
    });
  }

  async updateUserRole(id: string, role: string) {
    return this.prisma.profile.update({
      where: { id },
      data: { role: role as any },
    });
  }

  // ── Products ──────────────────────────────────────────────────────────────

  async getAllProducts(params: { limit?: number; offset?: number }) {
    const { limit = 20, offset = 0 } = params;
    return this.prisma.product.findMany({
      include: {
        farmer: { select: { id: true, name: true } },
        categoryRef: true,
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
      skip: offset,
    });
  }

  async deleteProduct(id: string) {
    return this.prisma.product.delete({ where: { id } });
  }

  async toggleProductAvailability(id: string, isAvailable: boolean) {
    return this.prisma.product.update({
      where: { id },
      data: { isAvailable },
    });
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  async getAllOrders(params: { status?: string; limit?: number; offset?: number }) {
    const { status, limit = 20, offset = 0 } = params;
    return this.prisma.order.findMany({
      where: status ? { status: status as any } : undefined,
      include: {
        consumer: { select: { id: true, name: true } },
        trackingSteps: { orderBy: { stepOrder: 'asc' } },
      },
      orderBy: { createdAt: 'desc' },
      take: limit,
      skip: offset,
    });
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  async getAnalytics() {
    const [
      totalUsers,
      totalFarmers,
      totalConsumers,
      totalProducts,
      totalOrders,
      completedOrders,
      pendingOrders,
    ] = await Promise.all([
      this.prisma.profile.count(),
      this.prisma.profile.count({ where: { role: 'farmer' } }),
      this.prisma.profile.count({ where: { role: 'consumer' } }),
      this.prisma.product.count(),
      this.prisma.order.count(),
      this.prisma.order.count({ where: { status: 'completed' } }),
      this.prisma.order.count({ where: { status: 'pending' } }),
    ]);

    return {
      users: { total: totalUsers, farmers: totalFarmers, consumers: totalConsumers },
      products: { total: totalProducts },
      orders: { total: totalOrders, completed: completedOrders, pending: pendingOrders },
    };
  }
}
