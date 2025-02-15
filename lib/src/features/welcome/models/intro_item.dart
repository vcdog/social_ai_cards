import 'package:flutter/material.dart';

class IntroItem {
  final String title;
  final String description;
  final IconData icon;

  const IntroItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

final List<IntroItem> introItems = [
  const IntroItem(
    title: 'AI 智能创作',
    description: '使用 AI 技术，轻松生成精美的社交分享卡片',
    icon: Icons.auto_awesome,
  ),
  const IntroItem(
    title: '丰富模板',
    description: '海量精选模板，一键套用，快速生成',
    icon: Icons.dashboard,
  ),
  const IntroItem(
    title: '便捷分享',
    description: '支持多平台一键分享，传播更轻松',
    icon: Icons.share,
  ),
];
