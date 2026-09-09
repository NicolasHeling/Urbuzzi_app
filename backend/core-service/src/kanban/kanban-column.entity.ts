import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { Proposal } from '../proposals/proposal.entity';

@Entity('kanban_columns')
export class KanbanColumn {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ type: 'int', default: 0 })
  order: number;

  @Column({ default: '#C2650A' })
  color: string;

  @Column({ nullable: true })
  projectId: string;

  @Column({ default: false })
  isFinal: boolean;

  @Column({ default: false })
  isCancellation: boolean;

  @OneToMany(() => Proposal, proposal => proposal.kanbanColumn)
  proposals: Proposal[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
