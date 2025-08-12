import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Task } from './task.entity';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { User } from '../users/user.entity';

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(Task) private readonly taskRepo: Repository<Task>,
    @InjectRepository(User) private readonly userRepo: Repository<User>,
  ) {}

  async create(dto: CreateTaskDto): Promise<Task> {
    const user = await this.userRepo.findOne({ where: { id: dto.userId } });
    if (!user) throw new BadRequestException('Usuario no encontrado');

    let dueDate: Date | null = null;
    if (dto.startTime) {
      const [hh, mm] = dto.startTime.split(':').map((s) => parseInt(s, 10));
      const d = new Date();
      d.setSeconds(0, 0);
      d.setHours(hh, mm, 0, 0);
      dueDate = d;
    }

    const task = this.taskRepo.create({
      title: dto.title,
      description: dto.description ?? null,
      status: dto.status,
      priority: dto.priority,
      dueDate,
      user,
    });

    return this.taskRepo.save(task);
  }

  async findByUser(userId: string): Promise<Task[]> {
    if (!userId) throw new BadRequestException('userId requerido');
    return this.taskRepo.find({
      where: { user: { id: userId } },
      order: { createdAt: 'DESC' },
    });
  }

  async update(id: string, dto: UpdateTaskDto): Promise<Task> {
    const task = await this.taskRepo.findOne({ where: { id } });
    if (!task) throw new NotFoundException('Tarea no encontrada');

    // Mapear startTime → dueDate si viene
    if (dto.startTime != null) {
      if (dto.startTime === ('' as any)) {
        task.dueDate = null;
      } else {
        const [hh, mm] = dto.startTime.split(':').map((s) => parseInt(s, 10));
        const d = new Date(task.dueDate ?? new Date());
        d.setSeconds(0, 0);
        d.setHours(hh, mm, 0, 0);
        task.dueDate = d;
      }
    }

    if (dto.title !== undefined) task.title = dto.title;
    if (dto.description !== undefined) task.description = dto.description;
    if (dto.status !== undefined) task.status = dto.status;
    if (dto.priority !== undefined) task.priority = dto.priority;

    return this.taskRepo.save(task);
  }

  async remove(id: string): Promise<void> {
    await this.taskRepo.delete(id);
  }
}
