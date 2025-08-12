import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class AddTaskUpdateDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(2000)
  message: string; // El comentario o actualización de la tarea
}
