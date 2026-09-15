import 'package:flutter_test/flutter_test.dart';
import 'package:urbuzzi_app/features/lots/domain/models/lot.dart';

void main() {
  group('Lot model', () {
    test('fromJson desserializa todos os campos corretamente', () {
      final json = {
        'id': 'abc-123',
        'block': 'A',
        'number': '12',
        'area': '300.50',
        'price': '150000.00',
        'status': 'Disponível',
        'svgCoordinates': '<svg/>',
        'landName': 'Loteamento Biopark',
        'registration': 'MAT-001',
        'frontMeasure': '12.5',
        'backMeasure': '15.0',
        'whatsappNumber': '5545999990000',
        'documents': ['doc1.pdf', 'doc2.pdf'],
        'mapPolygons': [[70.0, 70.0], [107.5, 70.0], [107.5, 135.0], [70.0, 135.0]],
      };

      final lot = Lot.fromJson(json);

      expect(lot.id, 'abc-123');
      expect(lot.block, 'A');
      expect(lot.number, '12');
      expect(lot.area, 300.50);
      expect(lot.price, 150000.00);
      expect(lot.status, 'Disponível');
      expect(lot.svgCoordinates, '<svg/>');
      expect(lot.landName, 'Loteamento Biopark');
      expect(lot.registration, 'MAT-001');
      expect(lot.frontMeasure, 12.5);
      expect(lot.backMeasure, 15.0);
      expect(lot.whatsappNumber, '5545999990000');
      expect(lot.documents, ['doc1.pdf', 'doc2.pdf']);
      expect(lot.mapPolygons, isNotNull);
      expect(lot.mapPolygons!.length, 4);
      expect(lot.mapPolygons![0], [70.0, 70.0]);
    });

    test('fromJson aceita area e price como números', () {
      final json = {
        'id': 'id1',
        'block': 'B',
        'number': '3',
        'area': 250,
        'price': 100000,
        'status': 'Reservado',
      };

      final lot = Lot.fromJson(json);
      expect(lot.area, 250.0);
      expect(lot.price, 100000.0);
    });

    test('fromJson lida com campos nulos graciosamente', () {
      final json = {
        'id': 'id2',
        'block': 'C',
        'number': '5',
        'area': '0',
        'price': '0',
        'status': 'Vendido',
      };

      final lot = Lot.fromJson(json);
      expect(lot.landName, isNull);
      expect(lot.registration, isNull);
      expect(lot.frontMeasure, isNull);
      expect(lot.backMeasure, isNull);
      expect(lot.clientName, isNull);
      expect(lot.documents, isNull);
      expect(lot.mapPolygons, isNull);
    });

    test('fromJson aceita nomes alternativos de campos (land_name, loteamento)', () {
      expect(Lot.fromJson({
        'id': 'id3', 'block': 'D', 'number': '1',
        'area': '100', 'price': '50000', 'status': 'Disponível',
        'land_name': 'Via Alt',
      }).landName, 'Via Alt');

      expect(Lot.fromJson({
        'id': 'id4', 'block': 'E', 'number': '2',
        'area': '100', 'price': '50000', 'status': 'Disponível',
        'loteamento': 'Via Loteamento',
      }).landName, 'Via Loteamento');
    });

    test('toJson serializa todos os campos', () {
      final lot = Lot(
        id: 'x', block: 'A', number: '1',
        area: 100, price: 50000, status: 'Disponível',
        landName: 'Test',
        mapPolygons: [[1.0, 2.0], [3.0, 4.0]],
      );

      final json = lot.toJson();
      expect(json['id'], 'x');
      expect(json['landName'], 'Test');
      expect(json['mapPolygons'], [[1.0, 2.0], [3.0, 4.0]]);
    });

    test('copyWith altera apenas os campos especificados', () {
      final lot = Lot(
        id: 'x', block: 'A', number: '1',
        area: 100, price: 50000, status: 'Disponível',
        documents: ['doc.pdf'],
      );

      final updated = lot.copyWith(status: 'Vendido');
      expect(updated.status, 'Vendido');
      expect(updated.id, 'x');
      expect(updated.block, 'A');
      expect(updated.documents, ['doc.pdf']); // Mantém

      final updatedDocs = lot.copyWith(documents: ['new.pdf']);
      expect(updatedDocs.documents, ['new.pdf']);
      expect(updatedDocs.status, 'Disponível'); // Mantém
    });
  });
}
