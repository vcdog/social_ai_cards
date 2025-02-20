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

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final templates = await _unsplashService.getImagesByCategory(
        '热门',
        size: 'small', // 使用小尺寸图片
        perPage: 6, // 限制加载数量
      );
      final inspirations = await _unsplashService.getImagesByCategory(
        '创意',
        size: 'small',
        perPage: 6,
      );

      setState(() {
        _recommendedTemplates = templates
            .map((url) => {
                  'url': url,
                  'name': TemplateNamingService.generateName('照片'),
                })
            .toList();
        _inspirationImages = inspirations
            .map((url) => {
                  'url': url,
                  'name': TemplateNamingService.generateName('创意'),
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading images: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const Text('AI社交卡片'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 跳转到设置页面
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 快捷功能区域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '快捷功能',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ShortcutButton(
                        icon: Icons.add_photo_alternate,
                        label: '创建卡片',
                        onTap: () => context.push('/create'),
                      ),
                      ShortcutButton(
                        icon: Icons.style,
                        label: '浏览模板',
                        onTap: () => context.push('/templates'),
                      ),
                      ShortcutButton(
                        icon: Icons.lightbulb_outline,
                        label: '获取灵感',
                        onTap: () => context.push('/inspiration'),
                      ),
                      ShortcutButton(
                        icon: Icons.favorite,
                        label: '我的收藏',
                        onTap: () => context.push('/favorites'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
