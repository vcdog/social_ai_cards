import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/unsplash_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final UnsplashService _unsplashService = UnsplashService();
  List<String> _welcomeImages = [];
  bool _isLoading = true;

  final List<Map<String, String>> _pages = [
    {
      'title': '欢迎使用AI社交卡片',
      'description': '让创作变得简单有趣',
      'searchTerm': 'social media creative',
    },
    {
      'title': '智能模板',
      'description': '海量精美模板，一键生成专业设计',
      'searchTerm': 'design template',
    },
    {
      'title': 'AI助手',
      'description': '智能推荐，让创作更轻松',
      'searchTerm': 'artificial intelligence creative',
    },
    {
      'title': '即刻开始',
      'description': '开启你的创作之旅',
      'searchTerm': 'start journey creative',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadWelcomeImages();
  }

  Future<void> _loadWelcomeImages() async {
    try {
      List<String> allImages = [];
      for (var page in _pages) {
        final images = await _unsplashService.getImagesByCategory(page['searchTerm']!);
        if (images.isNotEmpty) {
          allImages.add(images.first); // 每个类别取第一张图片
        }
      }
      
      setState(() {
        _welcomeImages = allImages;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading welcome images: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 轮播内容
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(
                title: _pages[index]['title']!,
                description: _pages[index]['description']!,
                imageUrl: _welcomeImages.length > index ? _welcomeImages[index] : null,
              );
            },
          ),

          // 底部指示器和按钮
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // 页面指示器
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildDotIndicator(index),
                  ),
                ),
                const SizedBox(height: 32),
                // 按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 跳过按钮
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: () => _onSkip(context),
                          child: const Text('跳过'),
                        ),
                      const Spacer(),
                      // 下一步/开始按钮
                      FilledButton(
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _onStart(context);
                          }
                        },
                        child: Text(
                          _currentPage < _pages.length - 1 ? '下一步' : '开始使用',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    String? imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图片区域
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : imageUrl != null
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
                    : Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
          ),
          const SizedBox(height: 48),
          // 标题
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 描述
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade300,
      ),
    );
  }

  void _onSkip(BuildContext context) {
    context.go('/');
  }

  void _onStart(BuildContext context) {
    context.go('/');
  }
}
