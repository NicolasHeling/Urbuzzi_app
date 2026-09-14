import { Entity, PrimaryGeneratedColumn, Column, Index, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('tasks')
@Index('IDX_tasks_date_time', ['date', 'time'])
@Index('IDX_tasks_clientId', ['clientId'])
@Index('IDX_tasks_status', ['status'])
export class Task {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ type: 'date' })
  date: string;

  @Column({ type: 'time' })
  time: string;

  @Column({ default: 'Pendente' })
  status: string;

  @Column()
  clientId: string;

  @Index('IDX_tasks_userId')
  @Column({ nullable: true })
  userId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
