import 'package:flutter/material.dart';

class WorksScreen extends StatefulWidget {
  const WorksScreen({Key? key}) : super(key: key);

  @override
  State<WorksScreen> createState() => _WorksScreenState();
}

class _WorksScreenState extends State<WorksScreen> {
  bool _isSelectionMode = false;
  final Set<int> _selectedItems = <int>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isSelectionMode ? '已选择 ${_selectedItems.length} 项' : '我的作品'),
        actions: _buildAppBarActions(),
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

          // 作品分类标签
          SliverToBoxAdapter(
            child: _buildCategoryTabs(),
          ),

          // 作品网格
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildWorkItem(index),
                childCount: 10, // 临时数量
              ),
            ),
          ),
        ],
      ),
      // 底部操作栏（选择模式时显示）
      bottomNavigationBar: _isSelectionMode ? _buildSelectionToolbar() : null,
      floatingActionButton: !_isSelectionMode
          ? FloatingActionButton(
              onPressed: () {
                // TODO: 跳转到创建页面
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSelectionMode) {
      return [
        TextButton(
          onPressed: () {
            setState(() {
              if (_selectedItems.length == 10) {
                _selectedItems.clear();
              } else {
                _selectedItems.addAll(List<int>.generate(10, (i) => i));
              }
            });
          },
          child: Text(_selectedItems.length == 10 ? '取消全选' : '全选'),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSelectionMode = false;
              _selectedItems.clear();
            });
          },
        ),
      ];
    }
    return [
      IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          setState(() {
            _isSelectionMode = true;
          });
        },
      ),
    ];
  }

  Widget _buildCategoryTabs() {
    final categories = ['全部', '最近', '收藏', '已分享'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category),
              selected: category == '全部', // 临时状态
              onSelected: (selected) {
                // TODO: 实现分类筛选
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkItem(int index) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          InkWell(
            onTap: _isSelectionMode
                ? () {
                    setState(() {
                      if (_selectedItems.contains(index)) {
                        _selectedItems.remove(index);
                      } else {
                        _selectedItems.add(index);
                      }
                    });
                  }
                : () {
                    // TODO: 查看作品详情
                  },
            onLongPress: !_isSelectionMode
                ? () {
                    setState(() {
                      _isSelectionMode = true;
                      _selectedItems.add(index);
                    });
                  }
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 作品预览图
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Text('作品 ${index + 1}'),
                    ),
                  ),
                ),
                // 作品信息
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '作品标题 ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '创建于 2024-03-${index + 10}',
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
          if (_isSelectionMode)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedItems.contains(index)
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.check,
                  size: 20,
                  color: _selectedItems.contains(index)
                      ? Colors.white
                      : Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionToolbar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolbarButton(
            icon: Icons.share,
            label: '分享',
            onTap: () {
              // TODO: 实现分享功能
            },
          ),
          _buildToolbarButton(
            icon: Icons.delete_outline,
            label: '删除',
            onTap: () {
              // TODO: 实现删除功能
            },
          ),
          _buildToolbarButton(
            icon: Icons.folder_outlined,
            label: '移动',
            onTap: () {
              // TODO: 实现移动功能
            },
          ),
          _buildToolbarButton(
            icon: Icons.more_horiz,
            label: '更多',
            onTap: () {
              // TODO: 显示更多选项
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
