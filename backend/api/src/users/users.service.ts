import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async getMe(userId: string) {
    const profile = await this.prisma.profile.findUnique({
      where: { id: userId },
      include: { farmerProfile: true },
    });

    if (!profile) throw new NotFoundException('Profil tidak ditemukan');
    return profile;
  }

  async updateMe(userId: string, dto: { name?: string; phone?: string; city?: string; province?: string }) {
    return this.prisma.profile.update({
      where: { id: userId },
      data: dto,
    });
  }
}
