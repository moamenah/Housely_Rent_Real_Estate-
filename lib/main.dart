import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';
import 'app/bloc_observer.dart';
import 'core/di/injection.dart';

/// Housely entry point.
///
/// Order matters: dependency graph → global observers → widget tree.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = const AppBlocObserver();
  await configureDependencies();

  runApp(const HouselyApp());
}
