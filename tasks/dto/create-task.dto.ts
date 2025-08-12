import {
  IsNotEmpty,
  IsIn,
  IsOptional,
  IsUUID,
  IsInt,
  Min,
  Matches,
  MaxLength,
} from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateTaskDto {
  @IsNotEmpty()
  @Transform(({ value }) => String(value).trim())
  title: string;

  @IsOptional()
  @Transform(({ value }) => (value == null ? null : String(value).trim()))
  @MaxLength(2000)
  description: string | null;

  @IsIn([
    'Pendiente',
    'En curso',
    'Listo para empezar',
    'Terminado',
    'Detenido',
  ])
  status: string;

  @IsIn(['Alta', 'Media', 'Baja', 'Critica', 'Maximo esfuerzo'])
  priority: string;

  // viene del front como HH:mm
  @IsOptional()
  @Transform(({ value }) => (value == null ? null : String(value).trim()))
  @Matches(/^[0-2]\d:[0-5]\d$/, { message: 'startTime debe ser HH:mm' })
  startTime: string | null;

  // el front lo manda; lo aceptamos para no romper whitelist
  @IsOptional()
  @IsInt()
  @Min(0)
  totalHours?: number;

  @IsUUID()
  @Transform(({ value }) => String(value).trim())
  userId: string;
}
