import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { User } from './users/user.entity';
import { Task } from './tasks/task.entity';
import { TaskLog } from './tasks/task-log.entity';
import { TaskUpdate } from './tasks/task-update.entity';
import { UsersModule } from './users/user.module';
import { TasksModule } from './tasks/tasks.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: Number(process.env.DB_PORT ?? 5432),
      username: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASS || 'postgres',
      database: process.env.DB_NAME || 'tasksdb',
      entities: [User, Task, TaskLog, TaskUpdate], // aquí registramos TODAS las entidades
      synchronize: false, // desactivamos la sincronización automática
    }),
    UsersModule,
    TasksModule,
  ],
})
export class AppModule {}
