import 'package:flutter/material.dart';

class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('声明'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('软件声明', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('请先建议阅读该软件声明（简称“声明”），如果继续使用该软件将视为自动同意本声明的所有内容。'),
            SizedBox(height: 24),
            Text('1. 服务器API接口', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('由于国际的mihoyo(即hoyoverse)锁定了中国大陆地区，本软件使用的API接口来自于妮露API（https://www.nilou.moe），请遵守其相关使用条款。'),
            SizedBox(height: 8),
            Text('2. 数据隐私', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('本软件不会收集、存储或传输任何用户的个人信息或游戏数据。所有数据均在本地处理，不会上传至服务器。'),
            SizedBox(height: 8),
            Text('3. 个人账户', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('该软件没有任何强制用户注册、登录、注销等行为。用户可以自由使用软件的所有功能，无需提供任何个人信息。'),
          ],
        ),
      ),
    );
  }
}
