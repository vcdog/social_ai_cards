import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import '../../services/unsplash_service.dart';
import '../../services/template_naming_service.dart';
import '../../models/template_model.dart';
import '../../common/constants/assets.dart';
import '../../features/template/template_detail_screen.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({Key? key}) : super(key: key);

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  final UnsplashService _unsplashService = UnsplashService();
  String _selectedCategory = '全部';
  Map<String, List<Map<String, String>>> _categoryImages = {};
  bool _isLoading = false;

  // 分类列表
  final List<String> _categories = [
    '全部',
    '照片',
    '插画',
    '壁纸',
    '自然',
    '3D',
    '纹理',
    '建筑',
    '旅行',
    '电影',
    '街拍',
    '人物',
    '动物',
    '其他',
  ];

  // 添加分页相关变量
  final Map<String, int> _currentPage = {};
  final Map<String, bool> _hasMore = {};
  static const int _perPage = 30; // 每页加载30张图片

  // 添加滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadImagesForCategory('壁纸');

    // 添加滚动监听
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动监听处理
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreImages();
    }
  }

  // 加载更多图片
  Future<void> _loadMoreImages() async {
    if (_isLoading || _selectedCategory == '全部') return;
    if (!(_hasMore[_selectedCategory] ?? true)) return;

    await _loadImagesForCategory(_selectedCategory, loadMore: true);
  }

  Future<void> _loadImagesForCategory(String category,
      {bool loadMore = false}) async {
    if (category == '全部') return;
    if (_isLoading) return;
    if (!loadMore && _categoryImages.containsKey(category)) return;

    setState(() => _isLoading = true);

    try {
      final searchTerm = _unsplashService.convertCategoryToSearchTerm(category);
      final currentPage = loadMore ? (_currentPage[category] ?? 1) + 1 : 1;

      final images = await _unsplashService.getImagesByCategory(
        searchTerm,
        size: 'small', // 使用小尺寸图片
        page: currentPage,
        perPage: _perPage,
      );

      if (images.isEmpty) {
        _hasMore[category] = false;
      } else {
        final namedImages = images
            .map((url) => {
                  'url': url,
                  'name': TemplateNamingService.generateName(category),
                })
            .toList();

        setState(() {
          if (loadMore) {
            _categoryImages[category]!.addAll(namedImages);
          } else {
            _categoryImages[category] = namedImages;
          }
          _currentPage[category] = currentPage;
        });
      }
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
        controller: _scrollController,
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

          // 分类选择器
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: _categories
                    .map((category) => _buildCategoryChip(category))
                    .toList(),
              ),
            ),
          ),

          // 模板网格 - 使用 SliverGrid 的新构建方式
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverLayoutBuilder(
              builder: (BuildContext context, SliverConstraints constraints) {
                // 计算每行可以显示的图片数量（最少3个）
                final double screenWidth = constraints.crossAxisExtent;
                final int crossAxisCount =
                    math.max(3, (screenWidth / 150).floor());

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1, // 正方形
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final images = _selectedCategory == '全部'
                          ? _categoryImages.values
                              .expand((images) => images)
                              .toList()
                          : _categoryImages[_selectedCategory] ?? [];

                      if (index >= images.length) {
                        if (_isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return null;
                      }

                      final imageData = images[index];
                      return _buildTemplateCard(imageData);
                    },
                    childCount: (_selectedCategory == '全部'
                            ? _categoryImages.values
                                .expand((images) => images)
                                .length
                            : (_categoryImages[_selectedCategory]?.length ??
                                0)) +
                        (_isLoading ? crossAxisCount : 0),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, String> imageData) {
    return InkWell(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => TemplateDetailScreen(
              templateData: imageData,
            ),
          ),
        );
      },
      child: Hero(
        tag: 'template_${imageData['url']}',
        child: Container(
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
                        imageData['name'] ?? '未命名模板',
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
        ),
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

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedCategory = category;
            _loadImagesForCategory(category);
          });
        },
      ),
    );
  }
}
