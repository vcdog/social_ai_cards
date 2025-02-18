import 'package:flutter/material.dart';
import '../../services/unsplash_service.dart';
import 'dart:math';

class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> with SingleTickerProviderStateMixin {
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
  
  Map<String, String> _templateImages = {};
  bool _isLoading = true;
  // 添加文本编辑相关变量
  final TextEditingController _textController = TextEditingController();
  bool _isEditing = false;
  String _editingText = '在此处添加文本';
  double _textSize = 16.0;
  Color _textColor = Colors.black87;
  Color _backgroundColor = Colors.white; // 默认白色背景
  bool _isColorPickerVisible = false;

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

  // 添加选中的工具栏项状态
  String _selectedToolbarItem = '模板'; // 默认选中模板

  // 在 _CreateScreenState 类中添加新的状态变量
  bool _isStyleButtonHovered = false; // 用于控制按钮的悬停/选中效果

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
        final images = await _unsplashService.getImagesByCategory(template['searchTerm']);
        if (images.isNotEmpty) {
          // 随机选择一张图片
          final randomIndex = Random().nextInt(images.length);
          _templateImages[template['category']] = images[randomIndex];
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading template images: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              // 预览功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // 保存功能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 卡片主体
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('在此输入文本'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 模板选择器（当选中模板时显示）
          if (_selectedToolbarItem == '模板')
            _buildTemplateSelector(),
          // 颜色选择器
          if (_selectedToolbarItem == '颜色')
            _buildColorPicker(),
          // 底部工具栏
          Container(
            height: 68, // 1.8cm
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
                Positioned(
                  left: 16,
                  top: 12,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isStyleButtonHovered = true),
                        onTapUp: (_) => setState(() => _isStyleButtonHovered = false),
                        onTapCancel: () => setState(() => _isStyleButtonHovered = false),
                        onTap: _toggleToolbar,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isStyleButtonHovered ? Colors.grey.shade200 : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Transform.rotate(
                                angle: _arrowRotationAnimation.value,
                                child: Icon(
                                  _isToolbarExpanded 
                                      ? Icons.keyboard_arrow_down 
                                      : Icons.keyboard_arrow_up,
                                  size: 24,
                                  color: _isStyleButtonHovered 
                                      ? Theme.of(context).primaryColor 
                                      : Colors.black87,
                                ),
                              ),
                              // 只在未展开时显示"卡片样式"文字
                              if (!_isToolbarExpanded) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '卡片样式',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _isStyleButtonHovered 
                                        ? Theme.of(context).primaryColor 
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // 展开时显示工具栏选项
                      if (_isToolbarExpanded)
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Row(
                            children: [
                              _buildToolbarItem('模板'),
                              const SizedBox(width: 32),
                              _buildToolbarItem('文字'),
                              const SizedBox(width: 32),
                              _buildToolbarItem('颜色'),
                              const SizedBox(width: 32),
                              _buildToolbarItem('显隐'),
                            ],
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 模板网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              final template = _templates[index];
              final backgroundImage = _templateImages[template['category']];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBackgroundImage = backgroundImage;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedBackgroundImage == backgroundImage
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: _selectedBackgroundImage == backgroundImage
                        ? [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (backgroundImage != null)
                          Image.network(
                            backgroundImage,
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
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            template['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
                            _textController.text = _editingText == '在此处添加文本' ? '' : _editingText;
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
                                    _editingText = value.isEmpty ? '在此处添加文本' : value;
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

  // 修改工具栏项构建方法
  Widget _buildToolbarItem(String label) {
    final isSelected = _selectedToolbarItem == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedToolbarItem = label;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.grey.shade200 : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // 修改工具栏切换方法
  void _toggleToolbar() {
    setState(() {
      _isToolbarExpanded = !_isToolbarExpanded;
      if (_isToolbarExpanded) {
        _toolbarAnimController.reverse();
        _selectedToolbarItem = '模板'; // 展开时默认选中模板
      } else {
        _toolbarAnimController.forward();
        _selectedToolbarItem = ''; // 收起时清除选中状态
      }
    });
  }

  // 添加页面切换方法
  void _toggleColorPage() {
    setState(() {
      _currentColorPage = _currentColorPage == 0 ? 1 : 0;
    });
  }

  // 修改颜色选择器的布局
  Widget _buildColorPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 颜色网格 - 每页2行，每行8个
          if (_currentColorPage == 0) ...[
            // 第一页
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(8, (index) => _buildGradientColorButton(index)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(8, (index) => _buildGradientColorButton(index + 8)),
            ),
          ] else ...[
            // 第二页
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(8, (index) => _buildGradientColorButton(index + 16)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(8, (index) => _buildGradientColorButton(index + 24)),
            ),
          ],
          const SizedBox(height: 8),
          // 页面指示器
          Center(
            child: GestureDetector(
              onTap: _toggleColorPage,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentColorPage == 0 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 16,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentColorPage == 1 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 修改颜色按钮的大小
  Widget _buildGradientColorButton(int index) {
    if (index >= _gradientColors.length) return const SizedBox(width: 32);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGradientIndex = index;
          _backgroundColor = _gradientColors[index][0];
        });
      },
      child: Container(
        width: 32,  // 调小色块尺寸
        height: 32, // 调小色块尺寸
        margin: const EdgeInsets.all(1), // 减小边距
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradientColors[index],
          ),
          border: _selectedGradientIndex == index
              ? Border.all(color: Colors.yellow, width: 2)
              : Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: _selectedGradientIndex == index
              ? [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.3),
                    blurRadius: 6, // 减小阴影
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
      ),
    );
  }
}
