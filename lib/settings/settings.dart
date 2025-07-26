
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _fontSize = 16;
  bool _isDarkMode = false;
  Color _themeColor = Colors.deepPurple;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('字体大小'),
                    subtitle: Slider(
                      min: 12,
                      max: 28,
                      divisions: 8,
                      value: _fontSize,
                      label: _fontSize.toStringAsFixed(0),
                      onChanged: (v) {
                        setState(() { _fontSize = v; });
                      },
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('暗黑模式'),
                    value: _isDarkMode,
                    onChanged: (v) {
                      setState(() { _isDarkMode = v; });
                      
                    },
                  ),
                  ListTile(
                    title: const Text('主题色'),
                    subtitle: Row(
                      children: [
                        _colorCircle(Colors.deepPurple),
                        _colorCircle(Colors.blue),
                        _colorCircle(Colors.green),
                        _colorCircle(Colors.orange),
                        _colorCircle(Colors.red),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '预览效果',
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: _isDarkMode ? Colors.grey[200] : _themeColor,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop({
                        'fontSize': _fontSize,
                        'isDarkMode': _isDarkMode,
                        'themeColor': _themeColor,
                      });
                    },
                    child: const Text('保存并应用'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _fontSize = 16;
                        _isDarkMode = false;
                        _themeColor = Colors.deepPurple;
                      });
                    },
                    child: const Text('重置为默认'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() { _themeColor = color; });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _themeColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
