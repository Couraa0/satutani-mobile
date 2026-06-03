import { Controller, Get, Post, Patch, Param, Body, Request, UseGuards } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('orders')
@UseGuards(AuthGuard)
export class OrdersController {
  constructor(private ordersService: OrdersService) {}

  @Get('my')
  getMyOrders(@Request() req) {
    return this.ordersService.findByConsumer(req.user.id);
  }

  @Get('farmer')
  getFarmerOrders(@Request() req) {
    return this.ordersService.findByFarmer(req.user.id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.ordersService.findOne(id);
  }

  @Post()
  create(@Request() req, @Body() body: any) {
    return this.ordersService.create(req.user.id, body);
  }

  @Patch(':id/status')
  updateStatus(@Param('id') id: string, @Request() req, @Body('status') status: string) {
    return this.ordersService.updateStatus(id, req.user.id, status);
  }
}
