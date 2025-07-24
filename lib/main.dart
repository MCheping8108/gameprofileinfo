import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'about/about.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
// import 'dart:typed_data';

// BasicInfo.json stats字段（除field_ext_map）对应的Dart类
class GenshinStats {
  final int activeDayNumber;
  final int achievementNumber;
  final int anemoculusNumber;
  final int geoculusNumber;
  final int avatarNumber;
  final int wayPointNumber;
  final int domainNumber;
  final String spiralAbyss;
  final int preciousChestNumber;
  final int luxuriousChestNumber;
  final int exquisiteChestNumber;
  final int commonChestNumber;
  final int electroculusNumber;
  final int magicChestNumber;
  final int dendroculusNumber;
  final int hydroculusNumber;
  final int pyroculusNumber;
  final int fullFetterAvatarNum;
  final int hardChallengeDifficulty;
  final String hardChallengeName;
  final bool hardChallengeHasData;
  final bool hardChallengeIsUnlock;
  final bool roleCombatIsUnlock;
  final int roleCombatMaxRoundId;
  final bool roleCombatHasData;
  final bool roleCombatHasDetailData;

  GenshinStats({
    required this.activeDayNumber,
    required this.achievementNumber,
    required this.anemoculusNumber,
    required this.geoculusNumber,
    required this.avatarNumber,
    required this.wayPointNumber,
    required this.domainNumber,
    required this.spiralAbyss,
    required this.preciousChestNumber,
    required this.luxuriousChestNumber,
    required this.exquisiteChestNumber,
    required this.commonChestNumber,
    required this.electroculusNumber,
    required this.magicChestNumber,
    required this.dendroculusNumber,
    required this.hydroculusNumber,
    required this.pyroculusNumber,
    required this.fullFetterAvatarNum,
    required this.hardChallengeDifficulty,
    required this.hardChallengeName,
    required this.hardChallengeHasData,
    required this.hardChallengeIsUnlock,
    required this.roleCombatIsUnlock,
    required this.roleCombatMaxRoundId,
    required this.roleCombatHasData,
    required this.roleCombatHasDetailData,
  });

