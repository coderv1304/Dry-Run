import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/about/about_screen.dart';
import '../features/consent/consent_screen.dart';
import '../features/debrief/debrief_screen.dart';
import '../features/drill/drill_screen.dart';
import '../features/home/home_screen.dart';
import '../features/join/join_screen.dart';
import '../features/report/report_screen.dart';
import '../features/try/try_screen.dart';
import '../state/token_store.dart';

/// The seven routes the product review approved. Path URLs on web, so every
/// route is a real address.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final InitialTokens initial = ref.watch(initialTokensProvider);
  return createAppRouter(initialLocation: _initialLocation(initial));
});

String _initialLocation(InitialTokens initial) {
  if (initial.reportToken != null) {
    return '/report';
  }
  if (initial.inviteToken != null) {
    return '/join';
  }
  return '/';
}

GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeScreen(),
      ),
      GoRoute(
        path: '/join',
        builder: (BuildContext context, GoRouterState state) =>
            const JoinScreen(),
      ),
      GoRoute(
        path: '/consent',
        builder: (BuildContext context, GoRouterState state) =>
            const ConsentScreen(),
      ),
      GoRoute(
        path: '/drill',
        builder: (BuildContext context, GoRouterState state) =>
            const DrillScreen(),
      ),
      GoRoute(
        path: '/debrief',
        builder: (BuildContext context, GoRouterState state) =>
            const DebriefScreen(),
      ),
      GoRoute(
        path: '/report',
        builder: (BuildContext context, GoRouterState state) =>
            const ReportScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (BuildContext context, GoRouterState state) =>
            const AboutScreen(),
      ),
      GoRoute(
        path: '/try',
        builder: (BuildContext context, GoRouterState state) =>
            const TryScreen(),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) =>
        const HomeScreen(),
  );
}
