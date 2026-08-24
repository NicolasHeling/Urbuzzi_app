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
  registration: string; // Matrícula

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  frontMeasure: number; // Frente (m)

  @Column('decimal', { precision: 10, scale: 2, nullable: true })
  backMeasure: number; // Fundo (m)

  @Column({ nullable: true })
  svgCoordinates: string; // Para renderizar no mapa interativo

  @Column({ nullable: true })
  landName: string; // Nome do loteamento (ex: Biopark, Vista Verde)

  @OneToMany(() => Proposal, proposal => proposal.lot)
  proposals: Proposal[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
