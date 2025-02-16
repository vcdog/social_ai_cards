import 'package:flutter/material.dart';
import '../../services/unsplash_service.dart';
import 'package:go_router/go_router.dart';

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
        const Text(
          '快捷功能',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildQuickActionItem(
              icon: Icons.add_circle_outline,
              label: '新建卡片',
              onTap: () {
                context.push('/create');
              },
            ),
            _buildQuickActionItem(
              icon: Icons.folder_open_outlined,
              label: '导入模板',
              onTap: () {
                // TODO: 实现导入功能
              },
            ),
            _buildQuickActionItem(
              icon: Icons.history,
              label: '最近使用',
              onTap: () {
                // TODO: 显示最近记录
              },
            ),
            _buildQuickActionItem(
              icon: Icons.lightbulb_outline,
              label: '获取灵感',
              onTap: () {
                // TODO: 显示灵感内容
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: constraints.maxHeight * 0.6,
                  child: Center(
                    child: Icon(
                      icon,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(
                  height: constraints.maxHeight * 0.4,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTemplateShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '推荐模板',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendedTemplates.isEmpty
                ? 5
                : _recommendedTemplates.length,
            itemBuilder: (context, index) {
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: _recommendedTemplates.isEmpty
                    ? Center(child: Text('模板 ${index + 1}'))
                    : Image.network(
                        _recommendedTemplates[index],
                        fit: BoxFit.cover,
                      ),
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
        const Text(
          '创作灵感',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _inspirationImages.isEmpty ? 4 : _inspirationImages.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: _inspirationImages.isEmpty
                  ? Center(child: Text('灵感 ${index + 1}'))
                  : Image.network(
                      _inspirationImages[index],
                      fit: BoxFit.cover,
                    ),
            );
          },
        ),
      ],
    );
  }
}
