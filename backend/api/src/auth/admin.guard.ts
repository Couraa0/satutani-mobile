import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AdminGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const userId = request.user?.id;

    const profile = await this.prisma.profile.findUnique({
      where: { id: userId },
      select: { role: true },
    });

    if (profile?.role !== 'admin') {
      throw new ForbiddenException('Akses ditolak — hanya admin');
    }
    return true;
  }
}
