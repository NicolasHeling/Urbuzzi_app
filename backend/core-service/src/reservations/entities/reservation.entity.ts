import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne } from 'typeorm';
import { Client } from '../../clients/entities/client.entity';
import { Lot } from '../../lots/lot.entity';

@Entity('reservations')
export class Reservation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'timestamp' })
  expiresAt: Date;

  @Column({ default: 'PENDING' }) // PENDING, APPROVED, CANCELLED, EXPIRED
  status: string;

  @ManyToOne(() => Client, (client) => client.reservations, { eager: true })
  client: Client;

  @ManyToOne(() => Lot, { eager: true })
  lot: Lot;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
