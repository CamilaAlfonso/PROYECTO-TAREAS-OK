import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Task } from './task.entity';

@Entity('task_logs')
export class TaskLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // columna action (varchar)
  @Column({ type: 'varchar' })
  action: string;

  // columna details (text)
  @Column({ type: 'text', nullable: true })
  details: string | null;

  // columna timestamp (timestamp without time zone)
  @Column({ name: 'timestamp', type: 'timestamp' })
  timestamp: Date;

  // FK -> taskid (uuid)
  @ManyToOne(() => Task, (task) => task.logs, {
    onDelete: 'CASCADE',
    nullable: false,
  })
  @JoinColumn({ name: 'taskid' })
  task: Task;
}
