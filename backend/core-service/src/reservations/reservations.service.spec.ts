import { Test, TestingModule } from '@nestjs/testing';
import { ReservationsService } from './reservations.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Reservation } from './entities/reservation.entity';
import { Lot } from '../lots/lot.entity';
import { NotFoundException } from '@nestjs/common';

describe('ReservationsService', () => {
  let service: ReservationsService;
  
  const mockReservationRepository = {
    findOne: jest.fn(),
    save: jest.fn(),
    create: jest.fn(),
  };

  const mockLotRepository = {
    save: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReservationsService,
        {
          provide: getRepositoryToken(Reservation),
          useValue: mockReservationRepository,
        },
        {
          provide: getRepositoryToken(Lot),
          useValue: mockLotRepository,
        },
      ],
    }).compile();

    service = module.get<ReservationsService>(ReservationsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('approve', () => {
    it('should set lot status to "Reservado" when a reservation is approved', async () => {
      const mockLot = { id: 'lot-1', status: 'Disponível' };
      const mockReservation = { id: 'res-1', status: 'PENDING', lot: mockLot };

      mockReservationRepository.findOne.mockResolvedValue(mockReservation);
      mockLotRepository.save.mockResolvedValue(true);
      mockReservationRepository.save.mockImplementation(async (res) => res);

      const result = await service.approve('res-1');

      expect(mockReservationRepository.findOne).toHaveBeenCalledWith({
        where: { id: 'res-1' },
        relations: ['lot'],
      });
      
      expect(mockLot.status).toBe('Reservado');
      expect(mockLotRepository.save).toHaveBeenCalledWith(mockLot);
      expect(result.status).toBe('APPROVED');
    });

    it('should throw NotFoundException if reservation is not found', async () => {
      mockReservationRepository.findOne.mockResolvedValue(null);

      await expect(service.approve('invalid')).rejects.toThrow(NotFoundException);
    });
  });
});
