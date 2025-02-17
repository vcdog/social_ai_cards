import 'package:flutter/material.dart';

class AppAssets {
  // 临时使用 Material Icons 替代图片
  static const String intro1 = 'assets/images/intro_1.png';
  static const String intro2 = 'assets/images/intro_2.png';
  static const String intro3 = 'assets/images/intro_3.png';

  // 颜色常量
  static const gradients = _Gradients();
  static const colors = _Colors();
  static const shadows = _Shadows();
  static const spacing = _Spacing();
  static const radius = _Radius();
  static const fontSize = _FontSize();

  // 动画时长
  static const animationDuration = Duration(milliseconds: 300);
  static const pageTransitionDuration = Duration(milliseconds: 400);
}

class _Gradients {
  const _Gradients();

  final primary = const [Color(0xFF6C63FF), Color(0xFF4CAF50)];
  final secondary = const [Color(0xFFFF6B6B), Color(0xFFFFBE0B)];
  final tertiary = const [Color(0xFF00BCD4), Color(0xFF03A9F4)];
  final success = const [Color(0xFF4CAF50), Color(0xFF8BC34A)];
  final warning = const [Color(0xFFFFEB3B), Color(0xFFFFC107)];
  final error = const [Color(0xFFFF5252), Color(0xFFFF1744)];
}

class _Colors {
  const _Colors();

  final primary = const Color(0xFF6C63FF);
  final secondary = const Color(0xFFFF6B6B);
  final tertiary = const Color(0xFF4CAF50);
  final background = const Color(0xFFF8F9FA);
  final surface = const Color(0xFFFFFFFF);
  final text = const Color(0xFF1F2937);
  final textSecondary = const Color(0xFF6B7280);

  // 添加一些语义化的颜色
  final success = const Color(0xFF4CAF50);
  final warning = const Color(0xFFFFC107);
  final error = const Color(0xFFFF5252);
  final info = const Color(0xFF2196F3);
}

class _Spacing {
  const _Spacing();

  final double xs = 4;
  final double sm = 8;
  final double md = 16;
  final double lg = 24;
  final double xl = 32;
  final double xxl = 48;

  // 添加一些特殊间距
  final double section = 40;
  final double page = 24;
  final double card = 16;
  final double item = 12;
}

class _Radius {
  const _Radius();

  final double xs = 4;
  final double sm = 8;
  final double md = 12;
  final double lg = 16;
  final double xl = 24;
  final double xxl = 32;

  // 添加一些特殊圆角
  final double button = 12;
  final double card = 16;
  final double modal = 24;
  final double circle = 999;
}

class _Shadows {
  const _Shadows();

  final light = const [
    BoxShadow(
      color: Color(0x0D000000), // 5% 透明度
      blurRadius: 10,
      offset: Offset(0, 4),
    )
  ];

  final medium = const [
    BoxShadow(
      color: Color(0x14000000), // 8% 透明度
      blurRadius: 15,
      offset: Offset(0, 6),
    )
  ];

  final heavy = const [
    BoxShadow(
      color: Color(0x1F000000), // 12% 透明度
      blurRadius: 20,
      offset: Offset(0, 8),
    )
  ];

  // 添加一些特殊阴影效果
  final card = const [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    )
  ];

  final button = const [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    )
  ];

  final modal = const [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    )
  ];
}

class _FontSize {
  const _FontSize();

  final double xs = 12;
  final double sm = 14;
  final double base = 16;
  final double lg = 18;
  final double xl = 20;
  final double xxl = 24;
  final double display = 32;

  // 添加一些特殊字号
  final double title = 22;
  final double subtitle = 16;
  final double caption = 12;
  final double button = 14;
}
