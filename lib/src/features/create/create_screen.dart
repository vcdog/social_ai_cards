import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import '../../services/unsplash_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/template_naming_service.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen>
    with SingleTickerProviderStateMixin {
  // 当前选中的编辑模式
  String _currentMode = 'template'; // template, edit, preview
  final UnsplashService _unsplashService = UnsplashService();
  String? _selectedBackgroundImage; // 添加选中的背景图片变量
  String _selectedCategory = '全部'; // 修改默认选中分类为"全部"

  // 分页和加载相关变量
  final Map<String, List<Map<String, String>>> _templateImages = {};
  final Map<String, int> _currentPage = {};
  final Map<String, bool> _hasMore = {};
  final Map<String, bool> _isLoadingMore = {}; // 只保留这一个 _isLoadingMore 声明
  static const int _perPage = 10;

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();
  late TextEditingController _textController;
  late AnimationController _toolbarAnimController;
  late Animation<double> _arrowRotationAnimation;

  // 修改模板分类列表
  final List<Map<String, String>> _templates = [
    {'category': '全部', 'searchTerm': 'creative templates'},
    {'category': '照片', 'searchTerm': 'photos'},
    {'category': '插画', 'searchTerm': 'illustrations'},
    {'category': '壁纸', 'searchTerm': 'wallpapers'},
    {'category': '自然', 'searchTerm': 'nature'},
    {'category': '3D', 'searchTerm': '3d renders'},
    {'category': '纹理', 'searchTerm': 'textures'},
    {'category': '建筑', 'searchTerm': 'architecture & interiors'},
    {'category': '旅行', 'searchTerm': 'travel'},
    {'category': '电影', 'searchTerm': 'film'},
    {'category': '街拍', 'searchTerm': 'street photography'},
    {'category': '人物', 'searchTerm': 'people'},
    {'category': '动物', 'searchTerm': 'animals'},
    {'category': '其他', 'searchTerm': 'miscellaneous'},
  ];

  // 添加文本编辑相关变量
  bool _isEditing = false;
  String _editingText = '在此处添加文本';
  double _fontSize = 16.0; // 用这个作为字体大小的控制变量
  Color _textColor = Colors.black87;
  TextAlign _textAlign = TextAlign.center; // 添加文本对齐方式变量

  // 添加工具栏展开状态控制
  bool _isToolbarExpanded = false;
  late Animation<double> _toolbarSlideAnimation;

  // 添加工具栏选中项状态
  String? _selectedToolbarItem; // 当前选中的工具栏项

  // 修改渐变色列表，完善第二页的深色系颜色
  final List<List<Color>> _gradientColors = [
    // 第一页 - 浅色系
    [Colors.blue.shade200, Colors.lightBlue.shade200],
    [Colors.blue.shade300, Colors.lightBlue.shade300],
    [Colors.green.shade200, Colors.lightGreen.shade200],
    [Colors.pink.shade100, Colors.blue.shade100],
    [Colors.purple.shade200, Colors.blue.shade200],
    [Colors.white, Colors.grey.shade100],
    [Colors.purple.shade100, Colors.pink.shade100],
    [Colors.pink.shade200, Colors.red.shade100],
    [Colors.pink.shade300, Colors.purple.shade200],
    [Colors.orange.shade100, Colors.yellow.shade100],
    [Colors.yellow.shade200, Colors.yellow.shade100],
    [Colors.purple.shade100, Colors.blue.shade100],
    [Colors.yellow.shade300, Colors.yellow.shade200],
    [Colors.green.shade200, Colors.lightGreen.shade100],
    [Colors.blue.shade100, Colors.lightBlue.shade100],
    [Colors.pink.shade100, Colors.purple.shade100],
    // 第二页 - 深色系（修复后的设计）
    [const Color(0xFF000428), const Color(0xFF004e92)], // Midnight City
    [const Color(0xFF1a0f0f), const Color(0xFF6a0000)], // Deep Red
    [const Color(0xFF0f2027), const Color(0xFF203a43)], // Deep Ocean
    [const Color(0xFF000046), const Color(0xFF1CB5E0)], // Ocean Night
    [const Color(0xFF16222A), const Color(0xFF3A6073)], // Steel Gray
    [const Color(0xFF1F1C2C), const Color(0xFF928DAB)], // Midnight Purple
    [const Color(0xFF141E30), const Color(0xFF243B55)], // Royal Blue
    [const Color(0xFF232526), const Color(0xFF414345)], // Coal
    [const Color(0xFF000000), const Color(0xFF434343)], // Black Elegance
    [const Color(0xFF1e130c), const Color(0xFF9a8478)], // Coffee
    [const Color(0xFF29323c), const Color(0xFF485563)], // Slate
    [const Color(0xFF093028), const Color(0xFF237A57)], // Forest
    [const Color(0xFF2C5364), const Color(0xFF203A43)], // Deep Sea
    [const Color(0xFF2C3E50), const Color(0xFF3498DB)], // Midnight Blue
    [const Color(0xFF4B1248), const Color(0xFFF02FC2)], // Dark Purple
    [const Color(0xFF0A2E38), const Color(0xFF00F0B5)], // Aurora Borealis
  ];

  // 添加当前选中的渐变色索引
  int _selectedGradientIndex = -1;
  // 添加当前颜色选择器页码
  int _currentColorPage = 0;

  // 添加透明度控制变量
  double _templateOpacity = 1.0;

  // 添加模板选择器显示状态
  bool _showTemplateSelector = false;

  // 添加文字选择器状态
  bool _showTextEditor = false;

  // 修改字体列表，使用正确的 Google Fonts 方法
  final List<Map<String, dynamic>> _fontFamilies = [
    {'name': '默认', 'textStyle': null},
    {
      'name': '思源黑体',
      'textStyle': GoogleFonts.notoSans(),
    },
    {
      'name': '思源宋体',
      'textStyle': GoogleFonts.notoSerif(),
    },
    {
      'name': 'ZCOOL楷体',
      'textStyle': GoogleFonts.zcoolKuaiLe(),
    },
    {
      'name': 'ZCOOL圆体',
      'textStyle': GoogleFonts.zcoolXiaoWei(),
    },
    {
      'name': '马善政',
      'textStyle': GoogleFonts.maShanZheng(),
    },
    {
      'name': '霞鹜文楷',
      'textStyle': GoogleFonts.longCang(),
    },
  ];
  TextStyle? _selectedFontStyle;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _toolbarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 初始化箭头旋转动画
    _arrowRotationAnimation = Tween<double>(
      begin: 0,
      end: math.pi,
    ).animate(CurvedAnimation(
      parent: _toolbarAnimController,
      curve: Curves.easeInOut,
    ));

    // 添加滚动监听
    _scrollController.addListener(_onScroll);

    // 初始加载图片
    _loadTemplateImages(_selectedCategory);
  }

  @override
  void dispose() {
    _textController.dispose();
    _toolbarAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动监听处理
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreImages();
    }
  }

  // 加载更多图片
  Future<void> _loadMoreImages() async {
    final category = _selectedCategory;
    if (!(_isLoadingMore[category] ?? false)) {
      setState(() {
        _isLoadingMore[category] = true;
      });
      await _loadTemplateImages(category, loadMore: true);
      setState(() {
        _isLoadingMore[category] = false;
      });
    }
  }

  // 加载模板图片
  Future<void> _loadTemplateImages(String category,
      {bool loadMore = false}) async {
    try {
      if (_isLoadingMore[category] ?? false) return;

      final currentPage = loadMore ? (_currentPage[category] ?? 1) + 1 : 1;

      List<String> images;
      if (category == '全部') {
        images = await _unsplashService.getImagesByCategory(
          'creative templates',
          size: 'small',
          page: currentPage,
          perPage: _perPage,
        );
      } else {
        final searchTerm = _templates
            .firstWhere((t) => t['category'] == category)['searchTerm']!;
        images = await _unsplashService.getImagesByCategory(
          searchTerm,
          size: 'small',
          page: currentPage,
          perPage: _perPage,
        );
      }

      if (images.isNotEmpty) {
        setState(() {
          if (!loadMore) {
            _templateImages[category] = [];
          }
          final namedImages = images
              .map((url) => {
                    'url': url,
                    'name': TemplateNamingService.generateName(category),
                  })
              .toList();

          _templateImages[category] ??= [];
          _templateImages[category]!.addAll(namedImages);
          _currentPage[category] = currentPage;
        });
      }
    } catch (e) {
      print('Error loading template images: $e');
    } finally {
      setState(() {
        _isLoadingMore[category] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建卡片'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // 预览按钮
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            onPressed: () {
              setState(() {
                _currentMode = 'preview';
              });
            },
          ),
          // 保存按钮
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              // TODO: 实现保存功能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部模式切换
          _buildModeSwitch(),

          // 主要内容区域
          Expanded(
            child: _buildMainContent(),
          ),

          // 底部工具栏
          if (_currentMode == 'edit') _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'template',
            icon: Icon(Icons.dashboard_outlined),
            label: Text('模板'),
          ),
          ButtonSegment(
            value: 'edit',
            icon: Icon(Icons.edit_outlined),
            label: Text('编辑'),
          ),
          ButtonSegment(
            value: 'preview',
            icon: Icon(Icons.remove_red_eye_outlined),
            label: Text('预览'),
          ),
        ],
        selected: {_currentMode},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            // 如果正在编辑，先保存当前编辑的内容
            if (_isEditing) {
              _editingText = _textController.text.isEmpty
                  ? '在此处添加文本'
                  : _textController.text;
              _isEditing = false;
            }
            _currentMode = newSelection.first;
          });
        },
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_currentMode) {
      case 'template':
        return _buildTemplateSelector();
      case 'edit':
        return _buildEditor();
      case 'preview':
        return _buildPreview();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTemplateSelector() {
    return Column(
      children: [
        // 添加分类选择器
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: _templates
                .map((template) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(template['category']!),
                        selected: _selectedCategory == template['category'],
                        onSelected: (bool selected) {
              setState(() {
                            _selectedCategory = template['category']!;
                            _loadTemplateImages(_selectedCategory);
              });
            },
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        // 模板网格部分
                Expanded(
          child: CustomScrollView(
            controller: _scrollController, // 添加滚动控制器
            slivers: [
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
                      (context, index) {
                        final imageData =
                            _templateImages[_selectedCategory]?[index];
                        if (imageData == null) {
                          return const SizedBox();
                        }
                        return _buildTemplateCard(imageData);
                      },
                      childCount:
                          _templateImages[_selectedCategory]?.length ?? 0,
                                ),
                              );
                            },
                          ),
              // 修改加载更多指示器的条件判断
              if (_isLoadingMore[_selectedCategory] ?? false)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                ),
                            ],
                          ),
                        ),
      ],
    );
  }

  Widget _buildTemplateCard(Map<String, String> imageData) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 图片
          Image.network(
            imageData['url']!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
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
                          child: Text(
                imageData['name'] ?? '未命名模板',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                  fontWeight: FontWeight.w500,
                            ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

          // 点击效果
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedBackgroundImage = imageData['url'];
                  _currentMode = 'edit';
                });
              },
                        ),
                      ),
                    ],
          ),
    );
  }

  Widget _buildEditor() {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 添加渐变色背景
                    if (_selectedGradientIndex >= 0)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _gradientColors[_selectedGradientIndex],
                          ),
                        ),
                      ),
                    // 背景图片
                    if (_selectedBackgroundImage != null)
                      Opacity(
                        opacity: _templateOpacity,
                        child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.white.withOpacity(0.7),
                          BlendMode.lighten,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _selectedBackgroundImage!,
                            fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditing = true;
                            _textController.text =
                                _editingText == '在此处添加文本' ? '' : _editingText;
                          });
                        },
                        child: _isEditing
                            ? TextField(
                                controller: _textController,
                                style: _getTextStyle(),
                                textAlign: _textAlign,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onSubmitted: (value) {
                                  setState(() {
                                    _editingText =
                                        value.isEmpty ? '在此处添加文本' : value;
                                    _isEditing = false;
                                  });
                                },
                                onTapOutside: (event) {
                                  setState(() {
                                    _editingText = _textController.text.isEmpty
                                        ? '在此处添加文本'
                                        : _textController.text;
                                    _isEditing = false;
                                  });
                                },
                              )
                            : Text(
                                _editingText,
                                style: _getTextStyle(),
                                textAlign: _textAlign,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 添加渐变色背景
              if (_selectedGradientIndex >= 0)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _gradientColors[_selectedGradientIndex],
                    ),
                  ),
                ),
              // 背景图片
              if (_selectedBackgroundImage != null)
                Opacity(
                  opacity: _templateOpacity,
                  child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.7),
                    BlendMode.lighten,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _selectedBackgroundImage!,
                      fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              // 半透明遮罩
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
              // 文本内容
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  // 如果正在编辑，使用 TextField 的当前值
                  _isEditing ? _textController.text : _editingText,
                  style: _getTextStyle(),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 选择器部分（模板、文字、颜色选择器）
        if (_isToolbarExpanded) ...[
          // 模板选择器
          if (_selectedToolbarItem == '模板')
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 140,
              child: _buildTemplatePickerInToolbar(),
            ),

          // 文字选择器
          if (_selectedToolbarItem == '文字')
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 90,
              child: _buildTextEditor(),
            ),

          // 颜色选择器
          if (_selectedToolbarItem == '颜色')
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 90,
              child: _buildColorPicker(),
            ),
        ],

        // 工具栏主体
        Container(
          height: 68,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              top: BorderSide(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
          child: Stack(
            children: [
              // 工具栏项
              Row(
                children: [
                  // 向上箭头按钮和"样式调整"文字
                  GestureDetector(
                onTap: _toggleToolbar,
                child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Transform.rotate(
                        angle: _arrowRotationAnimation.value,
                        child: Icon(
                          _isToolbarExpanded 
                              ? Icons.keyboard_arrow_down 
                              : Icons.keyboard_arrow_up,
                          size: 24,
                          color: Colors.black87,
                        ),
                      ),
                          // 只在收起状态显示"样式调整"文字
                          if (!_isToolbarExpanded) ...[
                            const SizedBox(width: 8),
                        const Text(
                              '样式调整',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
                  // 工具栏选项
                  if (_isToolbarExpanded)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildToolbarItem('模板'),
                          _buildToolbarItem('文字'),
                          _buildToolbarItem('颜色'),
                          _buildToolbarItem('显隐'),
                        ],
                  ),
                ),
            ],
          ),
              // 选中项的下划线指示器
              if (_selectedToolbarItem != null && _isToolbarExpanded)
                Positioned(
                  left: _getIndicatorPosition(),
                  bottom: 0,
      child: Container(
                    width: 32,
                    height: 2,
        decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // 获取下划线指示器的位置
  double _getIndicatorPosition() {
    switch (_selectedToolbarItem) {
      case '模板':
        return 64;
      case '文字':
        return 164;
      case '颜色':
        return 264;
      case '显隐':
        return 364;
      default:
        return 0;
    }
  }

  // 修改工具栏项构建方法
  Widget _buildToolbarItem(String label) {
    final isSelected = _selectedToolbarItem == label;

    // 根据标签选择对应的图标
    IconData getIconForLabel() {
      switch (label) {
        case '模板':
          return Icons.grid_view_rounded;
        case '文字':
          return Icons.text_format_rounded;
        case '颜色':
          return Icons.palette_rounded;
        case '显隐':
          return Icons.layers_rounded;
        default:
          return Icons.settings_rounded;
      }
    }
    
    return GestureDetector(
      onTap: () => _handleToolTap(label),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            getIconForLabel(),
            color: isSelected
                ? const Color(0xFF2196F3) // 选中时使用标准蓝色
                : const Color(0xFF9E9E9E), // 未选中时使用中性灰色
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? const Color(0xFF2196F3) // 选中时使用标准蓝色
                  : const Color(0xFF9E9E9E), // 未选中时使用中性灰色
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // 修改颜色页面切换方法
  void _toggleColorPage() {
    setState(() {
      _currentColorPage = _currentColorPage == 0 ? 1 : 0;
    });
  }

  // 修改颜色选择器部分的代码
  Widget _buildColorPicker() {
    return SizedBox(
      height: 90,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
          // 第一行渐变色按钮
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(8, (index) {
            final colorIndex = _currentColorPage * 16 + index;
            return _buildGradientColorButton(colorIndex);
          }),
        ),
            ),
          ),
          // 第二行渐变色按钮
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(8, (index) {
            final colorIndex = _currentColorPage * 16 + index + 8;
            return _buildGradientColorButton(colorIndex);
          }),
        ),
            ),
          ),
        // 页面指示器和切换按钮
          Padding(
            padding: const EdgeInsets.only(bottom: 4, top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 添加切换页面按钮
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentColorPage = _currentColorPage == 0 ? 1 : 0;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 4,
                decoration: BoxDecoration(
                            color: _currentColorPage == 0
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 16,
                height: 4,
                decoration: BoxDecoration(
                            color: _currentColorPage == 1
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
                    ),
          ),
        ),
      ],
            ),
          ),
        ],
      ),
    );
  }

  // 修改透明度控制弹出层方法
  void _showOpacityControl() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行
                Row(
                  children: [
                    const Icon(Icons.opacity, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      '背景透明度',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 滑块控制器
                Row(
                  children: [
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return Slider(
                            value: _templateOpacity,
                            min: 0.0,
                            max: 1.0,
                            divisions: 100,
                            label: '${(_templateOpacity * 100).round()}%',
                            onChanged: (value) {
                              setState(() {
                                _templateOpacity = value;
                              });
                              // 更新父级状态
                              this.setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${(_templateOpacity * 100).round()}%',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 底部工具栏的小型模板选择器
  Widget _buildTemplatePickerInToolbar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _templateImages.values
                  .expand((images) => images)
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                final imageData = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBackgroundImage = imageData['url'];
                        _showTemplateSelector = false;
                      });
                    },
                    child: Container(
                      width: 60, // 更小的缩略图
                      height: 90, // 保持宽高比
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedBackgroundImage == imageData['url']
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: imageData != null
                            ? Image.network(
                                imageData['url']!,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, size: 20),
                              ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // 滚动提示
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swipe,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '左右滑动查看更多',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 修改文字编辑器组件
  Widget _buildTextEditor() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 第一行：字体大小、颜色和字体选择
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // 字体大小控制
                  Icon(Icons.text_fields, size: 20.0, color: Colors.grey[600]),
                  Expanded(
                    flex: 2,
                    child: Slider(
                      value: _fontSize,
                      min: 12.0,
                      max: 32.0,
                      divisions: 20,
                      label: _fontSize.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });
                      },
                    ),
                  ),
                  // 文字颜色选择
                  Row(
                    children: [
                      _buildTextColorButton(Colors.black87),
                      _buildTextColorButton(Colors.white),
                      _buildTextColorButton(Colors.red),
                      _buildTextColorButton(Colors.blue),
                      _buildTextColorButton(Colors.green),
                      _buildTextColorButton(Colors.yellow),
                      _buildTextColorButton(Colors.purple),
                      _buildTextColorButton(Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 第二行：字体选择和对齐方式
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // 字体选择下拉框 - 减小宽度
                  Expanded(
                    flex: 2, // 从 3 改回 2，减小宽度
                    child: _buildFontSelector(),
                  ),
                  const SizedBox(width: 24), // 增加间距
                  // 对齐方式按钮组 - 向左对齐
                  Row(
                    // 移除 Expanded，使用普通 Row
                    mainAxisSize: MainAxisSize.min, // 让按钮组宽度自适应
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.format_align_left,
                          size: 20,
                          color: _textAlign == TextAlign.left
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[600],
                        ),
                        onPressed: () =>
                            setState(() => _textAlign = TextAlign.left),
                      ),
                      const SizedBox(width: 16), // 按钮之间的间距
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.format_align_center,
                          size: 20,
                          color: _textAlign == TextAlign.center
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[600],
                        ),
                        onPressed: () =>
                            setState(() => _textAlign = TextAlign.center),
                      ),
                      const SizedBox(width: 16), // 按钮之间的间距
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.format_align_right,
                          size: 20,
                          color: _textAlign == TextAlign.right
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[600],
                        ),
                        onPressed: () =>
                            setState(() => _textAlign = TextAlign.right),
                      ),
                    ],
                  ),
                  const Spacer(), // 添加 Spacer 让按钮组靠左
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 文字颜色选择按钮
  Widget _buildTextColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _textColor = color;
        });
      },
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _textColor == color
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
          // 为白色添加背景
          boxShadow: color == Colors.white
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  // 修改字体选择下拉框
  Widget _buildFontSelector() {
    return Container(
      height: 32.0,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<TextStyle?>(
        value: _selectedFontStyle,
        isExpanded: true,
        underline: const SizedBox(),
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 14.0,
        ),
        items: _fontFamilies.map((font) {
          return DropdownMenuItem<TextStyle?>(
            value: font['textStyle'],
            child: Text(
              font['name'],
              style: font['textStyle']?.copyWith(
                fontSize: 14.0,
                color: Colors.grey[800],
              ),
            ),
          );
        }).toList(),
        onChanged: (TextStyle? newStyle) {
          setState(() {
            _selectedFontStyle = newStyle;
          });
        },
      ),
    );
  }

  // 修改文本样式应用方式
  TextStyle _getTextStyle() {
    final baseStyle = _selectedFontStyle ?? const TextStyle();
    return baseStyle.copyWith(
      fontSize: _fontSize.toDouble(), // 这里已经确保是 double 类型
      color: _textColor,
      height: 1.5,
    );
  }

  // 工具栏展开/收起切换
  void _toggleToolbar() {
    setState(() {
      _isToolbarExpanded = !_isToolbarExpanded;
      if (_isToolbarExpanded) {
        _toolbarAnimController.reverse();
        _selectedToolbarItem = '模板'; // 默认选中模板
      } else {
        _toolbarAnimController.forward();
        _selectedToolbarItem = null; // 清除选中状态
      }
    });
  }

  // 添加渐变色按钮构建方法
  Widget _buildGradientColorButton(int index) {
    if (index >= _gradientColors.length) return const SizedBox();

    final isSelected = _selectedGradientIndex == index;
    final gradientColors = _gradientColors[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGradientIndex = index;
          // 更新背景图片为空，显示渐变色背景
          _selectedBackgroundImage = null;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
          ],
        ),
      ),
    );
  }

  // 处理工具栏项点击事件
  void _handleToolTap(String label) {
    setState(() {
      if (_selectedToolbarItem == label) {
        // 如果点击已选中的项，则取消选中
        _selectedToolbarItem = null;
        _showTemplateSelector = false;
        _showTextEditor = false;
        return;
      }

      // 更新选中项
      _selectedToolbarItem = label;

      // 根据选中的工具执行相应操作
      switch (label) {
        case '文字':
          _showTextEditor = true;
          _showTemplateSelector = false;
          break;
        case '模板':
          _showTemplateSelector = true;
          _showTextEditor = false;
          break;
        case '颜色':
          _showTemplateSelector = false;
          _showTextEditor = false;
          // 显示颜色选择器
          _currentColorPage = 0; // 重置颜色页面
          break;
        case '显隐':
          _showTemplateSelector = false;
          _showTextEditor = false;
          // 显示透明度控制
          _showOpacityControl();
          break;
      }
    });
  }
}
