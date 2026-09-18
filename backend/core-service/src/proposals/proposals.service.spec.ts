import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ProposalsService } from './proposals.service';
import { Proposal } from './proposal.entity';
import { ProposalHistory } from './proposal-history.entity';
import { Lot } from '../lots/lot.entity';
import { Reservation } from '../reservations/entities/reservation.entity';
import { Commission } from '../commissions/commission.entity';
import { AuditService } from '../audit/audit.service';
import { DataSource, EntityManager } from 'typeorm';

describe('ProposalsService', () => {
  let service: ProposalsService;
  let mockEntityManager: jest.Mocked<EntityManager>;

  const mockProposalRepository = {
    findOne: jest.fn(),
    find: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  const mockLotRepository = {
    findOne: jest.fn(),
    update: jest.fn(),
  };

  const mockReservationRepository = {
    count: jest.fn(),
  };

  const mockAuditService = {
    logAction: jest.fn(),
  };

  const mockDataSource = {
    transaction: jest.fn(),
  };

  beforeEach(async () => {
    mockEntityManager = {
      findOne: jest.fn(),
      find: jest.fn(),
      count: jest.fn(),
      create: jest.fn(),
      save: jest.fn(),
      update: jest.fn(),
    } as any;

    mockDataSource.transaction.mockImplementation(async (cb) => {
      return await cb(mockEntityManager);
    });

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProposalsService,
        { provide: getRepositoryToken(Proposal), useValue: mockProposalRepository },
        { provide: getRepositoryToken(ProposalHistory), useValue: {} },
        { provide: getRepositoryToken(Lot), useValue: mockLotRepository },
        { provide: getRepositoryToken(Reservation), useValue: mockReservationRepository },
        { provide: getRepositoryToken(Commission), useValue: {} },
        { provide: AuditService, useValue: mockAuditService },
        { provide: DataSource, useValue: mockDataSource },
      ],
    }).compile();

    service = module.get<ProposalsService>(ProposalsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Transição de Status de Proposta e Lote', () => {
    it('deve marcar o lote como "Vendido" e criar comissão com valores corretos ao mudar para "Concluída"', async () => {
      const mockProposal = {
        id: 'prop-1',
        lotId: 'lot-1',
        status: 'Nova',
        offeredPrice: 100000,
        responsibleUserName: 'broker-1',
      };
      
      const mockLot = { id: 'lot-1', status: 'Reservado' };
      
      mockEntityManager.findOne.mockResolvedValueOnce(mockProposal);
      mockEntityManager.findOne.mockResolvedValueOnce(mockLot);
      mockEntityManager.create.mockImplementation((entity, data) => data);
      
      await service.updateStatus('prop-1', 'Concluída', 'user-1');
      
      expect(mockEntityManager.update).toHaveBeenCalledWith(Lot, 'lot-1', { status: 'Vendido' });
      expect(mockEntityManager.create).toHaveBeenCalledWith(Commission, {
        brokerId: 'broker-1',
        proposalId: 'prop-1',
        saleValue: 100000,
        commissionValue: 5000,
        status: 'PENDING',
      });
      expect(mockAuditService.logAction).toHaveBeenCalled();
    });

    it('deve marcar o lote como "Disponível" ao mudar para "Rejeitada" quando não houver outras propostas/reservas ativas', async () => {
      const mockProposal = { id: 'prop-1', lotId: 'lot-1', status: 'Em Análise' };
      const mockLot = { id: 'lot-1', status: 'Reservado' };
      
      mockEntityManager.findOne.mockResolvedValueOnce(mockProposal);
      mockEntityManager.findOne.mockResolvedValueOnce(mockLot);
      mockEntityManager.count.mockResolvedValue(0); 
      
      await service.updateStatus('prop-1', 'Rejeitada', 'user-1');
      
      expect(mockEntityManager.update).toHaveBeenCalledWith(Lot, 'lot-1', { status: 'Disponível' });
      expect(mockAuditService.logAction).toHaveBeenCalled();
    });

    it('NÃO deve mudar o status do lote ao mudar para "Rejeitada" se houver outras propostas ativas', async () => {
      const mockProposal = { id: 'prop-1', lotId: 'lot-1', status: 'Em Análise' };
      const mockLot = { id: 'lot-1', status: 'Reservado' };
      
      mockEntityManager.findOne.mockResolvedValueOnce(mockProposal);
      mockEntityManager.findOne.mockResolvedValueOnce(mockLot);
      mockEntityManager.count.mockResolvedValue(1); 
      
      await service.updateStatus('prop-1', 'Rejeitada', 'user-1');
      
      expect(mockEntityManager.update).not.toHaveBeenCalledWith(Lot, 'lot-1', { status: 'Disponível' });
      expect(mockAuditService.logAction).toHaveBeenCalled();
    });

    it('deve definir o prazo de SLA para 7 dias a partir da criação', async () => {
      mockEntityManager.create.mockImplementation((entity, data) => data);
      mockEntityManager.save.mockImplementation((data: any) => Promise.resolve({ ...data, id: 'prop-1' }));
      
      const proposalData = { lotId: 'lot-1', offeredPrice: 100000 } as any;
      const result = await service.create(proposalData, 'user-1');
      
      const expectedSla = new Date();
      expectedSla.setDate(expectedSla.getDate() + 7);
      
      expect(result.slaDeadline).toBeDefined();
      expect(result.slaDeadline.getTime()).toBeCloseTo(expectedSla.getTime(), -4);
    });
  });
});
