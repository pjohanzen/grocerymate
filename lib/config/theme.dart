import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Spacing Constants ───────────────────────────────────────────
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // ─── Premium Palette (Forest Green & Muted Carrot) ────────────────
  static const Color primary = Color(0xFF2D6A4F);      // Forest Green
  static const Color primaryLight = Color(0xFF52B788); // Sage/Vibrant Accent
  static const Color primaryDark = Color(0xFF1B4332);  // Deep Forest Green
  static const Color secondary = Color(0xFFD07A3E);    // Warm Muted Carrot
  static const Color secondaryLight = Color(0xFFEAA070);
  static const Color secondaryDark = Color(0xFFB05B21);
  static const Color tertiary = Color(0xFF8B263E);     // Warm Beetroot Red
  static const Color accent = Color(0xFFC94A4A);       // Berry Alert Accent

  // ─── Spacing/Bento Neutral Colors (Refined Sage-Greys) ───────────
  static const Color neutral100 = Color(0xFFF9FAF8);
  static const Color neutral200 = Color(0xFFF0F2EE);
  static const Color neutral250 = Color(0xFFE9EBE6);
  static const Color neutral300 = Color(0xFFE2E6DF);
  static const Color neutral400 = Color(0xFFBFC4BA);
  static const Color neutral500 = Color(0xFF7A827B);
  static const Color neutral600 = Color(0xFF535A54);
  static const Color neutral700 = Color(0xFF353C37);
  static const Color neutral800 = Color(0xFF202522);
  static const Color neutral900 = Color(0xFF131714);

  static const Color success = Color(0xFF2D6A4F);
  static const Color successLight = Color(0xFFE2F0D9);
  static const Color warning = Color(0xFFE99D34);
  static const Color warningLight = Color(0xFFFEF2E2);
  static const Color error = Color(0xFFC94A4A);
  static const Color errorLight = Color(0xFFFDE8E8);

  // ─── Dark Theme Surface Colors ───────────────────────────────────
  static const Color darkBackground = Color(0xFF111613);       // Deep organic green-black
  static const Color darkSurface = Color(0xFF1A221C);          // Soft container green-grey
  static const Color darkSurfaceElevated = Color(0xFF1E2620);
  static const Color darkSurfaceHigh = Color(0xFF232D26);      // Active container
  static const Color darkSurfaceContainer = Color(0xFF1A221C);
  static const Color darkBorder = Color(0xFF2E3A31);
  static const Color darkTextPrimary = Color(0xFFE8ECE9);
  static const Color darkTextSecondary = Color(0xFF909A93);

  // ─── Font Pairing: Outfit (Headings) & Inter (Body) ──────────────
  static TextStyle get display => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get headline1 => GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  static TextStyle get headline2 => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headline3 => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get bodyRegular => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.3,
      );

  static TextStyle get monoRegular => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get monoBold => GoogleFonts.jetBrainsMono(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get monoLarge => GoogleFonts.jetBrainsMono(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  // ─── Light ThemeData ─────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD8F3DC),
      onPrimaryContainer: primaryDark,
      secondary: secondary,
      onSecondary: Colors.white,
      tertiary: tertiary,
      onTertiary: Colors.white,
      surface: lightSurface,
      onSurface: neutral900,
      surfaceContainerLow: neutral200,
      surfaceContainerHigh: lightSurface,
      outline: neutral300,
      outlineVariant: neutral200,
      error: error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: neutral100,
      textTheme: _buildTextTheme(neutral900, neutral500),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: headline3.copyWith(color: neutral900),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: neutral300, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neutral200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: bodyRegular.copyWith(color: neutral500),
        hintStyle: bodyRegular.copyWith(color: neutral400),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: neutral200,
        selectedColor: primary.withValues(alpha: 0.15),
        labelStyle: label.copyWith(color: neutral900),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
        dragHandleColor: neutral300,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: neutral900,
        contentTextStyle: bodyRegular.copyWith(color: Colors.white),
      ),
      dividerTheme: const DividerThemeData(
        color: neutral200,
        thickness: 1,
        space: 0,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: neutral400, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: neutral200,
      ),
    );
  }

  // ─── Dark ThemeData ──────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: primaryLight,
      onPrimary: darkSurface,
      primaryContainer: primaryLight.withValues(alpha: 0.15),
      onPrimaryContainer: Colors.white,
      secondary: secondary,
      onSecondary: darkSurface,
      tertiary: tertiary,
      onTertiary: Colors.white,
      surface: darkSurface,
      onSurface: darkTextPrimary,
      surfaceContainerLow: darkSurfaceContainer,
      surfaceContainerHigh: darkSurface,
      outline: darkBorder,
      outlineVariant: darkBorder.withValues(alpha: 0.5),
      error: error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      textTheme: _buildTextTheme(darkTextPrimary, darkTextSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: headline3.copyWith(color: darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: darkBorder, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: darkSurface,
          minimumSize: const Size(double.infinity, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: primaryLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: bodyRegular.copyWith(color: darkTextSecondary),
        hintStyle: bodyRegular.copyWith(color: darkTextSecondary.withValues(alpha: 0.5)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceContainer,
        selectedColor: primaryLight.withValues(alpha: 0.25),
        labelStyle: label.copyWith(color: darkTextPrimary),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
        dragHandleColor: darkBorder,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: darkSurfaceContainer,
        contentTextStyle: bodyRegular.copyWith(color: darkTextPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 0,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryLight;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(darkSurface),
        side: const BorderSide(color: darkTextSecondary, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryLight,
        linearTrackColor: darkSurfaceContainer,
      ),
    );
  }

  // ─── Shared TextTheme builder ────────────────────────────────
  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: display.copyWith(color: primaryColor),
      headlineLarge: headline1.copyWith(color: primaryColor),
      headlineMedium: headline2.copyWith(color: primaryColor),
      headlineSmall: headline3.copyWith(color: primaryColor),
      titleLarge: headline3.copyWith(color: primaryColor),
      titleMedium: bodyLarge.copyWith(color: primaryColor),
      titleSmall: bodyRegular.copyWith(color: primaryColor),
      bodyLarge: bodyLarge.copyWith(color: primaryColor),
      bodyMedium: bodyRegular.copyWith(color: primaryColor),
      bodySmall: caption.copyWith(color: secondaryColor),
      labelLarge: label.copyWith(color: primaryColor),
      labelMedium: label.copyWith(color: secondaryColor),
      labelSmall: caption.copyWith(color: secondaryColor),
    );
  }

  static Color getBudgetColor(double percentage) {
    if (percentage >= 0.95) return error;
    if (percentage >= 0.75) return warning;
    return success;
  }

  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return error;
      case 2:
        return warning;
      case 1:
        return primary;
      default:
        return neutral500;
    }
  }

  static String getPriorityLabel(int priority) {
    switch (priority) {
      case 3:
        return 'Urgent';
      case 2:
        return 'High';
      case 1:
        return 'Normal';
      default:
        return 'Low';
    }
  }

  // Helpers to fetch current surface/container backgrounds
  static Color getScaffoldBackground(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getSurface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getCardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkSurfaceElevated : Colors.white;
  }

  static Color getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBorder : neutral300;
  }

  static Color getTextPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTextPrimary : neutral900;
  }

  static Color getTextSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTextSecondary : neutral500;
  }
  
  static const Color lightSurface = Colors.white;
}
