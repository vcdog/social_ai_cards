import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/providers/theme_provider.dart';

class ThemeModeScreen extends StatelessWidget {
  const ThemeModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('深色模式'),
        centerTitle: true,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              // 系统跟随组
              _buildSection(
                title: '跟随系统',
                subtitle: '开启后，将跟随系统打开或关闭深色模式',
                child: Switch(
                  value: themeProvider.themeMode == ThemeMode.system,
                  onChanged: (value) {
                    themeProvider.setThemeMode(
                      value ? ThemeMode.system : ThemeMode.light,
                    );
                  },
                ),
              ),

              // 手动选择组
              if (themeProvider.themeMode != ThemeMode.system) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
                  child: Text(
                    '手动选择',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
                _buildThemeOption(
                  context,
                  title: '普通模式',
                  isSelected: themeProvider.themeMode == ThemeMode.light,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                ),
                _buildThemeOption(
                  context,
                  title: '深色模式',
                  isSelected: themeProvider.themeMode == ThemeMode.dark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和开关放在同一行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child, // Switch 开关
            ],
          ),
          const SizedBox(height: 4),
          // 副标题
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
} 