import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import '../../services/unsplash_service.dart';
import '../../services/template_naming_service.dart';
import '../../common/theme/app_theme.dart';

class WorksScreen extends StatefulWidget {
  const WorksScreen({Key? key}) : super(key: key);

  @override
  State<WorksScreen> createState() => _WorksScreenState();
}

class _WorksScreenState extends State<WorksScreen> {
  final UnsplashService _unsplashService = UnsplashService();
  bool _isSelectionMode = false;
  final Set<int> _selectedItems = <int>{};
  List<Map<String, String>> _workItems = [];
  bool _isLoading = true;
  String _selectedFilter = '全部';
  final List<String> _filters = ['全部', '最近', '收藏', '已分享'];

  final List<String> _categories = [
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
  ];

  @override
  void initState() {
    super.initState();
    _loadWorkImages();
  }

  Future<void> _loadWorkImages() async {
    try {
      List<Map<String, String>> items = [];
      final random = math.Random();

      for (int i = 0; i < 10; i++) {
        final category = _categories[random.nextInt(_categories.length)];
        final searchTerm =
            _unsplashService.convertCategoryToSearchTerm(category);

        final images = await _unsplashService.getImagesByCategory(
          searchTerm,
          size: 'small',
          perPage: 1,
          page: random.nextInt(5) + 1,
        );

        if (images.isNotEmpty) {
          items.add({
            'url': images.first,
            'title': TemplateNamingService.generateName(category),
            'category': category,
            'date': '2024-03-${10 + i}',
          });
        }
      }

      setState(() {
        _workItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading work images: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的作品'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: 实现更多操作菜单
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 搜索栏
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchBar(
                hintText: '搜索作品',
                leading: const Icon(Icons.search),
                onTap: () {
                  // TODO: 实现搜索功能
                },
              ),
            ),
          ),

          // 筛选条件
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children:
                    _filters.map((filter) => _buildFilterChip(filter)).toList(),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 16)),

          // 作品网格
          SliverLayoutBuilder(
            builder: (BuildContext context, SliverConstraints constraints) {
              final double screenWidth = constraints.crossAxisExtent;
              final int crossAxisCount =
                  math.max(3, (screenWidth / 150).floor());

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildWorkCard(_workItems[index]),
                  childCount: _workItems.length,
                ),
              );
            },
          ),

          // 加载状态指示器
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = filter;
            // TODO: 根据筛选条件加载作品
          });
        },
      ),
    );
  }

  Widget _buildWorkCard(Map<String, String> workItem) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 作品图片
          Image.network(
            workItem['url']!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: CircularProgressIndicator());
            },
          ),

          // 渐变遮罩
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
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
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    workItem['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '创建于 ${workItem['date']}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                    ),
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
              mainAxisSize: MainAxisSize.min,
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
