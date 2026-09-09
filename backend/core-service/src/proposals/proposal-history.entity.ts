import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Proposal } from './proposal.entity';

@Entity('proposal_history')
export class ProposalHistory {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Proposal, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'proposal_id' })
  proposal: Proposal;

  @Column({ name: 'proposal_id' })
  proposalId: string;

  @Column({ nullable: true })
  oldColumnId: string;

  @Column({ nullable: true })
  oldColumnName: string;

  @Column({ nullable: true })
  newColumnId: string;

  @Column({ nullable: true })
  newColumnName: string;

  @Column({ nullable: true })
  responsibleUserName: string;

  @CreateDateColumn()
  createdAt: Date;
}
