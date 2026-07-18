import { Module } from '@nestjs/common';
import { CommoditiesController } from './commodities.controller';
import { CommoditiesService } from './commodities.service';

@Module({
  controllers: [CommoditiesController],
  providers: [CommoditiesService],
  exports: [CommoditiesService],
})
export class CommoditiesModule {}
