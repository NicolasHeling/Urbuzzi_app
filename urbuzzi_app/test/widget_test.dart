import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:urbuzzi_app/core/widgets/status_badge.dart';
import 'package:urbuzzi_app/core/theme/app_colors.dart';
import 'package:urbuzzi_app/core/auth/user_role.dart';
import 'package:urbuzzi_app/features/auth/presentation/auth_provider.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // 1. StatusBadge — cor muda corretamente para cada status
  // ─────────────────────────────────────────────────────────────────────────
  group('StatusBadge', () {
    Widget buildBadge(String status) {
      return MaterialApp(
        home: Scaffold(body: StatusBadge(status: status)),
      );
    }

    testWidgets('exibe texto e cor para status "Disponível"', (tester) async {
      await tester.pumpWidget(buildBadge('Disponível'));
      expect(find.text('Disponível'), findsOneWidget);

      // O dot interno deve ter a cor correta
      final dot = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle),
        ),
      );
      final decoration = dot.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.disponivel));
    });

    testWidgets('exibe texto e cor para status "Reservado"', (tester) async {
      await tester.pumpWidget(buildBadge('Reservado'));
      expect(find.text('Reservado'), findsOneWidget);

      final dot = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle),
        ),
      );
      expect((dot.decoration as BoxDecoration).color, equals(AppColors.reservado));
    });

    testWidgets('exibe texto e cor para status "Vendido"', (tester) async {
      await tester.pumpWidget(buildBadge('Vendido'));
      expect(find.text('Vendido'), findsOneWidget);

      final dot = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle),
        ),
      );
      expect((dot.decoration as BoxDecoration).color, equals(AppColors.vendido));
    });

    testWidgets('exibe texto e cor para status "Em aprovação"', (tester) async {
      await tester.pumpWidget(buildBadge('Em aprovação'));
      expect(find.text('Em aprovação'), findsOneWidget);

      final dot = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle),
        ),
      );
      expect((dot.decoration as BoxDecoration).color, equals(AppColors.emAprovacao));
    });

    testWidgets('status desconhecido recebe cor de fallback (bloqueado)', (tester) async {
      await tester.pumpWidget(buildBadge('StatusInventado'));
      expect(find.text('StatusInventado'), findsOneWidget);

      final dot = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle),
        ),
      );
      expect((dot.decoration as BoxDecoration).color, equals(AppColors.bloqueado));
    });

    testWidgets('modo dense reduz a fonte para 11', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatusBadge(status: 'Disponível', dense: true)),
        ),
      );
      final text = tester.widget<Text>(find.text('Disponível'));
      expect(text.style?.fontSize, equals(11));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 2. UserRole — fromString cobre os 4 papéis + fallback
  // ─────────────────────────────────────────────────────────────────────────
  group('UserRole.fromString', () {
    test('retorna administrador para "administrador"', () {
      expect(UserRole.fromString('administrador'), UserRole.administrador);
    });

    test('retorna gestor para "gestor"', () {
      expect(UserRole.fromString('gestor'), UserRole.gestor);
    });

    test('retorna comercial para "comercial"', () {
      expect(UserRole.fromString('comercial'), UserRole.comercial);
    });

    test('retorna consulta para "consulta"', () {
      expect(UserRole.fromString('consulta'), UserRole.consulta);
    });

    test('retorna consulta para valores desconhecidos (fallback)', () {
      expect(UserRole.fromString('invalido'), UserRole.consulta);
      expect(UserRole.fromString(''), UserRole.consulta);
      expect(UserRole.fromString('root'), UserRole.consulta);
    });

    test('é case-insensitive', () {
      expect(UserRole.fromString('ADMINISTRADOR'), UserRole.administrador);
      expect(UserRole.fromString('Gestor'), UserRole.gestor);
      expect(UserRole.fromString('COMERCIAL'), UserRole.comercial);
    });
  });

  group('UserRole permissions', () {
    test('canWrite: admin, gestor e comercial podem escrever, consulta não', () {
      expect(UserRole.administrador.canWrite, isTrue);
      expect(UserRole.gestor.canWrite, isTrue);
      expect(UserRole.comercial.canWrite, isTrue);
      expect(UserRole.consulta.canWrite, isFalse);
    });

    test('canApprove: apenas admin e gestor', () {
      expect(UserRole.administrador.canApprove, isTrue);
      expect(UserRole.gestor.canApprove, isTrue);
      expect(UserRole.comercial.canApprove, isFalse);
      expect(UserRole.consulta.canApprove, isFalse);
    });

    test('label retorna string capitalizada', () {
      expect(UserRole.administrador.label, 'Administrador');
      expect(UserRole.gestor.label, 'Gestor');
      expect(UserRole.comercial.label, 'Comercial');
      expect(UserRole.consulta.label, 'Consulta');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 3. RBAC — botões de ação ocultos quando currentUserRoleProvider = consulta
  // ─────────────────────────────────────────────────────────────────────────
  group('RBAC: botões condicionais por papel', () {
    // Widget auxiliar que simula a lógica de exibição condicional de botões,
    // usando o mesmo padrão do app (canApprove / canWrite).
    Widget buildTestableButtons(UserRole role) {
      return ProviderScope(
        overrides: [
          currentUserRoleProvider.overrideWithValue(role),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final userRole = ref.watch(currentUserRoleProvider);
                return Column(
                  children: [
                    // Botão visível apenas para quem pode aprovar (gestor/admin)
                    if (userRole.canApprove)
                      const ElevatedButton(
                        onPressed: null,
                        child: Text('Aprovar Venda'),
                      ),
                    // Botão visível apenas para quem pode escrever (admin/gestor/comercial)
                    if (userRole.canWrite)
                      const ElevatedButton(
                        onPressed: null,
                        child: Text('Reservar Lote'),
                      ),
                    // Botão sempre visível para todos
                    const Text('Visualizar Detalhes'),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    testWidgets('role consulta: não vê botões de ação, vê apenas texto informativo', (tester) async {
      await tester.pumpWidget(buildTestableButtons(UserRole.consulta));

      expect(find.text('Aprovar Venda'), findsNothing);
      expect(find.text('Reservar Lote'), findsNothing);
      expect(find.text('Visualizar Detalhes'), findsOneWidget);
    });

    testWidgets('role comercial: vê "Reservar Lote" mas NÃO vê "Aprovar Venda"', (tester) async {
      await tester.pumpWidget(buildTestableButtons(UserRole.comercial));

      expect(find.text('Aprovar Venda'), findsNothing);
      expect(find.text('Reservar Lote'), findsOneWidget);
      expect(find.text('Visualizar Detalhes'), findsOneWidget);
    });

    testWidgets('role gestor: vê ambos os botões', (tester) async {
      await tester.pumpWidget(buildTestableButtons(UserRole.gestor));

      expect(find.text('Aprovar Venda'), findsOneWidget);
      expect(find.text('Reservar Lote'), findsOneWidget);
      expect(find.text('Visualizar Detalhes'), findsOneWidget);
    });

    testWidgets('role administrador: vê ambos os botões', (tester) async {
      await tester.pumpWidget(buildTestableButtons(UserRole.administrador));

      expect(find.text('Aprovar Venda'), findsOneWidget);
      expect(find.text('Reservar Lote'), findsOneWidget);
      expect(find.text('Visualizar Detalhes'), findsOneWidget);
    });
  });
}
