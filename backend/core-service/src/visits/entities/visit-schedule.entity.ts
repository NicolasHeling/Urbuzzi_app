import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Lot } from '../../lots/lot.entity';

@Entity('visit_schedules')
export class VisitSchedule {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  customerName: string;

  @Column({ type: 'timestamp' })
  date: Date;

  @Column({ nullable: true })
  responsibleUserName: string;

  @ManyToOne(() => Lot, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'lot_id' })
  lot: Lot;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
