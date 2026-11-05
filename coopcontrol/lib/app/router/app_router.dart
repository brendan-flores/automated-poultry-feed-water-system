import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/schedule/schedule_screen.dart';
import '../../features/alerts/alerts_screen.dart';

/// App router configuration
/// Uses go_router for navigation
class AppRouter {
  static const String home = '/home';
  static const String schedule = '/schedule';
  static const String alerts = '/alerts';
  static const String auth = '/auth';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return _MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: schedule,
            name: 'schedule',
            builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: alerts,
            name: 'alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Main scaffold with bottom navigation
class _MainScaffold extends ConsumerWidget {
  final Widget child;

  const _MainScaffold({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.lunch_dining),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: _AlertsIcon(),
            label: 'Alerts',
          ),
        ],
        selectedIndex: _getSelectedIndex(location),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRouter.home);
              break;
            case 1:
              context.go(AppRouter.schedule);
              break;
            case 2:
              context.go(AppRouter.alerts);
              break;
          }
        },
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith(AppRouter.home)) return 0;
    if (location.startsWith(AppRouter.schedule)) return 1;
    if (location.startsWith(AppRouter.alerts)) return 2;
    return 0;
  }
}

class _AlertsIcon extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, just show the icon without badge
    // In a real implementation, you'd watch the unread count provider
    return const Icon(Icons.notifications);
  }
}
