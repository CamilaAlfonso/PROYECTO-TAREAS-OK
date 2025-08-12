import {
  IsEmail,
  IsNotEmpty,
  MinLength,
  Matches,
  IsString,
} from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateUserDto {
  @IsNotEmpty({ message: 'El nombre es obligatorio' })
  @IsString()
  @Transform(({ value }) => String(value).trim())
  name: string;

  @IsEmail({}, { message: 'El correo no es válido' })
  @Transform(({ value }) => String(value).trim().toLowerCase())
  email: string;

  @MinLength(6, { message: 'La contraseña debe tener mínimo 6 caracteres' })
  @Matches(/(?=.*[A-Z])/, { message: 'Debe contener al menos una mayúscula' })
  @Transform(({ value }) => String(value).trim())
  password: string;
}
