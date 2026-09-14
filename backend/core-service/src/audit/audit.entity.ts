import { Entity, PrimaryGeneratedColumn, Column, Index, CreateDateColumn } from 'typeorm';

@Entity('audits')
@Index('IDX_audits_entityId', ['entityId'])
@Index('IDX_audits_action', ['action'])
@Index('IDX_audits_userId', ['userId'])
@Index('IDX_audits_createdAt', ['createdAt'])
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
