import 'package:flutter_test/flutter_test.dart';
import 'package:urbuzzi_app/features/home/presentation/map_data.dart';
import 'package:urbuzzi_app/features/lots/domain/models/lot.dart';

void main() {
  group('LotPolygon', () {
    test('construção estática com pontos', () {
      const poly = LotPolygon(
        block: '01',
        number: '01',
        points: [Offset(0, 0), Offset(10, 0), Offset(10, 10), Offset(0, 10)],
      );

      expect(poly.block, '01');
      expect(poly.number, '01');
      expect(poly.points.length, 4);
    });

    test('LotPolygon.fromLot cria polígono a partir de dados do backend', () {
      final lot = Lot(
        id: 'lot-1',
        block: 'A',
        number: '01',
        area: 300,
        price: 100000,
        status: 'Disponível',
        mapPolygons: [[70.0, 70.0], [107.5, 70.0], [107.5, 135.0], [70.0, 135.0]],
      );

      final poly = LotPolygon.fromLot(lot);

      expect(poly.block, 'A');
      expect(poly.number, '01');
      expect(poly.points.length, 4);
      expect(poly.points[0], const Offset(70.0, 70.0));
      expect(poly.points[1], const Offset(107.5, 70.0));
    });

    test('LotPolygon.fromLot lida com mapPolygons nulo', () {
      final lot = Lot(
        id: 'lot-2',
        block: 'B',
        number: '05',
        area: 250,
        price: 80000,
        status: 'Reservado',
      );

      final poly = LotPolygon.fromLot(lot);
      expect(poly.points, isEmpty);
    });
  });

  group('buildMapPolygons', () {
    test('retorna polígonos do backend quando disponíveis', () {
      final lots = [
        Lot(
          id: '1', block: 'A', number: '1', area: 100, price: 50000,
          status: 'Disponível',
          mapPolygons: [[0, 0], [10, 0], [10, 10], [0, 10]],
        ),
        Lot(
          id: '2', block: 'A', number: '2', area: 100, price: 50000,
          status: 'Disponível',
          mapPolygons: [[10, 0], [20, 0], [20, 10], [10, 10]],
        ),
      ];

      final polygons = buildMapPolygons(lots);
      expect(polygons.length, 2);
      expect(polygons[0].block, 'A');
      expect(polygons[0].number, '1');
    });

    test('faz fallback para MapData.lots quando backend está vazio', () {
      final polygons = buildMapPolygons([]);
      expect(polygons.length, MapData.lots.length);
      expect(polygons, same(MapData.lots));
    });

    test('faz fallback quando todos os lotes têm mapPolygons nulo', () {
      final lots = [
        Lot(id: '1', block: 'A', number: '1', area: 100, price: 50000, status: 'Disponível'),
        Lot(id: '2', block: 'A', number: '2', area: 100, price: 50000, status: 'Disponível'),
      ];

      final polygons = buildMapPolygons(lots);
      expect(polygons.length, MapData.lots.length);
    });

    test('ignora lotes sem polígonos na lista do backend', () {
      final lots = [
        Lot(
          id: '1', block: 'A', number: '1', area: 100, price: 50000,
          status: 'Disponível',
          mapPolygons: [[0, 0], [10, 0], [10, 10], [0, 10]],
        ),
        Lot(id: '2', block: 'A', number: '2', area: 100, price: 50000, status: 'Disponível'),
      ];

      final polygons = buildMapPolygons(lots);
      expect(polygons.length, 1); // Apenas o primeiro tem polígonos
    });
  });

  group('computeBlockCenters', () {
    test('calcula centros de quadras a partir de polígonos', () {
      final polygons = [
        const LotPolygon(
          block: '01', number: '01',
          points: [Offset(0, 0), Offset(100, 0), Offset(100, 100), Offset(0, 100)],
        ),
        const LotPolygon(
          block: '01', number: '02',
          points: [Offset(100, 0), Offset(200, 0), Offset(200, 100), Offset(100, 100)],
        ),
      ];

      final centers = computeBlockCenters(polygons);
      expect(centers.containsKey('01'), isTrue);
      // Centro X: (0 + 200) / 2 = 100
      // Centro Y: min(0) - 14 = -14
      expect(centers['01']!.dx, 100.0);
      expect(centers['01']!.dy, -14.0);
    });

    test('agrupa múltiplas quadras corretamente', () {
      final polygons = [
        const LotPolygon(
          block: '01', number: '01',
          points: [Offset(0, 0), Offset(50, 0), Offset(50, 50), Offset(0, 50)],
        ),
        const LotPolygon(
          block: '02', number: '01',
          points: [Offset(100, 100), Offset(200, 100), Offset(200, 200), Offset(100, 200)],
        ),
      ];

      final centers = computeBlockCenters(polygons);
      expect(centers.length, 2);
      expect(centers.containsKey('01'), isTrue);
      expect(centers.containsKey('02'), isTrue);
    });

    test('retorna mapa vazio para lista vazia', () {
      final centers = computeBlockCenters([]);
      expect(centers, isEmpty);
    });
  });

  group('MapData (fallback estático)', () {
    test('possui 192 polígonos definidos', () {
      expect(MapData.lots.length, 192);
    });

    test('possui 15 quadras (01 a 15)', () {
      final blocks = MapData.lots.map((p) => p.block).toSet();
      expect(blocks.length, 15);
    });

    test('blockCenters é calculado para todas as quadras', () {
      expect(MapData.blockCenters.length, 15);
      for (int i = 1; i <= 15; i++) {
        final key = i.toString().padLeft(2, '0');
        expect(MapData.blockCenters.containsKey(key), isTrue,
            reason: 'Deve ter centro para quadra $key');
      }
    });
  });
}
