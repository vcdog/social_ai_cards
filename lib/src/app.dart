import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: (context, child) {
        if (child == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ErrorBoundary(child: child);
      },
      // ... 其他配置
    );
  }
}
