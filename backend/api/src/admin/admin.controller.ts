import {
  Controller,
  Get,
  Patch,
  Delete,
  Param,
  Query,
  Body,
  UseGuards,
} from '@nestjs/common';
import { AdminService } from './admin.service';
import { AuthGuard } from '../auth/auth.guard';
import { AdminGuard } from '../auth/admin.guard';

@Controller('admin')
@UseGuards(AuthGuard, AdminGuard)
export class AdminController {
  constructor(private adminService: AdminService) {}

  // Analytics
  @Get('analytics')
  getAnalytics() {
    return this.adminService.getAnalytics();
  }

  // Users
  @Get('users')
  getAllUsers(
    @Query('role') role?: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.adminService.getAllUsers({
      role,
      limit: limit ? +limit : 20,
      offset: offset ? +offset : 0,
    });
  }

  @Patch('users/:id/role')
  updateUserRole(@Param('id') id: string, @Body('role') role: string) {
    return this.adminService.updateUserRole(id, role);
  }

  // Products
  @Get('products')
  getAllProducts(
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.adminService.getAllProducts({
      limit: limit ? +limit : 20,
      offset: offset ? +offset : 0,
    });
  }

  @Delete('products/:id')
  deleteProduct(@Param('id') id: string) {
    return this.adminService.deleteProduct(id);
  }

  @Patch('products/:id/availability')
  toggleAvailability(
    @Param('id') id: string,
    @Body('isAvailable') isAvailable: boolean,
  ) {
    return this.adminService.toggleProductAvailability(id, isAvailable);
  }

  // Orders
  @Get('orders')
  getAllOrders(
    @Query('status') status?: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.adminService.getAllOrders({
      status,
      limit: limit ? +limit : 20,
      offset: offset ? +offset : 0,
    });
  }
}
