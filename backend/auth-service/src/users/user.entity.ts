import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

/**
 * Papéis disponíveis:
 *   administrador — acesso total, incluindo aprovar/rejeitar e gerenciar usuários
 *   gestor        — pode aprovar/rejeitar propostas e criar/editar lotes
 *   comercial     — pode criar propostas e mover para "Em Análise"
 *   consulta      — somente leitura (default para novos cadastros)
 */
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ unique: true })
  email: string;

  @Column()
  passwordHash: string; // Senha salva com bcrypt

  @Column({ default: 'consulta' })
  role: string; // administrador | gestor | comercial | consulta

  @Column({ nullable: true })
  hashedRefreshToken: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
