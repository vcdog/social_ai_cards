import 'package:flutter/material.dart';
import '../settings/language_screen.dart';
import '../settings/theme_mode_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: ListView(
        children: [
          // 用户信息卡片
          _buildUserCard(),

          const SizedBox(height: 16),

          // Pro会员卡片
          _buildProCard(context),

          const SizedBox(height: 16),

          // 基础设置
          _buildSettingGroup(
            title: '基础设置',
            children: [
              _buildSettingItem(
                icon: Icons.language,
                title: '语言设置',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
              ),
              _buildSettingItem(
                icon: Icons.dark_mode_outlined,
                title: '深色模式',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemeModeScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 帮助我们
          _buildSettingGroup(
            title: '帮助我们',
            children: [
              _buildSettingItem(
                icon: Icons.star_outline,
                title: '好评鼓励',
                onTap: () {
                  // TODO: 跳转应用商店
                },
              ),
              _buildSettingItem(
                icon: Icons.share_outlined,
                title: '推荐给好友',
                onTap: () {
                  // TODO: 实现分享功能
                },
              ),
              _buildSettingItem(
                icon: Icons.feedback_outlined,
                title: '建议反馈',
                onTap: () {
                  // TODO: 跳转反馈页面
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 关注我们
          _buildSettingGroup(
            title: '关注我们',
            children: [
              _buildSettingItem(
                icon: Icons.public,
                title: '官方网站',
                onTap: () {
                  // TODO: 打开网站
                },
              ),
              _buildSettingItem(
                icon: Icons.wechat,
                title: '微信公众号',
                onTap: () {
                  // TODO: 显示公众号二维码
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 其他信息
          _buildSettingGroup(
            title: '其他信息',
            children: [
              _buildSettingItem(
                icon: Icons.info_outline,
                title: '关于应用',
                onTap: () {
                  // TODO: 跳转关于页面
                },
              ),
              _buildSettingItem(
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                onTap: () {
                  // TODO: 跳转隐私政策
                },
              ),
              _buildSettingItem(
                icon: Icons.description_outlined,
                title: '用户协议',
                onTap: () {
                  // TODO: 跳转用户协议
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(
            Icons.person_outline,
            size: 32,
            color: Colors.grey,
          ),
        ),
        title: const Text(
          '游客用户',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            '登录解锁更多功能',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        trailing: OutlinedButton(
          onPressed: () {
            // TODO: 跳转登录页面
          },
          child: const Text('登录'),
        ),
      ),
    );
  }

  Widget _buildProCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Pro会员',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '解锁所有高级功能',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '享受更多专业创作工具',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: 跳转会员购买页面
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('立即开通'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
