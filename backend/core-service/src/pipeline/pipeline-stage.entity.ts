import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('pipeline_stages')
export class PipelineStage {
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

  @Column({ default: true })
  isActive: boolean;

  @Column({ default: false })
  isFinal: boolean; // Marca a etapa como 'concluída' (ex: Vendido)

  @Column({ default: false })
  isCancellation: boolean; // Marca a etapa como 'cancelamento' (ex: Rejeitada)

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
