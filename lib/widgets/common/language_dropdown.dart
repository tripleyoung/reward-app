import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, provider, _) {
        return PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          position: PopupMenuPosition.under,
          icon: const Icon(Icons.language),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'ko',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  Text(
                    '한국어',
                    style: TextStyle(
                      fontWeight: provider.locale.languageCode == 'ko' 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
                  if (provider.locale.languageCode == 'ko') ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check, size: 16, 
                      color: Theme.of(context).colorScheme.primary),
                  ],
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  Text(
                    'English',
                    style: TextStyle(
                      fontWeight: provider.locale.languageCode == 'en' 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
                  if (provider.locale.languageCode == 'en') ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check, size: 16, 
                      color: Theme.of(context).colorScheme.primary),
                  ],
                ],
              ),
            ),
          ],
          onSelected: (String value) {
            provider.setLocale(context, Locale(value, ''));
          },
        );
      },
    );
  }
} 