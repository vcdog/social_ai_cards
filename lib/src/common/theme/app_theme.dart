import 'package:flutter/material.dart';

class AppTheme {
  // 定义主题色板
  static const primaryGradient = [Color(0xFF6C63FF), Color(0xFF4CAF50)];
  static const secondaryGradient = [Color(0xFFFF6B6B), Color(0xFFFFBE0B)];

  static ThemeData get lightTheme {
    const primaryColor = Color(0xFF6C63FF);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: const Color(0xFFFF6B6B),
        tertiary: const Color(0xFF4CAF50),
        surface: Colors.white,
        background: const Color(0xFFF8F9FA),
      ),

      // Card 样式
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // 按钮样式
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // 导航栏样式
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 65,
        indicatorColor: primaryColor.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // AppBar 样式
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),

      // 输入框样式
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    const primaryColor = Color(0xFF6C63FF);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: const Color(0xFFFF6B6B),
        tertiary: const Color(0xFF4CAF50),
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
      ),

      // Card 样式
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // 其他深色主题样式配置...
    );
  }
}
