import 'package:flutter/material.dart';
import '../../../common/constants/assets.dart';

class TemplateCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String description;
  final VoidCallback onTap;

  const TemplateCard({
    Key? key,
    this.imageUrl,
    required this.title,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: EdgeInsets.only(right: AppAssets.spacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppAssets.radius.card),
          boxShadow: AppAssets.shadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            Expanded(
              flex: 3,
              child: _buildImage(),
            ),
            // 信息区域
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(AppAssets.spacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppAssets.fontSize.base,
                        fontWeight: FontWeight.bold,
                        color: AppAssets.colors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppAssets.spacing.xs),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: AppAssets.fontSize.sm,
                        color: AppAssets.colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 图片或占位符
        imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoadingPlaceholder();
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorPlaceholder();
                },
              )
            : _buildPlaceholder(),

        // 渐变遮罩
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),

        // 操作按钮
        Positioned(
          top: AppAssets.spacing.xs,
          right: AppAssets.spacing.xs,
          child: Row(
            children: [
              _buildActionButton(
                icon: Icons.favorite_border,
                onTap: () {
                  // TODO: 收藏模板
                },
              ),
              SizedBox(width: AppAssets.spacing.xs),
              _buildActionButton(
                icon: Icons.share_outlined,
                onTap: () {
                  // TODO: 分享模板
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(AppAssets.radius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppAssets.radius.sm),
        child: Container(
          padding: EdgeInsets.all(AppAssets.spacing.xs),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.image_outlined,
        size: 32,
        color: Colors.grey[400],
      ),
    );
  }

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
        size: 32,
        color: Colors.grey[400],
      ),
    );
  }
}
