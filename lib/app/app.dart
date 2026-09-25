import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/favorites/viewmodels/favorites_cubit.dart';
import '../features/properties/repositories/property_repository.dart';
import '../features/properties/viewmodels/properties_cubit.dart';
import 'theme_cubit.dart';

/// Application root.
///
/// ```text
/// MultiBlocProvider          ← session-scoped ViewModels
/// └── MaterialApp.router     ← theme comes from ThemeCubit
///     └── GoRouter           ← screens create their own screen-scoped Cubits
/// ```
class HouselyApp extends StatelessWidget {
  const HouselyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<PropertiesCubit>(
          create: (_) => PropertiesCubit(
            repository: sl<PropertyRepository>(),
          )..fetchProperties(),
        ),
        BlocProvider<FavoritesCubit>(create: (_) => FavoritesCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp.router(
          title: 'Housely',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
