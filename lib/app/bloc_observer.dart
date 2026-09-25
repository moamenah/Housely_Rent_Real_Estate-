import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// Global Bloc logging — wired up in `main()`.
///
/// Prints every state transition and error in debug builds so accidental
/// `emit` storms are visible immediately. Silence it in release builds.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint('${bloc.runtimeType} $change');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (kDebugMode) {
      debugPrint('${bloc.runtimeType} $error\n$stackTrace');
    }
  }
}
