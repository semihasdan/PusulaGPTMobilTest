import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../features/landing/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/chat/presentation/pages/new_chat_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'landing',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => _buildPageWithGesture(
        context,
        state,
        const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      pageBuilder: (context, state) => _buildPageWithGesture(
        context,
        state,
        const RegisterPage(),
      ),
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) => const NewChatScreen(),
    ),
  ],
);

Page<dynamic> _buildPageWithGesture(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CupertinoPage(
    key: state.pageKey,
    child: child,
  );
}