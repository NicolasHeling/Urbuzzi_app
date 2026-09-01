import { Test, TestingModule } from '@nestjs/testing';
import { ProposalsService } from './proposals.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Proposal } from './proposal.entity';
import { Lot } from '../lots/lot.entity';
import { Reservation } from '../reservations/entities/reservation.entity';
import { AuditService } from '../audit/audit.service';

describe('ProposalsService', () => {
  let service: ProposalsService;

  const mockProposalRepository = {
    update: jest.fn(),
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  const mockLotRepository = {
    update: jest.fn(),
  };

  const mockReservationRepository = {
    findOne: jest.fn(),
  };

  const mockAuditService = {
    logAction: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProposalsService,
        {
          provide: getRepositoryToken(Proposal),
          useValue: mockProposalRepository,
        },
        {
          provide: getRepositoryToken(Lot),
          useValue: mockLotRepository,
        },
        {
          provide: getRepositoryToken(Reservation),
          useValue: mockReservationRepository,
        },
        {
          provide: AuditService,
          useValue: mockAuditService,
        },
      ],
    }).compile();

    service = module.get<ProposalsService>(ProposalsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('updateStatus', () => {
    it('should set lot status to "Vendido" when proposal is "Concluída"', async () => {
      const mockLot = { id: 'lot-1', status: 'Reservado' };
      const mockProposal = { id: 'prop-1', status: 'Aprovada', lot: mockLot };

      mockProposalRepository.update.mockResolvedValue(true);
      mockProposalRepository.findOne.mockResolvedValue(mockProposal);
      mockLotRepository.update.mockResolvedValue(true);

      const result = await service.updateStatus('prop-1', 'Concluída', 'user-1');

      expect(mockProposalRepository.update).toHaveBeenCalledWith('prop-1', { status: 'Concluída' });
      expect(mockLotRepository.update).toHaveBeenCalledWith('lot-1', { status: 'Vendido' });
      expect(mockAuditService.logAction).toHaveBeenCalledWith(
        'LOT_SOLD',
        'Lot',
        'lot-1',
        'user-1',
        { proposalId: 'prop-1', trigger: 'PROPOSAL_CONCLUDED' }
      );
      expect(result).toEqual(mockProposal);
    });

    it('should set lot status to "Disponível" when proposal is "Rejeitada" and no other active negotiation exists', async () => {
      const mockLot = { id: 'lot-1', status: 'Reservado' };
      const mockProposal = { id: 'prop-2', status: 'Em Análise', lot: mockLot };

      mockProposalRepository.update.mockResolvedValue(true);
      
      // first findOne is to return the updated proposal
      mockProposalRepository.findOne
        .mockResolvedValueOnce(mockProposal) // updatedProposal
        .mockResolvedValueOnce(null);        // otherActiveProposal

      mockReservationRepository.findOne.mockResolvedValue(null); // activeReservation

      await service.updateStatus('prop-2', 'Rejeitada', 'user-1');

      expect(mockLotRepository.update).toHaveBeenCalledWith('lot-1', { status: 'Disponível' });
    });
  });
});
