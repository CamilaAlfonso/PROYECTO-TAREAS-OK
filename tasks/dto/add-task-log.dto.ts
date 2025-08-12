import { IsDateString, IsNumber, Min } from 'class-validator';

export class AddTaskLogDto {
  @IsDateString(
    {},
    { message: 'La fecha debe estar en formato ISO (YYYY-MM-DD)' },
  )
  date: string; // Esta es la fecha de trabajo

  @IsNumber()
  @Min(0.25, { message: 'Las horas deben ser mayores o iguales a 0.25' })
  hours: number; // Horas trabajadas
}
