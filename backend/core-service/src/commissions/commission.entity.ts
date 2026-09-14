import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('commissions')
export class Commission {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  brokerId: string;

  @Column('uuid')
  proposalId: string;

  @Column('decimal', { precision: 12, scale: 2 })
  saleValue: number;

  @Column('decimal', { precision: 12, scale: 2 })
  commissionValue: number;

  @Column({ default: 'PENDING' })
  status: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
