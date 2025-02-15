import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/constants/supported_locales.dart';
import '../../common/providers/locale_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      default:
        return 'Unknown';
    }
  }

  IconData _getLanguageIcon(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return Icons.language;
      case 'en':
        return Icons.language;
      default:
        return Icons.language;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('语言设置'),
      ),
      body: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return ListView.builder(
            itemCount: SupportedLocales.locales.length,
            itemBuilder: (context, index) {
              final locale = SupportedLocales.locales[index];
              final isSelected = locale.languageCode == localeProvider.locale.languageCode;

              return ListTile(
                leading: Icon(
                  _getLanguageIcon(locale.languageCode),
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
                title: Text(_getLanguageName(locale.languageCode)),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () {
                  localeProvider.setLocale(locale);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
} 