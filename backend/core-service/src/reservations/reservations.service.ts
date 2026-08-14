import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Reservation } from './entities/reservation.entity';
import { Lot } from '../lots/lot.entity';
import { Client } from '../clients/entities/client.entity';

@Injectable()
export class ReservationsService {
  private readonly logger = new Logger(ReservationsService.name);

  constructor(
    @InjectRepository(Reservation)
    private readonly reservationRepository: Repository<Reservation>,
    @InjectRepository(Lot)
    private readonly lotRepository: Repository<Lot>,
  ) {}

  async create(createReservationDto: any): Promise<Reservation> {
    const lot = await this.lotRepository.findOne({ where: { id: createReservationDto.lotId } });
    if (!lot) throw new NotFoundException('Lot not found');

    if (lot.status !== 'Disponível') {
      throw new BadRequestException('Lot is not available for reservation');
    }

    // Marca lote como RESERVED
    lot.status = 'Reservado';
    await this.lotRepository.save(lot);

    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 48); // Reserva válida por 48h

    const reservation = this.reservationRepository.create({
      status: 'PENDING',
      expiresAt,
      client: { id: createReservationDto.clientId } as Client,
      lot,
    });

    return this.reservationRepository.save(reservation);
  }

  findAll(): Promise<Reservation[]> {
    return this.reservationRepository.find({ relations: ['client', 'lot'] });
  }

  async approve(id: string): Promise<Reservation> {
    const reservation = await this.reservationRepository.findOne({ where: { id }, relations: ['lot'] });
    if (!reservation) throw new NotFoundException('Reservation not found');

    reservation.status = 'APPROVED';
    
    // Atualiza status do lote
    reservation.lot.status = 'Vendido';
    await this.lotRepository.save(reservation.lot);

    return this.reservationRepository.save(reservation);
  }

  async cancel(id: string): Promise<Reservation> {
    const reservation = await this.reservationRepository.findOne({ where: { id }, relations: ['lot'] });
    if (!reservation) throw new NotFoundException('Reservation not found');

    reservation.status = 'CANCELLED';
    
    // Libera o lote
    reservation.lot.status = 'Disponível';
    await this.lotRepository.save(reservation.lot);

    return this.reservationRepository.save(reservation);
  }

  // Verifica a cada hora se há reservas expiradas
  @Cron(CronExpression.EVERY_HOUR)
  async checkExpiredReservations() {
    this.logger.log('Checking for expired reservations...');
    const now = new Date();
    
    // Buscar reservas pendentes com expiresAt menor que o tempo atual
    const expiredReservations = await this.reservationRepository
      .createQueryBuilder('reservation')
      .leftJoinAndSelect('reservation.lot', 'lot')
      .where('reservation.status = :status', { status: 'PENDING' })
      .andWhere('reservation.expiresAt <= :now', { now })
      .getMany();

    if (expiredReservations.length > 0) {
      for (const res of expiredReservations) {
        res.status = 'EXPIRED';
        res.lot.status = 'Disponível';
        
        await this.lotRepository.save(res.lot);
        await this.reservationRepository.save(res);
        this.logger.log(`Reservation ${res.id} expired. Lot ${res.lot.id} is available again.`);
      }
    }
  }
}
