import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import '../../services/unsplash_service.dart';
import '../../services/template_naming_service.dart';
import '../../common/theme/app_theme.dart';
import '../../common/constants/assets.dart';
import 'widgets/shortcut_button.dart';
import 'widgets/template_card.dart';
import 'widgets/inspiration_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UnsplashService _unsplashService = UnsplashService();
  List<Map<String, String>> _recommendedTemplates = [];
  List<Map<String, String>> _inspirationImages = [];
  bool _isLoading = true;

  // 定义快捷功能项
  final List<Map<String, dynamic>> _shortcutItems = [
    {
      'icon': Icons.add_photo_alternate_rounded,
      'label': '创建卡片',
      'color': const Color(0xFF4A90E2),
      'route': '/create',
    },
    {
      'icon': Icons.style_rounded,
      'label': '浏览模板',
      'color': const Color(0xFF50C878),
      'route': '/templates',
    },
    {
      'icon': Icons.lightbulb_rounded,
      'label': '获取灵感',
      'color': const Color(0xFFFFA726),
      'route': '/inspiration',
    },
    {
      'icon': Icons.favorite_rounded,
      'label': '我的收藏',
      'color': const Color(0xFFE57373),
      'route': '/favorites',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      setState(() => _isLoading = true);
      
      // 加载推荐模板
      final templates = await _unsplashService.getImagesByCategory(
        '热门',
        size: 'small',
        perPage: 6,
      );
      
      // 加载创意灵感
      final inspirations = await _unsplashService.getImagesByCategory(
        '创意',
        size: 'small',
        perPage: 6,
      );
      
      if (!mounted) return;
      
      setState(() {
        _recommendedTemplates = templates.map((url) => {
          'url': url,
          'name': TemplateNamingService.generateName('照片'),
        }).toList();
        
        _inspirationImages = inspirations.map((url) => {
          'url': url,
          'name': TemplateNamingService.generateName('创意'),
        }).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading images: $e');
      
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _recommendedTemplates = [];
        _inspirationImages = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HomeScreen build called, isLoading: $_isLoading');
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI社交卡片'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _buildContent(),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // 快捷功能区域
        SliverToBoxAdapter(
          child: _buildShortcutsSection(),
        ),

        // 推荐模板区域
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSectionHeader(
                  '推荐模板',
                  '查看全部',
                  onTap: () => context.push('/templates'),
                ),
                const SizedBox(height: 16),
                _buildAdaptiveGrid(_recommendedTemplates),
              ],
            ),
          ),
        ),

        // 创意灵感区域
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSectionHeader(
                  '创意灵感',
                  '更多灵感',
                  onTap: () => context.push('/inspiration'),
                ),
                const SizedBox(height: 16),
                _buildAdaptiveGrid(_inspirationImages),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 构建快捷功能区
  Widget _buildShortcutsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 添加回标题
          const Text(
            '快捷功能',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // 快捷功能图标行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                _shortcutItems.map((item) => _buildShortcutItem(item)).toList(),
          ),
        ],
      ),
    );
  }

  // 修改快捷功能项的点击处理
  Widget _buildShortcutItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => context.push(item['route']), // 使用 go_router 进行导航
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: item['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: item['color'].withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              // 添加 Material widget 以支持水波纹效果
              color: Colors.transparent,
              child: Stack(
                children: [
                  // 背景装饰
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      item['icon'],
                      size: 40,
                      color: item['color'].withOpacity(0.2),
                    ),
                  ),
                  // 主图标
                  Center(
                    child: Icon(
                      item['icon'],
                      size: 28,
                      color: item['color'],
                    ),
                  ),
                  // 添加水波纹效果
                  Positioned.fill(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push(item['route']),
                      splashColor: item['color'].withOpacity(0.3),
                      highlightColor: item['color'].withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item['label'],
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action,
      {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Row(
            children: [
              Text(action),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptiveGrid(List<Map<String, String>> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final int crossAxisCount = math.max(3, (screenWidth / 150).floor());
        final double itemWidth =
            (screenWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildImageCard(item);
          },
        );
      },
    );
  }

  Widget _buildImageCard(Map<String, String> imageData) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 图片
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageData['url']!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // 渐变遮罩
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    imageData['name'] ?? '未命名',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // 操作按钮
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _buildActionButton(Icons.favorite_border),
                const SizedBox(width: 8),
                _buildActionButton(Icons.share),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
