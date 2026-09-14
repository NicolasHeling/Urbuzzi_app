import { Entity, PrimaryGeneratedColumn, Column, Index, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Lot } from '../../lots/lot.entity';

@Entity('visit_schedules')
@Index('IDX_visits_date', ['date'])
export class VisitSchedule {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Index('IDX_visits_customerName')
  @Column()
  customerName: string;

  @Column({ type: 'timestamp' })
  date: Date;

  @Column({ nullable: true })
  responsibleUserName: string;

  @Index('IDX_visits_lotId')
  @ManyToOne(() => Lot, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'lot_id' })
  lot: Lot;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
