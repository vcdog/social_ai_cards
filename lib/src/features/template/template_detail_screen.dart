import 'package:flutter/material.dart';
import '../../services/unsplash_service.dart';

class TemplateDetailScreen extends StatefulWidget {
  final Map<String, String> templateData;

  const TemplateDetailScreen({
    Key? key,
    required this.templateData,
  }) : super(key: key);

  @override
  State<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends State<TemplateDetailScreen> {
  final UnsplashService _unsplashService = UnsplashService();
  String? _hdImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHdImage();
  }

  Future<void> _loadHdImage() async {
    try {
      // 从小图URL中提取图片ID
      final originalUrl = widget.templateData['url'] ?? '';
      final hdUrl = await _unsplashService.getHdImageUrl(originalUrl);

      if (mounted) {
        setState(() {
          _hdImageUrl = hdUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载高清图片失败')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.templateData['name'] ?? '模板详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 实现分享功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: 实现收藏功能
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 高清图片展示
                  AspectRatio(
                    aspectRatio: 1,
                    child: Hero(
                      tag: 'template_${widget.templateData['url']}',
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _hdImageUrl ?? widget.templateData['url']!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 模板信息
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.templateData['name'] ?? '未命名模板',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        // 操作按钮
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text('立即使用'),
                                onPressed: () {
                                  // TODO: 跳转到编辑页面
                                },
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
}
