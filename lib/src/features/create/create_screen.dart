import 'package:flutter/material.dart';
import '../../services/unsplash_service.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

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

  // 添加文字相关属性
  double _fontSize = 16.0;
  TextAlign _textAlign = TextAlign.center;

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
    _textController.dispose();
    _toolbarAnimController.dispose();
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 每行2个模板
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75, // 长宽比
            ),
            itemCount: _templateImages.values
                .expand((images) => images)
                .toList()
                .length,
            itemBuilder: (context, index) {
              final images =
                  _templateImages.values.expand((images) => images).toList();
              final imageUrl = images.isNotEmpty ? images[index] : null;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBackgroundImage = imageUrl;
                    _currentMode = 'edit'; // 选择后自动切换到编辑模式
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedBackgroundImage == imageUrl
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 32),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
          // 模板选择器（当点击模板按钮时显示）
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showTemplateSelector ? 140 : 0,
            child: _showTemplateSelector
                ? _buildTemplatePickerInToolbar()
                : const SizedBox.shrink(),
          ),

          // 颜色选择器（保持原有代码）
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showColorPicker ? 90 : 0, // 减小高度
            child: _showColorPicker
                ? _buildColorPicker()
                : const SizedBox.shrink(),
          ),

          // 文字选择器
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showTextEditor ? 90 : 0,
            child:
                _showTextEditor ? _buildTextEditor() : const SizedBox.shrink(),
          ),

          // 工具栏
          InkWell(
            onTap: _toggleToolbar,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
  }

  // 添加颜色选择器显示状态
  bool _showColorPicker = false;

  Widget _buildToolbarItem(String label) {
    bool isSelected = false;
    switch (label) {
      case '模板':
        isSelected = _showTemplateSelector;
        break;
      case '颜色':
        isSelected = _showColorPicker;
        break;
      case '文字':
        isSelected = _showTextEditor;
        break;
    }

    return GestureDetector(
      onTap: () {
        // 使用 Future.microtask 来避免在构建过程中调用 setState
        Future.microtask(() {
          switch (label) {
            case '模板':
              setState(() {
                _showTemplateSelector = !_showTemplateSelector;
                _showColorPicker = false;
                _showTextEditor = false;
              });
              break;
            case '颜色':
              setState(() {
                _showColorPicker = !_showColorPicker;
                _showTemplateSelector = false;
                _showTextEditor = false;
              });
              break;
            case '文字':
              setState(() {
                _showTextEditor = !_showTextEditor;
                _showTemplateSelector = false;
                _showColorPicker = false;
              });
              break;
            case '显隐':
              // 先关闭所有选择器
              setState(() {
                _showTemplateSelector = false;
                _showColorPicker = false;
                _showTextEditor = false;
              });
              // 然后显示透明度控制
              _showOpacityControl();
              break;
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.grey.withOpacity(0.1) : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black87,
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
    if (index >= _gradientColors.length) return const SizedBox(width: 24);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGradientIndex = index;
        });
      },
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradientColors[index],
          ),
          shape: BoxShape.circle,
          border: _selectedGradientIndex == index
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
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
                final imageUrl = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBackgroundImage = imageUrl;
                        _showTemplateSelector = false;
                      });
                    },
                    child: Container(
                      width: 60, // 更小的缩略图
                      height: 90, // 保持宽高比
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedBackgroundImage == imageUrl
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
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
                  Icon(Icons.text_fields, size: 20, color: Colors.grey[600]),
                  Expanded(
                    flex: 2,
                    child: Slider(
                      value: _fontSize,
                      min: 12.0,
                      max: 32.0,
                      divisions: 20,
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
                  // 字体选择下拉框
                  Expanded(
                    flex: 2,
                    child: _buildFontSelector(),
                  ),
                  const SizedBox(width: 16),
                  // 对齐方式
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          onPressed: () {
                            setState(() {
                              _textAlign = TextAlign.left;
                            });
                          },
                        ),
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
                          onPressed: () {
                            setState(() {
                              _textAlign = TextAlign.center;
                            });
                          },
                        ),
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
                          onPressed: () {
                            setState(() {
                              _textAlign = TextAlign.right;
                            });
                          },
                        ),
                      ],
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
      height: 32,
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
          fontSize: 14,
        ),
        items: _fontFamilies.map((font) {
          return DropdownMenuItem<TextStyle?>(
            value: font['textStyle'],
            child: Text(
              font['name'],
              style: font['textStyle']?.copyWith(
                fontSize: 14,
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
      fontSize: _fontSize,
      color: _textColor,
      height: 1.5,
    );
  }
}
