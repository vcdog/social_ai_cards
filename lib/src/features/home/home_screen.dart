import 'package:flutter/material.dart';
import '../../services/unsplash_service.dart';
import 'package:go_router/go_router.dart';
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
  List<String> _recommendedTemplates = [];
  List<String> _inspirationImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final templates = await _unsplashService.getImagesByCategory('热门');
      final inspirations = await _unsplashService.getImagesByCategory('创意');

      setState(() {
        _recommendedTemplates = templates;
        _inspirationImages = inspirations;
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildTemplateShowcase(),
                const SizedBox(height: 24),
                _buildInspirationSection(),
              ],
            ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppAssets.spacing.xs),
          child: Text(
            '快捷功能',
            style: TextStyle(
              fontSize: AppAssets.fontSize.title,
              fontWeight: FontWeight.bold,
              color: AppAssets.colors.text,
            ),
          ),
        ),
        SizedBox(height: AppAssets.spacing.md),
        Container(
          padding: EdgeInsets.all(AppAssets.spacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppAssets.radius.card),
            boxShadow: AppAssets.shadows.card,
            gradient: LinearGradient(
              colors: AppAssets.gradients.primary,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: AppAssets.spacing.md,
            crossAxisSpacing: AppAssets.spacing.md,
            children: [
              ShortcutButton(
                icon: Icons.add_circle_outline,
                label: '新建卡片',
                onTap: () => context.push('/create'),
                isActive: true,
              ),
              ShortcutButton(
                icon: Icons.folder_open_outlined,
                label: '导入模板',
                onTap: () {
                  // TODO: 实现导入功能
                },
              ),
              ShortcutButton(
                icon: Icons.history,
                label: '最近使用',
                onTap: () {
                  // TODO: 显示最近记录
                },
              ),
              ShortcutButton(
                icon: Icons.lightbulb_outline,
                label: '获取灵感',
                onTap: () {
                  // TODO: 显示灵感内容
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppAssets.spacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '推荐模板',
                style: TextStyle(
                  fontSize: AppAssets.fontSize.title,
                  fontWeight: FontWeight.bold,
                  color: AppAssets.colors.text,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push('/templates');
                },
                child: Row(
                  children: [
                    Text(
                      '查看全部',
                      style: TextStyle(
                        fontSize: AppAssets.fontSize.sm,
                        color: AppAssets.colors.primary,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppAssets.colors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppAssets.spacing.md),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppAssets.spacing.md),
            itemCount: _recommendedTemplates.isEmpty
                ? 5
                : _recommendedTemplates.length,
            itemBuilder: (context, index) {
              final imageUrl = _recommendedTemplates.isEmpty
                  ? null
                  : _recommendedTemplates[index];
              return TemplateCard(
                imageUrl: imageUrl,
                title: '精选模板 ${index + 1}',
                description: '这是一个精美的社交分享模板，点击立即使用',
                onTap: () {
                  // TODO: 跳转到模板详情页
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInspirationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppAssets.spacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '创作灵感',
                style: TextStyle(
                  fontSize: AppAssets.fontSize.title,
                  fontWeight: FontWeight.bold,
                  color: AppAssets.colors.text,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 跳转到灵感页面
                },
                child: Row(
                  children: [
                    Text(
                      '更多灵感',
                      style: TextStyle(
                        fontSize: AppAssets.fontSize.sm,
                        color: AppAssets.colors.primary,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppAssets.colors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppAssets.spacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppAssets.spacing.md),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppAssets.spacing.md,
            crossAxisSpacing: AppAssets.spacing.md,
            childAspectRatio: 1.2,
          ),
          itemCount: _inspirationImages.isEmpty ? 4 : _inspirationImages.length,
          itemBuilder: (context, index) {
            final imageUrl =
                _inspirationImages.isEmpty ? null : _inspirationImages[index];
            return InspirationCard(
              imageUrl: imageUrl,
              title: '创意灵感 ${index + 1}',
              onTap: () {
                // TODO: 跳转到灵感详情页
              },
              isNew: index == 0, // 第一个显示NEW标签
            );
          },
        ),
      ],
    );
  }
}
