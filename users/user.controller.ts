// users/user.controller.ts
import {
  Body,
  Controller,
  Post,
  Get,
  Param,
  HttpException,
  Query as QueryParam,
  HttpStatus,
  HttpCode,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { UsersService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';

@Controller('users')
export class UserController {
  constructor(private readonly usersService: UsersService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() body: { email: string; password: string }) {
    try {
      const email = String(body.email ?? '')
        .trim()
        .toLowerCase();
      const password = String(body.password ?? '').trim();

      if (!email || !password) {
        throw new HttpException(
          'Email y contraseña son requeridos',
          HttpStatus.BAD_REQUEST,
        );
      }

      const user = await this.usersService.validateUser(email, password);
      if (!user) {
        throw new HttpException(
          'Credenciales incorrectas',
          HttpStatus.UNAUTHORIZED,
        );
      }

      return { id: user.id, name: user.name, email: user.email };
    } catch (error: unknown) {
      if (error instanceof HttpException) throw error;
      throw new HttpException(
        'Error interno del servidor',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() dto: CreateUserDto) {
    const u = await this.usersService.createUser(dto);
    return { id: u.id, name: u.name, email: u.email };
  }

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  async register(@Body() dto: CreateUserDto) {
    return this.create(dto);
  }

  @Get()
  async findByEmail(@QueryParam('email') email?: string) {
    const e = String(email ?? '')
      .trim()
      .toLowerCase();
    if (!e) throw new BadRequestException('Parámetro email requerido');

    const u = await this.usersService.findByEmail(e);
    if (!u) throw new NotFoundException('Usuario no encontrado');

    return { id: u.id, name: u.name, email: u.email };
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const u = await this.usersService.findById(id);
    if (!u) throw new NotFoundException('Usuario no encontrado');
    return { id: u.id, name: u.name, email: u.email };
  }
}
