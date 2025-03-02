import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/unsplash_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

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
  bool _isSaving = false;
  bool _isSettingWallpaper = false;

  @override
  void initState() {
    super.initState();
    _loadHdImage();
  }

  Future<void> _loadHdImage() async {
    try {
      final originalUrl = widget.templateData['url'] ?? '';
      final hdUrl = await _unsplashService.getHdImageUrl(originalUrl, width: 2560);

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

  // 保存图片到相册
  Future<void> _saveImage(bool originalImage) async {
    if (_hdImageUrl == null) return;
    
    // 检查权限
    if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        status = await Permission.photos.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('需要相册权限才能保存图片')),
            );
          }
          return;
        }
      }
    }
    
    setState(() => _isSaving = true);
    
    try {
      // 1. 首先下载图片数据
      final response = await Dio().get(
        _hdImageUrl!,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        throw Exception('Failed to download image');
      }

      // 2. 直接使用图片数据保存到相册
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "template_${DateTime.now().millisecondsSinceEpoch}",
      );
      
      if (mounted) {
        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('图片已保存到相册')),
          );
        } else {
          throw Exception('Save failed: ${result['error']}');
        }
      }
    } catch (e) {
      print('Save error: $e'); // 添加错误日志
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // 设置壁纸
  Future<void> _setWallpaper(int wallpaperType) async {
    if (_hdImageUrl == null) return;
    
    setState(() => _isSettingWallpaper = true);
    
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/wallpaper.jpg';
      
      await Dio().download(_hdImageUrl!, path);
      
      // 针对不同平台使用不同的实现
      if (Platform.isAndroid) {
        // Android平台直接使用插件设置壁纸
        final result = await WallpaperManager.setWallpaperFromFile(
          path, 
          wallpaperType,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('壁纸设置成功')),
          );
        }
      } else if (Platform.isIOS) {
        // iOS平台保存到相册并提示用户手动设置
        await ImageGallerySaver.saveFile(path);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('图片已保存到相册，请前往"设置>墙纸"手动设置为壁纸'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('设置壁纸失败: $e')),
        );
      }
    } finally {
      setState(() => _isSettingWallpaper = false);
    }
  }

  // 显示壁纸选项对话框
  void _showWallpaperOptions() {
    if (Platform.isIOS) {
      // iOS平台显示简化的对话框
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('设置为壁纸'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('iOS系统限制，无法直接设置壁纸。图片将保存到相册，请手动前往"设置>墙纸"设置。'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _saveImage(true); // 保存原图到相册
              },
              child: const Text('保存图片'),
            ),
          ],
        ),
      );
    } else {
      // Android平台显示完整选项
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('设置为壁纸'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('锁屏壁纸'),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(WallpaperManager.LOCK_SCREEN);
                },
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('主屏幕壁纸'),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(WallpaperManager.HOME_SCREEN);
                },
              ),
              ListTile(
                leading: const Icon(Icons.smartphone),
                title: const Text('同时设置'),
                onTap: () {
                  Navigator.pop(context);
                  _setWallpaper(WallpaperManager.BOTH_SCREEN);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        ),
      );
    }
  }

  // 显示保存选项对话框
  void _showSaveOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存到相册'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('保存原图'),
              onTap: () {
                Navigator.pop(context);
                _saveImage(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.crop),
              title: const Text('保存当前视图'),
              onTap: () {
                Navigator.pop(context);
                _saveImage(false);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  // 跳转到编辑页面
  void _navigateToEdit() {
    if (_hdImageUrl == null) return;
    
    // 跳转到编辑页面，传递图片URL
    context.push('/create', extra: {'imageUrl': _hdImageUrl});
  }

  // 分享图片
  void _shareImage(bool withWatermark) {
    if (_hdImageUrl == null) return;
    
    Share.share(
      '查看这张精美图片: $_hdImageUrl',
      subject: widget.templateData['name'] ?? '分享图片',
    );
  }

  // 显示分享选项对话框
  void _showShareOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('分享图片'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('分享原图'),
              onTap: () {
                Navigator.pop(context);
                _shareImage(false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.water_drop_outlined),
              title: const Text('分享带水印图片'),
              onTap: () {
                Navigator.pop(context);
                _shareImage(true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('生成分享卡片'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现生成分享卡片功能
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('生成分享卡片功能即将上线')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        title: Text(
          widget.templateData['name'] ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!kIsWeb) // 在Web平台上不显示这些操作按钮
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _showShareOptions,
            ),
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {
                // TODO: 实现收藏功能
              },
            ),
          if (!kIsWeb)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                switch (value) {
                  case 'wallpaper':
                    _showWallpaperOptions();
                    break;
                  case 'save':
                    _showSaveOptions();
                    break;
                  case 'edit':
                    _navigateToEdit();
                    break;
                  case 'share':
                    _showShareOptions();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'wallpaper',
                  child: Row(
                    children: [
                      Icon(Icons.wallpaper, size: 20),
                      SizedBox(width: 8),
                      Text('设置为壁纸'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'save',
                  child: Row(
                    children: [
                      Icon(Icons.save_alt, size: 20),
                      SizedBox(width: 8),
                      Text('保存到相册'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('编辑图片'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 20),
                      SizedBox(width: 8),
                      Text('分享选项'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          // 图片查看器
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : PhotoView(
                  imageProvider: CachedNetworkImageProvider(
                    _hdImageUrl ?? widget.templateData['url']!,
                  ),
                  loadingBuilder: (context, event) => Center(
                    child: CircularProgressIndicator(
                      value: event?.expectedTotalBytes != null
                          ? event!.cumulativeBytesLoaded /
                              event.expectedTotalBytes!
                          : null,
                    ),
                  ),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  initialScale: PhotoViewComputedScale.covered,
                  heroAttributes: kIsWeb ? null : PhotoViewHeroAttributes( // Web平台不使用Hero动画
                    tag: 'template_${widget.templateData['url']}',
                  ),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  filterQuality: FilterQuality.high,
                  basePosition: Alignment.center,
                  enableRotation: !kIsWeb, // Web平台禁用旋转
                  scaleStateCycle: (currentState) {
                    if (currentState == PhotoViewScaleState.covering) {
                      return PhotoViewScaleState.initial;
                    } else {
                      return PhotoViewScaleState.covering;
                    }
                  },
                ),
          
          // 加载指示器
          if (_isSaving || _isSettingWallpaper)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _isSaving ? '正在保存...' : '正在设置壁纸...',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
