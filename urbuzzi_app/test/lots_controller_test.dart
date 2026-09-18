import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbuzzi_app/features/lots/data/lots_repository.dart';
import 'package:urbuzzi_app/features/lots/domain/models/lot.dart';
import 'package:urbuzzi_app/features/lots/presentation/lots_provider.dart';
import 'package:urbuzzi_app/core/network/socket_service.dart';

import 'package:dio/dio.dart';

// Mock simples do LotsRepository sem dependência de geração de código
class FakeLotsRepository extends LotsRepository {
  List<Lot> _fakeLots = [];
  int fetchCallCount = 0;

  FakeLotsRepository() : super(Dio());

  void setFakeLots(List<Lot> lots) {
    _fakeLots = lots;
  }

  @override
  Future<LotsPage> fetchLots({
    String? landName,
    int limit = 50,
    int offset = 0,
    String? search,
    String? status,
  }) async {
    fetchCallCount++;
    var filtered = _fakeLots;
    if (status != null && status != 'Todos') {
      filtered = filtered.where((l) => l.status == status).toList();
    }
    if (search != null && search.isNotEmpty) {
      final term = search.toLowerCase();
      filtered = filtered.where((l) =>
        l.block.toLowerCase().contains(term) || l.number.toLowerCase().contains(term)
      ).toList();
    }
    final paged = filtered.skip(offset).take(limit).toList();
    return LotsPage(data: paged, total: filtered.length);
  }

  @override
  Future<void> updateLotStatus(String id, String newStatus, {String? justification}) async {
    // no-op em teste
  }

  @override
  Future<void> updateLotsStatusBulk(List<String> ids, String newStatus, {String? justification}) async {
    // no-op em teste
  }

  @override
  Future<List<Lot>> fetchMapPolygons({String? landName}) async {
    return _fakeLots.where((l) => l.mapPolygons != null && l.mapPolygons!.isNotEmpty).toList();
  }
}

Lot _makeLot(String id, String block, String number, String status, {double price = 100000, List<List<double>>? mapPolygons}) {
  return Lot(
    id: id,
    block: block,
    number: number,
    area: 300,
    price: price,
    status: status,
    mapPolygons: mapPolygons,
  );
}

class FakeSocketService extends SocketService {
  @override
  void initSocket({required Function(String lotId, String newStatus) onLotStatusUpdated}) {}
  
  @override
  void disconnect() {}
}

void main() {
  group('LotsController', () {
    late FakeLotsRepository fakeRepo;
    late FakeSocketService fakeSocket;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeLotsRepository();
      fakeSocket = FakeSocketService();
      fakeRepo.setFakeLots([
        _makeLot('1', 'A', '01', 'Disponível', price: 100000),
        _makeLot('2', 'A', '02', 'Reservado', price: 200000),
        _makeLot('3', 'B', '01', 'Vendido', price: 150000),
        _makeLot('4', 'B', '02', 'Disponível', price: 180000),
        _makeLot('5', 'C', '01', 'Em aprovação', price: 120000),
      ]);

      container = ProviderContainer(
        overrides: [
          lotsRepositoryProvider.overrideWithValue(fakeRepo),
          socketServiceProvider.overrideWithValue(fakeSocket),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('carrega lotes ao inicializar', () async {

      // Espera o fetchLots inicial completar
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(lotsControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.length, 5);
    });

    test('totalVendido calcula corretamente', () async {
      final controller = container.read(lotsControllerProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.totalVendido, 150000.0);
    });

    test('totalNegociacao soma Reservado + Em aprovação', () async {
      final controller = container.read(lotsControllerProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      // Reservado: 200000 + Em aprovação: 120000 = 320000
      expect(controller.totalNegociacao, 320000.0);
    });

    test('updateLotInState atualiza o status de um lote', () async {
      final controller = container.read(lotsControllerProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      controller.updateLotInState('1', 'Vendido');

      final state = container.read(lotsControllerProvider);
      final lot = state.value!.firstWhere((l) => l.id == '1');
      expect(lot.status, 'Vendido');
    });

    test('updateLotInState ignora lote inexistente sem erro', () async {
      final controller = container.read(lotsControllerProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      // Não deve lançar exceção
      controller.updateLotInState('inexistente', 'Vendido');

      final state = container.read(lotsControllerProvider);
      expect(state.value!.length, 5);
    });

    test('updateLotInState ignora se status é o mesmo', () async {
      final controller = container.read(lotsControllerProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      final stateBefore = container.read(lotsControllerProvider);
      controller.updateLotInState('1', 'Disponível'); // Mesmo status
      final stateAfter = container.read(lotsControllerProvider);

      // O estado não deve ter mudado (mesma referência)
      expect(identical(stateBefore, stateAfter), isTrue);
    });
  });

  group('mapPolygonsProvider', () {
    test('retorna lotes com mapPolygons do backend', () async {
      final fakeRepo = FakeLotsRepository();
      fakeRepo.setFakeLots([
        _makeLot('1', 'A', '01', 'Disponível', mapPolygons: [[70, 70], [107.5, 70], [107.5, 135], [70, 135]]),
        _makeLot('2', 'A', '02', 'Reservado'), // Sem polígonos
      ]);

      final container = ProviderContainer(
        overrides: [
          lotsRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      // Aguarda o provider resolver
      final result = await container.read(mapPolygonsProvider.future);
      expect(result.length, 1);
      expect(result.first.id, '1');

      container.dispose();
    });
  });
}
