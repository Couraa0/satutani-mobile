import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { createClient } from '@supabase/supabase-js';

/**
 * FarmerGuard — memastikan user yang sudah login (AuthGuard) memiliki role 'farmer'.
 * Harus digunakan SETELAH AuthGuard.
 *
 * Cara kerja:
 * 1. AuthGuard menaruh user Supabase di req.user
 * 2. FarmerGuard membaca tabel profiles untuk mengecek kolom 'role'
 */
@Injectable()
export class FarmerGuard implements CanActivate {
  private supabase = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
  );

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user?.id) {
      throw new ForbiddenException('User tidak terautentikasi.');
    }

    const { data, error } = await this.supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single();

    if (error || !data) {
      throw new ForbiddenException('Profil pengguna tidak ditemukan.');
    }

    if (data.role !== 'farmer') {
      throw new ForbiddenException(
        'Fitur ini hanya tersedia untuk pengguna dengan peran Petani.',
      );
    }

    return true;
  }
}
