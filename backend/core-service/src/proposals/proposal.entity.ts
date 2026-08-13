import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Lot } from '../lots/lot.entity';

@Entity('proposals')
export class Proposal {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  customerName: string;

  @Column()
  customerDocument: string; // CPF ou CNPJ

  @Column({ default: 'Nova' })
  status: string; // Nova, Em Análise, Aprovada, Rejeitada, Concluída

  @Column('decimal', { precision: 12, scale: 2, nullable: true })
  offeredPrice: number;

  @ManyToOne(() => Lot, lot => lot.proposals)
  @JoinColumn({ name: 'lot_id' })
  lot: Lot;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
