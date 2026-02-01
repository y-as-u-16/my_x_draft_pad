import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'ads/ad_manager.dart';
import 'core/constants/app_colors.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await AdManager.initialize();
  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ThemeViewModel>()..loadThemeMode(),
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, child) {
          return MaterialApp.router(
            title: 'X Draft Pad',
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter,
            themeMode: themeViewModel.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: AppColors.backgroundLight,
              colorScheme: ColorScheme.light(
                primary: AppColors.accent,
                secondary: AppColors.accent,
                surface: AppColors.backgroundLight,
                onSurface: AppColors.textPrimaryLight,
              ),
              dividerColor: AppColors.borderLight,
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.backgroundLight,
                elevation: 0,
                scrolledUnderElevation: 0,
                iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
                titleTextStyle: TextStyle(
                  color: AppColors.textPrimaryLight,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
                bodyMedium: TextStyle(color: AppColors.textPrimaryLight),
                bodySmall: TextStyle(color: AppColors.textSecondaryLight),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return AppColors.textSecondaryLight;
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.accent;
                  }
                  return AppColors.borderLight;
                }),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: AppColors.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.backgroundDark,
              colorScheme: ColorScheme.dark(
                primary: AppColors.accent,
                secondary: AppColors.accent,
                surface: AppColors.backgroundDark,
                onSurface: AppColors.textPrimaryDark,
              ),
              dividerColor: AppColors.borderDark,
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.backgroundDark,
                elevation: 0,
                scrolledUnderElevation: 0,
                iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
                titleTextStyle: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
                bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
                bodySmall: TextStyle(color: AppColors.textSecondaryDark),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return AppColors.textSecondaryDark;
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.accent;
                  }
                  return AppColors.borderDark;
                }),
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: AppColors.surfaceDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
