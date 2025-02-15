import 'package:flutter/material.dart';
import '../../services/unsplash_service.dart';
import '../../models/template_model.dart';

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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: 跳转到模板详情页
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 模板预览图
            Expanded(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image_outlined),
                      ),
                    ),
            ),
            // 模板信息
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '模板 ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${1000 + index}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.remove_red_eye_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${5000 + index}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
