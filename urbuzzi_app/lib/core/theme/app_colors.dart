import 'package:flutter/material.dart';

/// Paleta central do app, inspirada num visual clean de SaaS
/// (tons neutros de slate + acentos de status bem distintos entre si).
class AppColors {
  AppColors._();

  // Marca / ação primária
  static const Color primary = Color(0xFF2563EB); // blue-600
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Neutros (slate)
  static const Color background = Color(0xFFF1F5F9); // slate-100
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF64748B); // slate-500
  static const Color textMuted = Color(0xFF94A3B8); // slate-400

  // Sidebar (dark) — alinhado com o protótipo Lovable
  static const Color sidebarBg = Color(0xFF0F172A);           // slate-900
  static const Color sidebarFg = Color(0xFFCBD5E1);           // slate-300
  static const Color sidebarFgMuted = Color(0xFF475569);      // slate-600
  static const Color sidebarPrimary = Color(0xFF3B82F6);      // blue-500
  static const Color sidebarPrimaryFg = Color(0xFFFFFFFF);
  static const Color sidebarAccent = Color(0xFF1E293B);       // slate-800
  static const Color sidebarAccentFg = Color(0xFFFFFFFF);
  static const Color sidebarBorder = Color(0xFF1E293B);       // slate-800

  // Card / header
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color headerBg = Color(0xFFFFFFFF);

  // Status dos lotes — cada um com tom "forte" (texto/ícone) e tom "suave" (fundo de chip)
  static const Color disponivel = Color(0xFF16A34A); // green-600
  static const Color disponivelBg = Color(0xFFDCFCE7); // green-100

  static const Color reservado = Color(0xFFD97706); // amber-600
  static const Color reservadoBg = Color(0xFFFEF3C7); // amber-100

  static const Color emAprovacao = Color(0xFF2563EB); // blue-600
  static const Color emAprovacaoBg = Color(0xFFDBEAFE); // blue-100

  static const Color bloqueado = Color(0xFF64748B); // slate-500
  static const Color bloqueadoBg = Color(0xFFF1F5F9); // slate-100

  static const Color vendido = Color(0xFF7C3AED); // violet-600
  static const Color vendidoBg = Color(0xFFEDE9FE); // violet-100

  static const Color cancelado = Color(0xFFDC2626); // red-600
  static const Color canceladoBg = Color(0xFFFEE2E2); // red-100

  static const List<String> statusOrder = [
    'Disponível',
    'Reservado',
    'Em aprovação',
    'Bloqueado',
    'Vendido',
    'Cancelado',
  ];

  static Color statusColor(String status) {
    switch (status) {
      case 'Disponível':
        return disponivel;
      case 'Reservado':
        return reservado;
      case 'Em aprovação':
        return emAprovacao;
      case 'Bloqueado':
        return bloqueado;
      case 'Vendido':
        return vendido;
      case 'Cancelado':
        return cancelado;
      default:
        return bloqueado;
    }
  }

  static Color statusBgColor(String status) {
    switch (status) {
      case 'Disponível':
        return disponivelBg;
      case 'Reservado':
        return reservadoBg;
      case 'Em aprovação':
        return emAprovacaoBg;
      case 'Bloqueado':
        return bloqueadoBg;
      case 'Vendido':
        return vendidoBg;
      case 'Cancelado':
        return canceladoBg;
      default:
        return bloqueadoBg;
    }
  }
}