  factory GenshinStats.fromJson(Map<String, dynamic> json) {
    final hardChallenge = json['hard_challenge'] ?? {};
    final roleCombat = json['role_combat'] ?? {};
    return GenshinStats(
      activeDayNumber: json['active_day_number'] ?? 0,
      achievementNumber: json['achievement_number'] ?? 0,
      anemoculusNumber: json['anemoculus_number'] ?? 0,
      geoculusNumber: json['geoculus_number'] ?? 0,
      avatarNumber: json['avatar_number'] ?? 0,
      wayPointNumber: json['way_point_number'] ?? 0,
      domainNumber: json['domain_number'] ?? 0,
      spiralAbyss: json['spiral_abyss'] ?? '',
      preciousChestNumber: json['precious_chest_number'] ?? 0,
      luxuriousChestNumber: json['luxurious_chest_number'] ?? 0,
      exquisiteChestNumber: json['exquisite_chest_number'] ?? 0,
      commonChestNumber: json['common_chest_number'] ?? 0,
      electroculusNumber: json['electroculus_number'] ?? 0,
      magicChestNumber: json['magic_chest_number'] ?? 0,
      dendroculusNumber: json['dendroculus_number'] ?? 0,
      hydroculusNumber: json['hydroculus_number'] ?? 0,
      pyroculusNumber: json['pyroculus_number'] ?? 0,
      fullFetterAvatarNum: json['full_fetter_avatar_num'] ?? 0,
      hardChallengeDifficulty: hardChallenge['difficulty'] ?? 0,
      hardChallengeName: hardChallenge['name'] ?? '',
      hardChallengeHasData: hardChallenge['has_data'] ?? false,
      hardChallengeIsUnlock: hardChallenge['is_unlock'] ?? false,
      roleCombatIsUnlock: roleCombat['is_unlock'] ?? false,
      roleCombatMaxRoundId: roleCombat['max_round_id'] ?? 0,
      roleCombatHasData: roleCombat['has_data'] ?? false,
      roleCombatHasDetailData: roleCombat['has_detail_data'] ?? false,
    );
  }
}
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gameProfileInfo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'gameProfileInfo'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void showAlert(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  Map<String, dynamic>? basicInfo;
  bool isLoading = true;
  String? errorMsg;

  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _serverController = TextEditingController();

  final String kUidKey = 'genshin_uid';
  final String kServerKey = 'genshin_server';
  final String kCacheFile = 'BasicInfo.json';

  final GlobalKey _boundaryKey = GlobalKey();

  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAlert('使用前确保对方是否开启了“在个人中心是否展示角色战绩”\n请输入你的原神UID和服务器（如cn_gf01），点击“获取/保存”即可获取并保存你的游戏信息。\n\n服务器常用：\n国服官服：cn_gf01\n国服B服：cn_qd01\n国际服：os_usa、os_euro、os_asia、os_cht');
    });
    _loadUserPrefs().then((_) => loadBasicInfo());
  }

  Future<void> _loadUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _uidController.text = prefs.getString(kUidKey) ?? '';
    _serverController.text = prefs.getString(kServerKey) ?? '';
  }

  Future<String> _getCacheFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$kCacheFile';
  }

  Future<void> loadBasicInfo() async {
    setState(() { isLoading = true; errorMsg = null; });
    try {
      // 优先加载本地缓存
      final filePath = await _getCacheFilePath();
      if (await File(filePath).exists()) {
        final jsonStr = await File(filePath).readAsString();
        final Map<String, dynamic> jsonMap = json.decode(jsonStr);
        setState(() {
          basicInfo = jsonMap['data'] ?? jsonMap;
          isLoading = false;
        });
        return;
      }
      // 若本地无缓存，尝试加载 assets 里的初始数据
      final String jsonStr = await rootBundle.loadString('assets/BasicInfo.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      setState(() {
        basicInfo = jsonMap['data'] ?? jsonMap;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = '加载数据失败: \n$e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchAndSaveBasicInfo() async {
    final uid = _uidController.text.trim();
    final server = _serverController.text.trim();
    if (uid.isEmpty || server.isEmpty) {
      setState(() { errorMsg = '请填写UID和服务器'; });
      return;
    }
    setState(() { isLoading = true; errorMsg = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kUidKey, uid);
      await prefs.setString(kServerKey, server);
      final url = 'https://api.nilou.moe/v1/bbs/genshin/BasicInfo?uid=$uid&server=$server';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final filePath = await _getCacheFilePath();
        await File(filePath).writeAsString(response.body);
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        setState(() {
          basicInfo = jsonMap['data'] ?? jsonMap;
          isLoading = false;
        });
      } else {
      setState(() {
        errorMsg = 'API请求失败: ${response.statusCode}';
        isLoading = false;
      });
      }
    } catch (e) {
      setState(() {
        errorMsg = '请求或保存数据失败: \n$e';
        isLoading = false;
      });
    }
  }
  // 因为这段代码让我反复换JDK8，11，17，21，所以被折磨了两天...
  // Future<void> saveScreenshot() async {
  //   try {
  //     // 申请存储权限（安卓需要）
  //     if (Platform.isAndroid) {
  //       var status = await Permission.storage.request();
  //       if (!status.isGranted) {
  //         showAlert('未获得存储权限，无法保存截图');
  //         return;
  //       }
  //     }
  //     // 获取整个界面的 RenderRepaintBoundary
  //     RenderRepaintBoundary boundary = _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //     var image = await boundary.toImage(pixelRatio: 3.0);
  //     ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
  //     if (byteData == null) {
  //       showAlert('截图失败');
  //       return;
  //     }
  //     final pngBytes = byteData.buffer.asUint8List();
  //
  //     // 保存到相册
  //     final result = await ImageGallerySaver.saveImage(
  //       pngBytes,
  //       quality: 100,
  //       name: 'pictureshot_${DateTime.now().millisecondsSinceEpoch}',
  //     );
  //     if (result['isSuccess'] == true || result['success'] == true) {
  //       showAlert('截图已保存到相册');
  //     } else {
  //       showAlert('保存失败: ${result['errorMessage'] ?? result.toString()}');
  //     }
  //   } catch (e) {
  //     showAlert('截图或保存失败: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _boundaryKey,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('菜单', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('关于软件'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _uidController,
                      decoration: const InputDecoration(labelText: 'UID'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _serverController,
                      decoration: const InputDecoration(labelText: '服务器(如 cn_gf01)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading ? null : fetchAndSaveBasicInfo,
                    child: const Text('获取/更新/保存'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMsg != null
                      ? Center(child: Text(errorMsg!))
                      : buildBasicInfoView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBasicInfoView() {
    if (basicInfo == null) return const Text('无数据');
    final role = basicInfo!["role"];
    final avatars = List<Map<String, dynamic>>.from(basicInfo!["avatars"] ?? []);
    final statsRaw = basicInfo!["stats"];
    GenshinStats? stats;
    if (statsRaw != null) {
      stats = GenshinStats.fromJson(statsRaw);
    }
    if (role == null) {
      return const Center(child: Text('未获取到角色信息，请检查UID/服务器或稍后重试。'));
    }
    // 处理世界探索数据
    final worldExplorationsRaw = basicInfo!["world_explorations"] as List? ?? [];
    final List<WorldExploration> worldExplorations = worldExplorationsRaw.map((e) => WorldExploration.fromJson(e)).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: role["game_head_icon"] != null && role["game_head_icon"].toString().isNotEmpty
                    ? NetworkImage(role["game_head_icon"])
                    : null,
                radius: 32,
                child: role["game_head_icon"] == null || role["game_head_icon"].toString().isEmpty
                    ? const Icon(Icons.person, size: 32)
                    : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role["nickname"] ?? "", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("等级: "+(role["level"]?.toString() ?? "-")),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (stats != null) ...[
            const Text("账号统计信息:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _statItem("活跃天数", stats.activeDayNumber),
                    _statItem("成就数", stats.achievementNumber),
                    _statItem("角色数", stats.avatarNumber),
                    _statItem("传送点数", stats.wayPointNumber),
                    _statItem("秘境数", stats.domainNumber),
                    _statItem("深渊进度", stats.spiralAbyss),
                    _statItem("风神瞳", stats.anemoculusNumber),
                    _statItem("岩神瞳", stats.geoculusNumber),
                    _statItem("雷神瞳", stats.electroculusNumber),
                    _statItem("草神瞳", stats.dendroculusNumber),
                    _statItem("水神瞳", stats.hydroculusNumber),
                    _statItem("火神瞳", stats.pyroculusNumber),
                    _statItem("珍贵宝箱", stats.preciousChestNumber),
                    _statItem("华丽宝箱", stats.luxuriousChestNumber),
                    _statItem("精致宝箱", stats.exquisiteChestNumber),
                    _statItem("普通宝箱", stats.commonChestNumber),
                    _statItem("奇馈宝箱", stats.magicChestNumber),
                    _statItem("满好感角色数", stats.fullFetterAvatarNum),
                    _statItem("困难挑战", stats.hardChallengeName),
                    _statItem("挑战难度", stats.hardChallengeDifficulty),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          const Text("角色列表:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: avatars.length,
            itemBuilder: (context, idx) {
              final avatar = avatars[idx];
              return Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: avatar["image"] != null ? NetworkImage(avatar["image"]) : null,
                      radius: 32,
                      child: avatar["image"] == null ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(height: 8),
                    Text(avatar["name"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("等级: "+(avatar["level"]?.toString() ?? "-")),
                    Text("元素: "+(avatar["element"] ?? "-")),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text("世界探索:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Column(
            children: worldExplorations.map<Widget>((exp) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (exp.icon.isNotEmpty)
                            CircleAvatar(backgroundImage: NetworkImage(exp.icon), radius: 22),
                          if (exp.icon.isEmpty && exp.cover.isNotEmpty)
                            CircleAvatar(backgroundImage: NetworkImage(exp.cover), radius: 22),
                          if (exp.icon.isEmpty && exp.cover.isEmpty)
                            const CircleAvatar(child: Icon(Icons.landscape)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(exp.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          Text("探索度: ${exp.explorationPercentage / 10}%", style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      if (exp.backgroundImage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              exp.backgroundImage,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      if (exp.natanReputation != null && exp.natanReputation!.tribalList.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("声望部族：", style: TextStyle(fontWeight: FontWeight.bold)),
                              Wrap(
                                spacing: 8,
                                children: exp.natanReputation!.tribalList.map<Widget>((tribe) => Column(
                                  children: [
                                    if (tribe.icon.isNotEmpty)
                                      CircleAvatar(backgroundImage: NetworkImage(tribe.icon), radius: 16),
                                    if (tribe.icon.isEmpty)
                                      const CircleAvatar(child: Icon(Icons.group)),
                                    Text(tribe.name, style: const TextStyle(fontSize: 13)),
                                    Text("等级: ${tribe.level}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      if (exp.areaExplorationList.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Wrap(
                            spacing: 8,
                            children: exp.areaExplorationList.map<Widget>((area) {
                              final name = area['name'] ?? '';
                              final percent = area['exploration_percentage'] ?? 0;
                              return Chip(label: Text("$name ${percent / 10}%"));
                            }).toList(),
                          ),
                        ),
                      if (exp.bossList.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Wrap(
                            spacing: 8,
                            children: exp.bossList.map<Widget>((boss) {
                              final name = boss['name'] ?? '';
                              final killNum = boss['kill_num'] ?? 0;
                              return Chip(label: Text("$name 击杀:$killNum"));
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, Object value) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// 世界探索相关数据类
class NatanReputationTribe {
  final String icon;
  final String image;
  final String name;
  final int id;
  final int level;
  NatanReputationTribe({
    required this.icon,
    required this.image,
    required this.name,
    required this.id,
    required this.level,
  });
  factory NatanReputationTribe.fromJson(Map<String, dynamic> json) {
    return NatanReputationTribe(
      icon: json['icon'] ?? '',
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      id: json['id'] ?? 0,
      level: json['level'] ?? 0,
    );
  }
}

class NatanReputation {
  final List<NatanReputationTribe> tribalList;
  NatanReputation({required this.tribalList});
  factory NatanReputation.fromJson(Map<String, dynamic> json) {
    final list = (json['tribal_list'] as List?) ?? [];
    return NatanReputation(
      tribalList: list.map((e) => NatanReputationTribe.fromJson(e)).toList(),
    );
  }
}

class WorldExploration {
  final int level;
  final int explorationPercentage;
  final String icon;
  final String name;
  final String type;
  final List offerings;
  final int id;
  final int parentId;
  final String mapUrl;
  final String strategyUrl;
  final String backgroundImage;
  final String innerIcon;
  final String cover;
  final List areaExplorationList;
  final List bossList;
  final bool isHot;
  final bool indexActive;
  final bool detailActive;
  final int sevenStatueLevel;
  final NatanReputation? natanReputation;
  final int worldType;

  WorldExploration({
    required this.level,
    required this.explorationPercentage,
    required this.icon,
    required this.name,
    required this.type,
    required this.offerings,
    required this.id,
    required this.parentId,
    required this.mapUrl,
    required this.strategyUrl,
    required this.backgroundImage,
    required this.innerIcon,
    required this.cover,
    required this.areaExplorationList,
    required this.bossList,
    required this.isHot,
    required this.indexActive,
    required this.detailActive,
    required this.sevenStatueLevel,
    required this.natanReputation,
    required this.worldType,
  });

  factory WorldExploration.fromJson(Map<String, dynamic> json) {
    return WorldExploration(
      level: json['level'] ?? 0,
      explorationPercentage: json['exploration_percentage'] ?? 0,
      icon: json['icon'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      offerings: json['offerings'] ?? [],
      id: json['id'] ?? 0,
      parentId: json['parent_id'] ?? 0,
      mapUrl: json['map_url'] ?? '',
      strategyUrl: json['strategy_url'] ?? '',
      backgroundImage: json['background_image'] ?? '',
      innerIcon: json['inner_icon'] ?? '',
      cover: json['cover'] ?? '',
      areaExplorationList: json['area_exploration_list'] ?? [],
      bossList: json['boss_list'] ?? [],
      isHot: json['is_hot'] ?? false,
      indexActive: json['index_active'] ?? false,
      detailActive: json['detail_active'] ?? false,
      sevenStatueLevel: json['seven_statue_level'] ?? 0,
      natanReputation: json['natan_reputation'] != null ? NatanReputation.fromJson(json['natan_reputation']) : null,
      worldType: json['world_type'] ?? 0,
    );
  }
}
