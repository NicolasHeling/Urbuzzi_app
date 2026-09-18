import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { LotsService } from './lots.service';
import { Lot } from './lot.entity';
import { AuditService } from '../audit/audit.service';
import { EventsGateway } from './events.gateway';
import { StorageService } from '../storage/storage.service';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { DataSource, EntityManager } from 'typeorm';

describe('LotsService', () => {
  let service: LotsService;
  let mockEntityManager: jest.Mocked<EntityManager>;

  const mockLotRepository = {
    find: jest.fn(),
    findOne: jest.fn(),
  };

  const mockAuditService = {
    logAction: jest.fn(),
  };

  const mockEventsGateway = {
    server: {
      emit: jest.fn(),
    },
    emitLotUpdate: jest.fn(),
  };

  const mockStorageService = {
    uploadFile: jest.fn(),
  };

  const mockCacheManager = {
    clear: jest.fn().mockResolvedValue(undefined),
  };

  const mockDataSource = {
    transaction: jest.fn(),
  };

  beforeEach(async () => {
    mockEntityManager = {
      findOne: jest.fn(),
      update: jest.fn(),
      save: jest.fn(),
    } as any;

    mockDataSource.transaction.mockImplementation(async (cb) => {
      return await cb(mockEntityManager);
    });

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        LotsService,
        { provide: getRepositoryToken(Lot), useValue: mockLotRepository },
        { provide: AuditService, useValue: mockAuditService },
        { provide: EventsGateway, useValue: mockEventsGateway },
        { provide: StorageService, useValue: mockStorageService },
        { provide: CACHE_MANAGER, useValue: mockCacheManager },
        { provide: DataSource, useValue: mockDataSource },
      ],
    }).compile();

    service = module.get<LotsService>(LotsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Atualização de Status', () => {
    it('deve mudar o status do lote corretamente em uma transação', async () => {
      const mockLot = { id: 'lot-1', status: 'Disponível' };
      mockEntityManager.findOne.mockResolvedValue(mockLot);
      
      await service.updateStatus('lot-1', 'Reservado', 'user-1');
      
      expect(mockEntityManager.update).toHaveBeenCalledWith(Lot, 'lot-1', { status: 'Reservado' });
    });

    it('deve criar log de auditoria com status antigo e novo', async () => {
      const mockLot = { id: 'lot-1', status: 'Disponível' };
      mockEntityManager.findOne.mockResolvedValue(mockLot);
      
      await service.updateStatus('lot-1', 'Reservado', 'user-1');
      
      expect(mockAuditService.logAction).toHaveBeenCalledWith(
        expect.objectContaining({
          entityId: 'lot-1',
          action: 'STATUS_UPDATE',
          oldValue: 'Disponível',
          newValue: 'Reservado'
        })
      );
    });

    it('deve enviar notificação WebSocket após atualizar status', async () => {
      const mockLot = { id: 'lot-1', status: 'Disponível' };
      mockEntityManager.findOne.mockResolvedValue(mockLot);
      
      await service.updateStatus('lot-1', 'Reservado', 'user-1');
      
      expect(mockEventsGateway.emitLotUpdate).toHaveBeenCalledWith('lot-1', 'Reservado');
    });

    it('deve resetar o cache ao atualizar status', async () => {
      const mockLot = { id: 'lot-1', status: 'Disponível' };
      mockEntityManager.findOne.mockResolvedValue(mockLot);
      
      await service.updateStatus('lot-1', 'Reservado', 'user-1');
      
      expect(mockCacheManager.clear).toHaveBeenCalled();
    });
  });

  describe('Atualização em Lote (Bulk Status)', () => {
    it('deve lidar graciosamente com array vazio sem lançar erros', async () => {
      await expect(service.updateBulkStatus([], 'Reservado', 'user-1')).resolves.not.toThrow();
      expect(mockDataSource.transaction).not.toHaveBeenCalled();
    });

    it('deve atualizar todos os lotes especificados', async () => {
      const mockLots = [{ id: 'lot-1' }, { id: 'lot-2' }];
      await service.updateBulkStatus(['lot-1', 'lot-2'], 'Vendido', 'user-1');
      
      expect(mockEntityManager.update).toHaveBeenCalledWith(Lot, 'lot-1', { status: 'Vendido' });
      expect(mockEntityManager.update).toHaveBeenCalledWith(Lot, 'lot-2', { status: 'Vendido' });
    });
  });

  describe('Consultas', () => {
    it('findMapPolygons deve retornar apenas lotes com mapPolygons', async () => {
      await service.findMapPolygons();
      expect(mockLotRepository.find).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({ mapPolygons: expect.anything() })
        })
      );
    });

    it('findMapPolygons deve filtrar por landName corretamente', async () => {
      await service.findMapPolygons('Empreendimento A');
      expect(mockLotRepository.find).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({ landName: 'Empreendimento A' })
        })
      );
    });

    it('findPublic deve retornar apenas lotes com status "Disponível"', async () => {
      await service.findPublic();
      expect(mockLotRepository.find).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { status: 'Disponível' }
        })
      );
    });
  });
});
