import 'package:go_router/go_router.dart';
import '../../domain/entities/draft_entity.dart';
import '../../presentation/screens/draft_edit_screen.dart';
import '../../presentation/screens/draft_list_screen.dart';
import '../../presentation/screens/settings_screen.dart';

abstract class AppRoutes {
  static const String home = '/';
  static const String edit = '/edit';
  static const String settings = '/settings';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const DraftListScreen(),
    ),
    GoRoute(
      path: AppRoutes.edit,
      name: 'edit',
      builder: (context, state) {
        final draft = state.extra as DraftEntity?;
        return DraftEditScreen(draft: draft);
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);