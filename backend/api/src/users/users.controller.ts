import { Controller, Get, Patch, Body, Request, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { AuthGuard } from '../auth/auth.guard';

@Controller('users')
@UseGuards(AuthGuard)
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('me')
  getMe(@Request() req) {
    return this.usersService.getMe(req.user.id);
  }

  @Patch('me')
  updateMe(@Request() req, @Body() body: { name?: string; phone?: string; city?: string; province?: string }) {
    return this.usersService.updateMe(req.user.id, body);
  }
}
