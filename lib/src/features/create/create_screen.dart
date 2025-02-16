import 'package:flutter/material.dart';
import '../../services/unsplash_service.dart';
import 'dart:math';

class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
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

  @override
  void initState() {
    super.initState();
    _loadTemplateImages();
  }

  @override
  void dispose() {
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
              _editingText = _textController.text.isEmpty ? '在此处添加文本' : _textController.text;
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
        final backgroundImage = _templateImages[template['category']];

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              setState(() {
                _currentMode = 'edit';
                _selectedBackgroundImage = backgroundImage; // 保存选中的背景图片
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (backgroundImage != null)
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.7),
                            BlendMode.lighten,
                          ),
                          child: Image.network(
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
                        )
                      else
                        Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      // 添加半透明遮罩
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      // 分类标签
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            template['category'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '选择模板',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditor() {
    return Stack(
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildToolbarItem(
            Icons.text_fields,
            '文本',
            onTap: () {
              setState(() {
                _isEditing = true;
                _textController.text = _editingText == '在此处添加文本' ? '' : _editingText;
              });
            },
          ),
          _buildToolbarItem(Icons.image_outlined, '图片'),
          _buildToolbarItem(Icons.format_paint_outlined, '背景'),
          _buildToolbarItem(
            Icons.palette_outlined,
            '样式',
            onTap: () {
              _showTextStyleDialog();
            },
          ),
          _buildToolbarItem(Icons.qr_code_outlined, '二维码'),
        ],
      ),
    );
  }

  void _showTextStyleDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('文本样式', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // 文字大小调节
              Row(
                children: [
                  const Text('文字大小'),
                  Expanded(
                    child: Slider(
                      value: _textSize,
                      min: 12,
                      max: 32,
                      onChanged: (value) {
                        setState(() {
                          _textSize = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              // 文字颜色选择
              Wrap(
                spacing: 8,
                children: [
                  Colors.black87,
                  Colors.white,
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                ].map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _textColor = color;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: Colors.grey,
                          width: _textColor == color ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbarItem(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
