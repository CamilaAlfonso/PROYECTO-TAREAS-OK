// users/user.service.ts
import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';

import { User } from './user.entity';
import { CreateUserDto } from './dto/create-user.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  // Crear usuario
  async createUser(dto: CreateUserDto): Promise<User> {
    const name = String(dto.name ?? '').trim();
    const email = String(dto.email ?? '')
      .trim()
      .toLowerCase();
    const password = String(dto.password ?? '').trim();

    if (!name || !email || !password) {
      throw new BadRequestException('name, email y password son requeridos');
    }

    const existingUser = await this.userRepository.findOne({
      where: { email },
    });
    if (existingUser) {
      throw new ConflictException('El correo electrónico ya está registrado');
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = this.userRepository.create({
      name,
      email,
      password: hashedPassword,
    });

    // `save` devuelve el registro con el `id` generado
    const saved = await this.userRepository.save(user);
    return saved; // el controller filtrará los campos expuestos
  }

  // Validar credenciales (login)
  async validateUser(email: string, password: string): Promise<User | null> {
    const normalizedEmail = String(email ?? '')
      .trim()
      .toLowerCase();
    const plainPassword = String(password ?? '').trim();

    const user = await this.userRepository.findOne({
      where: { email: normalizedEmail },
    });
    if (!user) return null;

    const isPasswordValid = await bcrypt.compare(plainPassword, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Correo o contraseña incorrectos');
    }

    return user;
  }

  // Buscar por email (para GET /users?email=...)
  async findByEmail(email: string): Promise<User | null> {
    const e = String(email ?? '')
      .trim()
      .toLowerCase();
    if (!e) return null;
    return this.userRepository.findOne({ where: { email: e } });
  }

  // Buscar por id
  async findById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }
}
