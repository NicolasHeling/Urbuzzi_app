import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('audits')
export class Audit {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  action: string;

  @Column()
  entityName: string;

  @Column()
  entityId: string;

  @Column({ nullable: true })
  userId: string;

  @Column('jsonb', { nullable: true })
  details: any;

  @CreateDateColumn()
  createdAt: Date;
}
