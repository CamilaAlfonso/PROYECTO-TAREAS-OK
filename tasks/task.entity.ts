import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../users/user.entity';
import { TaskLog } from './task-log.entity';
import { TaskUpdate } from './task-update.entity';

@Entity('tasks')
export class Task {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string | null;

  @Column({ default: 'Pendiente' })
  status: string;

  @Column({ default: 'Media' })
  priority: string;

  // ← mapea a due_date (timestamp) de tu BD
  @Column({ name: 'due_date', type: 'timestamp', nullable: true })
  dueDate: Date | null;

  // ← FK real: userid (uuid)
  @ManyToOne(() => User, (user) => user.tasks, {
    nullable: false,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'userid' })
  user: User;

  @OneToMany(() => TaskLog, (log) => log.task, { cascade: false })
  logs: TaskLog[];

  @OneToMany(() => TaskUpdate, (upd) => upd.task, { cascade: false })
  updates: TaskUpdate[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
