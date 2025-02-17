import 'package:flutter/material.dart';
import '../../../common/constants/assets.dart';

class InspirationCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final VoidCallback onTap;
  final bool isNew;

  const InspirationCard({
    Key? key,
    this.imageUrl,
    required this.title,
    required this.onTap,
    this.isNew = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppAssets.radius.card),
          boxShadow: AppAssets.shadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // 背景图片
            SizedBox.expand(
              child: _buildImage(),
            ),

            // 渐变遮罩
            Positioned.fill(
              child: DecoratedBox(
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
              ),
            ),

            // 标题和标签
            Positioned(
              left: AppAssets.spacing.sm,
              right: AppAssets.spacing.sm,
              bottom: AppAssets.spacing.sm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isNew) _buildNewTag(),
                  SizedBox(height: AppAssets.spacing.xs),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppAssets.fontSize.base,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 收藏按钮
            Positioned(
              top: AppAssets.spacing.xs,
              right: AppAssets.spacing.xs,
              child: _buildActionButton(
                icon: Icons.favorite_border,
                onTap: () {
                  // TODO: 收藏灵感
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return imageUrl != null
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
        : _buildPlaceholder();
  }

  Widget _buildNewTag() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppAssets.spacing.sm,
        vertical: AppAssets.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppAssets.colors.primary,
        borderRadius: BorderRadius.circular(AppAssets.radius.sm),
      ),
      child: Text(
        'NEW',
        style: TextStyle(
          color: Colors.white,
          fontSize: AppAssets.fontSize.xs,
          fontWeight: FontWeight.bold,
        ),
      ),
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
