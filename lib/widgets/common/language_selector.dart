import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      onSelected: (Locale locale) {
        final provider = Provider.of<LocaleProvider>(context, listen: false);
        provider.setLocale(context, locale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        const PopupMenuItem<Locale>(
          value: Locale('ko', ''),
          child: Row(
            children: [
              Text('🇰🇷'),
              SizedBox(width: 8),
              Text('한국어'),
            ],
          ),
        ),
        const PopupMenuItem<Locale>(
          value: Locale('en', ''),
          child: Row(
            children: [
              Text('🇺🇸'),
              SizedBox(width: 8),
              Text('English'),
            ],
          ),
        ),
      ],
    );
  }
} 