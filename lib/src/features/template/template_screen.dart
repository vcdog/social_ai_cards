import 'package:flutter/material.dart';
import '../../services/unsplash_service.dart';
import '../../models/template_model.dart';
import '../../common/constants/assets.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({Key? key}) : super(key: key);

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  final UnsplashService _unsplashService = UnsplashService();
  String _selectedCategory = '全部';
  Map<String, List<String>> _categoryImages = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImagesForCategory('热门'); // 默认加载热门分类
  }

  Future<void> _loadImagesForCategory(String category) async {
    if (category == '全部' || _categoryImages.containsKey(category)) return;

    setState(() => _isLoading = true);

    try {
      final images = await _unsplashService.getImagesByCategory(category);
      setState(() {
        _categoryImages[category] = images;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('模板'),
      ),
      body: CustomScrollView(
        slivers: [
          // 搜索栏
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchBar(
                hintText: '搜索模板',
                leading: const Icon(Icons.search),
                onTap: () {
                  // TODO: 实现搜索功能
                },
              ),
            ),
          ),

          // 分类标签
          SliverToBoxAdapter(
            child: _buildCategoryTabs(),
          ),

          // 模板网格
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: _isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTemplateItem(index),
                      childCount: _getTemplateCount(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['全部', '热门', '节日', '商务', '社交', '生活', '创意', '其他'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                  _loadImagesForCategory(category);
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTemplateItem(int index) {
    final images = _getImagesForCurrentCategory();
    final imageUrl = images.isNotEmpty ? images[index % images.length] : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppAssets.radius.lg),
        boxShadow: AppAssets.shadows.light,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppAssets.radius.lg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图片
            _buildTemplateImage(imageUrl),

            // 渐变遮罩
            _buildGradientOverlay(),

            // 模板信息
            _buildTemplateInfo(index),

            // 悬浮操作按钮
            _buildFloatingActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateImage(String? imageUrl) {
    return AnimatedSwitcher(
      duration: AppAssets.animationDuration,
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              key: ValueKey(imageUrl),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            )
          : Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image, size: 32),
            ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateInfo(int index) {
    return Positioned(
      left: AppAssets.spacing.md,
      right: AppAssets.spacing.md,
      bottom: AppAssets.spacing.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '模板 ${index + 1}',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppAssets.fontSize.lg,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppAssets.spacing.xs),
          Text(
            '点击使用该模板',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: AppAssets.fontSize.xs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Positioned(
      top: AppAssets.spacing.sm,
      right: AppAssets.spacing.sm,
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.favorite_border,
            onTap: () {
              // TODO: 收藏模板
            },
          ),
          SizedBox(width: AppAssets.spacing.xs),
          _buildActionButton(
            icon: Icons.share_outlined,
            onTap: () {
              // TODO: 分享模板
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(AppAssets.radius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppAssets.radius.sm),
        child: Container(
          padding: EdgeInsets.all(AppAssets.spacing.xs),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  List<String> _getImagesForCurrentCategory() {
    if (_selectedCategory == '全部') {
      return _categoryImages.values.expand((images) => images).toList();
    }
    return _categoryImages[_selectedCategory] ?? [];
  }

  int _getTemplateCount() {
    final images = _getImagesForCurrentCategory();
    return images.isEmpty ? 10 : images.length;
  }
}
