import { Controller, Get, Post, Patch, Delete, Param, Query, Body, Request, UseGuards } from '@nestjs/common';
import { ProductsService } from './products.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('products')
export class ProductsController {
  constructor(private productsService: ProductsService) {}

  @Get()
  findAll(
    @Query('category') category?: string,
    @Query('search') search?: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.productsService.findAll({
      category,
      search,
      limit: limit ? +limit : 20,
      offset: offset ? +offset : 0,
    });
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.productsService.findOne(id);
  }

  @Post()
  @UseGuards(AuthGuard)
  create(@Request() req, @Body() body: any) {
    return this.productsService.create(req.user.id, body);
  }

  @Patch(':id')
  @UseGuards(AuthGuard)
  update(@Param('id') id: string, @Request() req, @Body() body: any) {
    return this.productsService.update(id, req.user.id, body);
  }

  @Delete(':id')
  @UseGuards(AuthGuard)
  remove(@Param('id') id: string, @Request() req) {
    return this.productsService.remove(id, req.user.id);
  }
}
