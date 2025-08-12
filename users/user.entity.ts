import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';
import { Task } from '../tasks/task.entity';

@Entity('users') // Nombre de la tabla
export class User {
  @PrimaryGeneratedColumn('uuid') // id único tipo UUID
  id: string;

  @Column()
  name: string;

  @Column({ unique: true }) // email no repetido
  email: string;

  @Column()
  password: string; // aquí guardaremos el hash, no la contraseña real

  @OneToMany(() => Task, (task) => task.user) // un usuario puede tener muchas tareas
  tasks: Task[];
}
