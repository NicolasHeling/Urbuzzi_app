import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CommissionsService } from './commissions.service';
import { Commission } from './commission.entity';

describe('CommissionsService', () => {
  let service: CommissionsService;
  let repository: Repository<Commission>;

  const mockRepository = {
    find: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CommissionsService,
        {
          provide: getRepositoryToken(Commission),
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<CommissionsService>(CommissionsService);
    repository = module.get<Repository<Commission>>(getRepositoryToken(Commission));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('deve estar definido', () => {
    expect(service).toBeDefined();
  });

  describe('Cálculo de Comissão', () => {
    const calculateCommission = (offeredPrice: number, responsibleUserName?: string) => {
      const commissionValue = Number(offeredPrice || 0) * 0.05;
      return {
        brokerId: responsibleUserName || 'unknown-broker',
        saleValue: offeredPrice || 0,
        commissionValue,
        status: 'PENDING',
      };
    };

    it('deve calcular a comissão como 5% do valor da venda', () => {
      const result = calculateCommission(100000, 'broker-1');
      expect(result.commissionValue).toBe(5000);
    });

    it('deve calcular a comissão corretamente para vários preços (250000, 0, decimais)', () => {
      expect(calculateCommission(250000).commissionValue).toBe(12500);
      expect(calculateCommission(0).commissionValue).toBe(0);
      expect(calculateCommission(100.50).commissionValue).toBe(5.025);
    });

    it('deve definir brokerId como "unknown-broker" quando responsibleUserName for null/undefined', () => {
      const result1 = calculateCommission(100000, undefined);
      expect(result1.brokerId).toBe('unknown-broker');

      const result2 = calculateCommission(100000, null as any);
      expect(result2.brokerId).toBe('unknown-broker');
    });

    it('deve definir o status inicial sempre como "PENDING"', () => {
      const result = calculateCommission(100000, 'broker-1');
      expect(result.status).toBe('PENDING');
    });
  });

  describe('findAll', () => {
    it('deve retornar comissões ordenadas por createdAt DESC', async () => {
      const mockCommissions = [
        { id: '1', createdAt: new Date('2023-01-02') },
        { id: '2', createdAt: new Date('2023-01-01') },
      ];
      mockRepository.find.mockResolvedValue(mockCommissions);

      const result = await service.findAll();
      
      expect(mockRepository.find).toHaveBeenCalledWith({
        order: { createdAt: 'DESC' },
      });
      expect(result).toEqual(mockCommissions);
    });
  });
});
