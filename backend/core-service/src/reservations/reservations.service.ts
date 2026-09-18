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
    return this.reservationRepository.manager.transaction(async (manager) => {
      const lot = await manager.findOne(Lot, { where: { id: createReservationDto.lotId } });
      if (!lot) throw new NotFoundException('Lot not found');

      if (lot.status !== 'Disponível') {
        throw new BadRequestException('Lot is not available for reservation');
      }

      await manager.update(Lot, lot.id, { status: 'Reservado' });

      const expiresAt = new Date();
      expiresAt.setHours(expiresAt.getHours() + 48);

      const reservation = manager.create(Reservation, {
        status: 'PENDING',
        expiresAt,
        client: { id: createReservationDto.clientId } as Client,
        lot,
      });

      return await manager.save(reservation);
    });
  }

  findAll(): Promise<Reservation[]> {
    return this.reservationRepository.find({ relations: ['client', 'lot'] });
  }

  async approve(id: string): Promise<Reservation> {
    return this.reservationRepository.manager.transaction(async (manager) => {
      const reservation = await manager.findOne(Reservation, { where: { id }, relations: ['lot'] });
      if (!reservation) throw new NotFoundException('Reservation not found');

      reservation.status = 'APPROVED';
      await manager.update(Lot, reservation.lot.id, { status: 'Reservado' });

      return await manager.save(reservation);
    });
  }

  async cancel(id: string): Promise<Reservation> {
    return this.reservationRepository.manager.transaction(async (manager) => {
      const reservation = await manager.findOne(Reservation, { where: { id }, relations: ['lot'] });
      if (!reservation) throw new NotFoundException('Reservation not found');

      reservation.status = 'CANCELLED';
      await manager.update(Lot, reservation.lot.id, { status: 'Disponível' });

      return await manager.save(reservation);
    });
  }

  // Verifica a cada hora se há reservas expiradas
  @Cron(CronExpression.EVERY_HOUR)
  async checkExpiredReservations() {
    this.logger.log('Checking for expired reservations...');
    const now = new Date();

    const expiredReservations = await this.reservationRepository
      .createQueryBuilder('reservation')
      .leftJoinAndSelect('reservation.lot', 'lot')
      .where('reservation.status = :status', { status: 'PENDING' })
      .andWhere('reservation.expiresAt <= :now', { now })
      .getMany();

    if (expiredReservations.length > 0) {
      // Processar todas as expiradas em uma única transação
      await this.reservationRepository.manager.transaction(async (manager) => {
        for (const res of expiredReservations) {
          res.status = 'EXPIRED';
          await manager.update(Lot, res.lot.id, { status: 'Disponível' });
          await manager.save(res);
          this.logger.log(`Reservation ${res.id} expired. Lot ${res.lot.id} is available again.`);
        }
      });
    }
  }
}
