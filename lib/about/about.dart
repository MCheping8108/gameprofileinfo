import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于软件'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('gameProfileInfo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('本软件用于展示游戏玩家基础信息等多种内容，可能会有多个游戏的内容。'),
            SizedBox(height: 16),
            Text('作者：和平peaceful'),
            SizedBox(height: 8),
            Text('github仓库地址：https://github.com/MCheping8108/gameprofileinfo'),
            SizedBox(height: 24),
            Text('感谢', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('妮露API：https://www.nilou.moe'),
            Text('Github Copilot：https://github.com')
          ],
        ),
      ),
    );
  }
}
