import 'package:flutter/material.dart';

/// Paleta central do app, espelhando o design system Lovable (OKLCH → HEX).
class AppColors {
  AppColors._();

  // Marca / ação primária (warm amber/burnt-orange — Lovable primary)
  static const Color primary = Color(0xFFC2650A);
  static const Color primaryDark = Color(0xFFA85508);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  // Neutros (warm off-white tones — Lovable uses oklch warm neutrals)
  static const Color background = Color(0xFFFAF9F6); // warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0DDD8); // warm light gray
  static const Color textPrimary = Color(0xFF1A1A2E); // near-black
  static const Color textSecondary = Color(0xFF7C7C72); // muted foreground
  static const Color textMuted = Color(0xFFA3A39A); // lighter muted

  // Muted / Accent
  static const Color muted = Color(0xFFF3F2EF);
  static const Color accent = Color(0xFFF5EDE3); // warm peach accent
  static const Color accentForeground = Color(0xFF8B4513);

  // Sidebar (dark warm) — alinhado com o Lovable
  static const Color sidebarBg = Color(0xFF2D2D3D);
  static const Color sidebarFg = Color(0xFFEDECEA);
  static const Color sidebarFgMuted = Color(0xFF8A8A94);
  static const Color sidebarPrimary = Color(0xFFC2650A); // same warm amber
  static const Color sidebarPrimaryFg = Color(0xFFFFFFFF);
  static const Color sidebarAccent = Color(0xFF3D3D4D);
  static const Color sidebarAccentFg = Color(0xFFFAF9F6);
  static const Color sidebarBorder = Color(0xFF454555);

  // Card / header
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color headerBg = Color(0xFFFFFFFF);

  // Status dos lotes — Lovable OKLCH palette (bg + foreground pairs)
  static const Color disponivel = Color(0xFF1B7A3D); // dark green (foreground)
  static const Color disponivelBg = Color(0xFFD4F5E0); // light green

  static const Color reservado = Color(0xFF9A6B28); // dark amber
  static const Color reservadoBg = Color(0xFFF5E6C8); // light amber

  static const Color emAprovacao = Color(0xFF2952A3); // dark blue
  static const Color emAprovacaoBg = Color(0xFFD4E4FA); // light blue

  static const Color bloqueado = Color(0xFF6B6B73); // medium gray
  static const Color bloqueadoBg = Color(0xFFE5E5E5); // light gray

  static const Color vendido = Color(0xFFC62828); // red
  static const Color vendidoBg = Color(0xFFFAD4D4); // light red/rose

  static const Color cancelado = Color(0xFF3A3A42); // dark gray
  static const Color canceladoBg = Color(0xFFD5D5D8); // grayish

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
