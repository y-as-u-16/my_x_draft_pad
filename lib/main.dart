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
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.backgroundLight,
                elevation: 0,
                iconTheme: IconThemeData(color: AppColors.textPrimary),
                titleTextStyle: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: AppColors.textPrimary),
                bodyMedium: TextStyle(color: AppColors.textPrimary),
                bodySmall: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.backgroundDark,
              colorScheme: ColorScheme.dark(
                primary: AppColors.accent,
                secondary: AppColors.accent,
                surface: AppColors.backgroundDark,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.backgroundDark,
                elevation: 0,
                iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
                titleTextStyle: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
                bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
                bodySmall: TextStyle(color: AppColors.textSecondaryDark),
              ),
            ),
          );
        },
      ),
    );
  }
}