import { PartialType } from '@nestjs/mapped-types';
import { CreateTaskDto } from './create-task.dto';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateTaskDto extends PartialType(CreateTaskDto) {
  @IsOptional()
  @IsString()
  @MaxLength(200)
  title?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  description?: string;

  @IsOptional()
  @IsEnum([
    'Listo para empezar',
    'En curso',
    'Detenido',
    'Pendiente',
    'Terminado',
  ])
  status?: string;

  @IsOptional()
  @IsEnum(['Critica', 'Alta', 'Media', 'Baja', 'Maximo esfuerzo'])
  priority?: string;
}
