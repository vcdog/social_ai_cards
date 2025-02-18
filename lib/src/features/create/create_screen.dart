import 'package:flutter/material.dart';
import '../../services/unsplash_service.dart';
import 'dart:math';

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
  final List<Map<String, dynamic>> _templates = [
    {'category': '节日', 'title': '节日祝福', 'searchTerm': 'festival celebration'},
    {'category': '商务', 'title': '商务简约', 'searchTerm': 'business professional'},
    {'category': '社交', 'title': '社交分享', 'searchTerm': 'social media'},
    {'category': '生活', 'title': '生活日常', 'searchTerm': 'lifestyle daily'},
    {'category': '创意', 'title': '创意设计', 'searchTerm': 'creative design'},
    {'category': '其他', 'title': '通用模板', 'searchTerm': 'general template'},
  ];

  Map<String, List<String>> _templateImages = {};
  bool _isLoading = true;
  // 添加文本编辑相关变量
  final TextEditingController _textController = TextEditingController();
  bool _isEditing = false;
  String _editingText = '在此处添加文本';
  double _textSize = 16.0;
  Color _textColor = Colors.black87;

  // 添加工具栏展开状态控制
  bool _isToolbarExpanded = false;
  late AnimationController _toolbarAnimController;
  late Animation<double> _toolbarSlideAnimation;
  late Animation<double> _arrowRotationAnimation;

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
    // 第二页 - 深色系
    [Colors.blue.shade900, Colors.indigo.shade800],
    [Colors.purple.shade900, Colors.deepPurple.shade800],
    [Colors.red.shade900, Colors.redAccent.shade700],
    [Colors.green.shade900, Colors.teal.shade800],
    [Colors.brown.shade900, Colors.brown.shade800],
    [Colors.grey.shade900, Colors.blueGrey.shade800],
    [Colors.indigo.shade900, Colors.blue.shade900],
    [Colors.deepPurple.shade900, Colors.purple.shade900],
    [Colors.pink.shade900, Colors.red.shade900],
    [Colors.teal.shade900, Colors.green.shade900],
    [Colors.blueGrey.shade900, Colors.grey.shade900],
    [Colors.deepOrange.shade900, Colors.orange.shade900],
    [Colors.cyan.shade900, Colors.blue.shade900],
    [Colors.amber.shade900, Colors.orange.shade900],
    [Colors.lime.shade900, Colors.green.shade900],
    [Colors.black, Colors.grey.shade900],
  ];

  // 添加当前选中的渐变色索引
  int _selectedGradientIndex = -1;
  // 添加当前颜色选择器页码
  int _currentColorPage = 0;

  // 添加透明度控制变量
  double _templateOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _loadTemplateImages();

    // 初始化动画控制器
    _toolbarAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 工具栏滑动动画
    _toolbarSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _toolbarAnimController,
      curve: Curves.easeInOut,
    ));

    // 箭头旋转动画
    _arrowRotationAnimation = Tween<double>(
      begin: 0,
      end: 3.14159, // 180度（π弧度）
    ).animate(CurvedAnimation(
      parent: _toolbarAnimController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _toolbarAnimController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplateImages() async {
    try {
      for (var template in _templates) {
        final images = await _unsplashService.getImagesByCategory(
          template['searchTerm'],
          size: 'regular',
        );
        if (images.length >= 2) {
          // 随机选择2张不同的图片
          final List<String> selectedImages = [];
          final random = Random();
          while (selectedImages.length < 2) {
            final randomIndex = random.nextInt(images.length);
            final image = images[randomIndex];
            if (!selectedImages.contains(image)) {
              selectedImages.add(image);
            }
          }
          setState(() {
            _templateImages[template['category']] = selectedImages;
          });
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading template images: $e');
      setState(() => _isLoading = false);
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
    return _buildTemplateGrid();
  }

  Widget _buildTemplateGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: 0.75,
      ),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        final category = template['category'] as String;
        final images = _templateImages[category] ?? [];

        return Column(
          children: [
            if (images.isNotEmpty)
              Expanded(
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, imageIndex) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBackgroundImage = images[imageIndex];
                          _currentMode = 'edit'; // 自动切换到编辑模式
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(images[imageIndex]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            Text(
              template['title'] as String,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
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
                    if (_selectedBackgroundImage != null)
                      ColorFiltered(
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
                                autofocus: true,
                                maxLines: null,
                                textAlign: TextAlign.center,
                                enableInteractiveSelection: true,
                                style: TextStyle(
                                  fontSize: _textSize,
                                  color: _textColor,
                                  height: 1.5,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '输入文本',
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
                                onChanged: (value) {
                                  setState(() {
                                    _editingText = value;
                                  });
                                },
                              )
                            : Text(
                                _editingText,
                                style: TextStyle(
                                  fontSize: _textSize,
                                  color: _textColor,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
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
              // 背景图片
              if (_selectedBackgroundImage != null)
                ColorFiltered(
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
                  style: TextStyle(
                    fontSize: _textSize,
                    color: _textColor,
                    height: 1.5,
                  ),
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
    return AnimatedBuilder(
      animation: _toolbarAnimController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              top: BorderSide(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 颜色选择器（当点击颜色按钮时显示）
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showColorPicker ? null : 0,
                child: _showColorPicker
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: _buildColorPicker(),
                      )
                    : null,
              ),
              // 工具栏
              InkWell(
                onTap: _toggleToolbar,
                child: Container(
                  height: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                      const SizedBox(width: 12),
                      if (!_isToolbarExpanded)
                        const Text(
                          '样式编辑',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      if (_isToolbarExpanded) ...[
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildToolbarItem('模板'),
                              _buildToolbarItem('文字'),
                              _buildToolbarItem('颜色'),
                              _buildToolbarItem('显隐'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // 工具栏内容
              if (!_isToolbarExpanded)
                ClipRect(
                  child: Align(
                    heightFactor: 1.0 - _toolbarSlideAnimation.value,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildToolbarItem('模板'),
                          _buildToolbarItem('文字'),
                          _buildToolbarItem('颜色'),
                          _buildToolbarItem('显隐'),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // 添加颜色选择器显示状态
  bool _showColorPicker = false;

  Widget _buildToolbarItem(String label) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        switch (label) {
          case '颜色':
            setState(() {
              _showColorPicker = !_showColorPicker;
            });
            break;
          // TODO: 处理其他按钮点击事件
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // 工具栏展开/收起切换
  void _toggleToolbar() {
    setState(() {
      _isToolbarExpanded = !_isToolbarExpanded;
      if (_isToolbarExpanded) {
        _toolbarAnimController.reverse();
      } else {
        _toolbarAnimController.forward();
      }
    });
  }

  Widget _buildGradientColorButton(int index) {
    if (index >= _gradientColors.length) return const SizedBox(width: 32);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGradientIndex = index;
        });
        // TODO: 应用选中的渐变色
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradientColors[index],
          ),
          border: _selectedGradientIndex == index
              ? Border.all(color: Colors.yellow, width: 2)
              : null,
        ),
      ),
    );
  }

  // 添加页面切换方法
  void _toggleColorPage() {
    setState(() {
      _currentColorPage = _currentColorPage == 0 ? 1 : 0;
    });
  }

  // 修改颜色选择器部分的代码
  Widget _buildColorPicker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 渐变色按钮网格
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(8, (index) {
            final colorIndex = _currentColorPage * 16 + index;
            return _buildGradientColorButton(colorIndex);
          }),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(8, (index) {
            final colorIndex = _currentColorPage * 16 + index + 8;
            return _buildGradientColorButton(colorIndex);
          }),
        ),
        const SizedBox(height: 16),
        // 页面指示器和切换按钮
        GestureDetector(
          onTap: _toggleColorPage,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 4,
                decoration: BoxDecoration(
                  color: _currentColorPage == 0
                      ? Colors.yellow
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
                      ? Colors.yellow
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
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

  // 修改样式工具栏
  Widget _buildStyleToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 模板按钮
          InkWell(
            onTap: _showTemplateSelector,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image,
                    color: _currentMode == 'template'
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '模板',
                    style: TextStyle(
                      color: _currentMode == 'template'
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 其他样式按钮...
        ],
      ),
    );
  }

  // 修改模板图片显示部分
  Widget _buildTemplatePreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // 背景层
            if (_selectedGradientIndex >= 0)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _gradientColors[_selectedGradientIndex],
                  ),
                ),
              ),

            // 模板图片层
            if (_selectedBackgroundImage != null)
              Positioned.fill(
                child: InteractiveViewer(
                  constrained: true,
                  child: Opacity(
                    opacity: _templateOpacity,
                    child: Image.network(
                      _selectedBackgroundImage!,
                      fit: BoxFit.cover,
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if (frame == null) {
                          return _buildLoadingPlaceholder();
                        }
                        return child;
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorPlaceholder();
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // 添加占位符组件
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.broken_image_outlined,
        size: 48,
        color: Colors.grey[400],
      ),
    );
  }

  // 修改模板选择器的实现
  void _showTemplateSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题栏
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.image, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        '选择模板',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                // 模板网格
                SizedBox(
                  height: 240,
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: _templateImages.values
                        .expand((images) => images)
                        .toList()
                        .length,
                    itemBuilder: (context, index) {
                      final allImages = _templateImages.values
                          .expand((images) => images)
                          .toList();
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedBackgroundImage = allImages[index];
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(allImages[index]),
                                fit: BoxFit.cover,
                              ),
                              border:
                                  _selectedBackgroundImage == allImages[index]
                                      ? Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 2,
                                        )
                                      : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
