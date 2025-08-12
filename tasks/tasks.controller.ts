import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  Get,
  Query,
  Patch,
  Param,
  Delete,
} from '@nestjs/common';
import { TasksService } from './tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { Task } from './task.entity';

@Controller('tasks')
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Body() dto: CreateTaskDto,
  ): Promise<Partial<Task> & { startTime: string | null; totalHours: number }> {
    const t = await this.tasksService.create(dto);

    let startTime: string | null = null;
    if (t.dueDate) {
      const hh = String(t.dueDate.getHours()).padStart(2, '0');
      const mm = String(t.dueDate.getMinutes()).padStart(2, '0');
      startTime = `${hh}:${mm}`;
    }

    return {
      id: t.id,
      title: t.title,
      description: t.description,
      status: t.status,
      priority: t.priority,
      startTime,
      totalHours: 0,
    };
  }

  // LISTAR por usuario
  @Get()
  async findByUser(
    @Query('userId') userId: string,
  ): Promise<Array<Partial<Task> & { startTime: string | null }>> {
    const list = await this.tasksService.findByUser(userId);
    return list.map((t) => {
      let startTime: string | null = null;
      if (t.dueDate) {
        const hh = String(t.dueDate.getHours()).padStart(2, '0');
        const mm = String(t.dueDate.getMinutes()).padStart(2, '0');
        startTime = `${hh}:${mm}`;
      }
      return {
        id: t.id,
        title: t.title,
        description: t.description,
        status: t.status,
        priority: t.priority,
        startTime,
      };
    });
  }

  // EDITAR
  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateTaskDto,
  ): Promise<Partial<Task> & { startTime: string | null }> {
    const t = await this.tasksService.update(id, dto);

    let startTime: string | null = null;
    if (t.dueDate) {
      const hh = String(t.dueDate.getHours()).padStart(2, '0');
      const mm = String(t.dueDate.getMinutes()).padStart(2, '0');
      startTime = `${hh}:${mm}`;
    }

    return {
      id: t.id,
      title: t.title,
      description: t.description,
      status: t.status,
      priority: t.priority,
      startTime,
    };
  }

  // ELIMINAR
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id') id: string): Promise<void> {
    await this.tasksService.remove(id);
  }
}
