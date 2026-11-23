import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Static activity-level colors shared by models and widgets.
class AppColors {
  // Activity levels
  static const Color levelIV = Color(0xFFD9453B); // Awas
  static const Color levelIII = Color(0xFFE8742C); // Siaga
  static const Color levelII = Color(0xFFF2B04A); // Waspada
  static const Color levelI = Color(0xFF5FAE63); // Normal

  static const Color amber = Color(0xFFF2B04A);
  static const Color inkOnAmber = Color(0xFF1B1B19);

  // Opaque fills for translucent level backgrounds
  static const Color levelIVBg = Color(0x33D9453B);
  static const Color levelIIIBg = Color(0x33E8742C);
  static const Color levelIIBg = Color(0x33F2B04A);
  static const Color levelIBg = Color(0x335FAE63);

  // Semantic aliases kept for shared widgets
  static const Color primary = levelIV;
  static const Color secondary = Color(0xFF1B1B19);
  static const Color textPrimary = Color(0xFF1B1B19);
  static const Color textSecondary = Color(0xFF7B7B75);
  static const Color textMuted = Color(0xFF9A9A93);
  static const Color errorBadge = levelIV;
  static const Color freshBadge = levelI;
  static const Color staleBadge = levelIII;
}

/// Palette resolved per brightness.
class AppPalette extends ThemeExtension<AppPalette> {
  final Color bg;
  final Color card;
  final Color ink;
  final Color mut;
  final Color line;
  final Color amb;
  final Color lime;
  final Color blu;
  final Color dk;
  final bool isDark;

  const AppPalette({
    required this.bg,
    required this.card,
    required this.ink,
    required this.mut,
    required this.line,
    required this.amb,
    required this.lime,
    required this.blu,
    required this.dk,
    required this.isDark,
  });

  static const AppPalette light = AppPalette(
    bg: Color(0xFFEDEDEA),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF1B1B19),
    mut: Color(0xFF7B7B75),
    line: Color(0xFFE0E0DB),
    amb: Color(0xFFF2B04A),
    lime: Color(0xFFEEF5C8),
    blu: Color(0xFF9DBCF2),
    dk: Color(0xFF1B1B19),
    isDark: false,
  );

  static const AppPalette dark = AppPalette(
    bg: Color(0xFF151513),
    card: Color(0xFF232320),
    ink: Color(0xFFF3F3EE),
    mut: Color(0xFF9C9C95),
    line: Color(0xFF33332F),
    amb: Color(0xFFF2B04A),
    lime: Color(0xFF2C3320),
    blu: Color(0xFF9DBCF2),
    dk: Color(0xFF2D2D29),
    isDark: true,
  );

  @override
  AppPalette copyWith({
    Color? bg,
    Color? card,
    Color? ink,
    Color? mut,
    Color? line,
    Color? amb,
    Color? lime,
    Color? blu,
    Color? dk,
    bool? isDark,
  }) {
    return AppPalette(
      bg: bg ?? this.bg,
      card: card ?? this.card,
      ink: ink ?? this.ink,
      mut: mut ?? this.mut,
      line: line ?? this.line,
      amb: amb ?? this.amb,
      lime: lime ?? this.lime,
      blu: blu ?? this.blu,
      dk: dk ?? this.dk,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      mut: Color.lerp(mut, other.mut, t)!,
      line: Color.lerp(line, other.line, t)!,
      amb: Color.lerp(amb, other.amb, t)!,
      lime: Color.lerp(lime, other.lime, t)!,
      blu: Color.lerp(blu, other.blu, t)!,
      dk: Color.lerp(dk, other.dk, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;

  /// Text color that stays legible on an amber accent.
  Color get onAccent => AppColors.inkOnAmber;
}

class AppTheme {
  static ThemeData get lightTheme => _build(AppPalette.light, Brightness.light);

  static ThemeData get darkTheme => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Outfit',
      scaffoldBackgroundColor: p.bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: p.amb,
        onPrimary: AppColors.inkOnAmber,
        secondary: p.ink,
        onSecondary: p.card,
        error: p.isDark ? const Color(0xFFE57368) : AppColors.levelIV,
        onError: Colors.white,
        surface: p.card,
        onSurface: p.ink,
      ),
      extensions: [p],
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: p.ink),
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          color: p.ink,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        systemOverlayStyle:
            p.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      dividerColor: p.line,
      dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: p.ink),
      textTheme: base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.dk,
        contentTextStyle: const TextStyle(
          fontFamily: 'Outfit',
          color: Colors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(16),
        elevation: 0,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.amb),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.ink,
        selectionColor: p.amb.withValues(alpha: 0.3),
        selectionHandleColor: p.amb,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.amb,
          foregroundColor: AppColors.inkOnAmber,
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
