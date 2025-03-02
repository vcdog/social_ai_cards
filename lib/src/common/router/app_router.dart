// import 'package:go_router/go_router.dart';  // 暂时注释掉，后续需要时再启用
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/template/template_screen.dart';
import '../../features/create/create_screen.dart';
import '../../features/works/works_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/settings/theme_mode_screen.dart';
import '../../features/template/template_detail_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// 自定义页面切换动画
CustomTransitionPage<T> _buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut)).animate(animation),
          child: child,
        ),
      );
    },
  );
}

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
    // 欢迎页面路由
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    
    // 使用 ShellRoute 来管理带有底部导航栏的页面
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ShellScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/templates',
          builder: (context, state) => const TemplateScreen(),
        ),
        GoRoute(
          path: '/works',
          builder: (context, state) => const WorksScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    
    // 创建卡片页面作为独立路由
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/create',
      builder: (context, state) => const CreateScreen(),
    ),

    GoRoute(
      path: '/settings/theme',
      builder: (context, state) => const ThemeModeScreen(),
    ),

    // 确保模板详情页面使用根导航器
    GoRoute(
      path: '/template-detail',
      parentNavigatorKey: _rootNavigatorKey, // 关键设置：使用根导航器
      builder: (context, state) {
        final templateData = state.extra as Map<String, String>;
        return TemplateDetailScreen(templateData: templateData);
      },
    ),
  ],
);

// TODO: 后续实现路由配置

// 添加错误页面
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('页面加载错误'),
      ),
    );
  }
}
