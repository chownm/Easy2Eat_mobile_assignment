import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';

class InternationalizePage extends StatefulWidget {
  const InternationalizePage({super.key});

  @override
  State<InternationalizePage> createState() => _InternationalizePageState();
}

class _InternationalizePageState extends State<InternationalizePage> {
  String? _selectedLanguageCode;

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'native': 'English', 'code': 'en'},
    {'name': 'Malay', 'native': 'Bahasa Melayu', 'code': 'ms'},
    {'name': 'Chinese', 'native': '中文', 'code': 'zh'},
    {'name': 'Spanish', 'native': 'Español', 'code': 'es'},
  ];

  @override
  Widget build(BuildContext context) {
    // Safely initialize selected language code from context in build
    _selectedLanguageCode ??= context.locale.languageCode;

    return Scaffold(
      appBar: const RiderSubAppBar(title: "Preferred Language"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select your preferred language",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemesColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final lang = _languages[index];
                  final isSelected = _selectedLanguageCode == lang['code'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? ThemesColors.brandOrange : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: RadioListTile(
                      title: Text(
                        lang['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemesColors.darkCharcoal,
                        ),
                      ),
                      subtitle: Text(
                        lang['native']!,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      value: lang['code']!,
                      groupValue: _selectedLanguageCode!,
                      activeColor: ThemesColors.brandOrange,
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguageCode = value!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemesColors.darkCharcoal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  context.setLocale(Locale(_selectedLanguageCode!));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language successfully updated!')),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  "Save Language",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alias for backwards compatibility
typedef Internationalize = InternationalizePage;
