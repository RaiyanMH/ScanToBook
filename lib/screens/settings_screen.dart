import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    double textSize = themeProvider.textSize;
    String theme = themeProvider.customTheme;
  final List<Map<String, dynamic>> _themes = [
    {'label': 'System', 'value': 'system'},
    {'label': 'OLED Black', 'value': 'oled'},
    {'label': 'Blue Dark', 'value': 'blue_dark'},
    {'label': 'Sepia', 'value': 'sepia'},
    {'label': 'Green Dark', 'value': 'green'},
    {'label': 'Purple Dark', 'value': 'purple'},
  ];
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Text Size', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            min: 12,
            max: 28,
            divisions: 8,
            value: textSize,
            label: textSize.toStringAsFixed(0),
            onChanged: (v) => themeProvider.setTextSize(v),
          ),
          SizedBox(height: 24),
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          ..._themes.map((t) => RadioListTile<String>(
                title: Text(t['label']),
                value: t['value'],
                groupValue: theme,
                onChanged: (v) => themeProvider.setCustomTheme(v!),
              )),
          SizedBox(height: 24),
          ListTile(
            title: Text('About'),
            subtitle: Text('ScanToBook v1.0.0\nA professional book scanning and reading app.'),
            leading: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
} 