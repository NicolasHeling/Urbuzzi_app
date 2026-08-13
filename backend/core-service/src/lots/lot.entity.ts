import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { Proposal } from '../proposals/proposal.entity';

@Entity('lots')
export class Lot {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  block: string;

  @Column()
  number: string;

  @Column('decimal', { precision: 10, scale: 2 })
  area: number;

  @Column('decimal', { precision: 12, scale: 2 })
  price: number;

  @Column({ default: 'Disponível' })
  status: string; // Disponível, Reservado, Vendido

  @Column({ nullable: true })
  svgCoordinates: string; // Para renderizar no mapa interativo

  @OneToMany(() => Proposal, proposal => proposal.lot)
  proposals: Proposal[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
