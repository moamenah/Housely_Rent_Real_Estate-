import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Application-level ViewModel: which theme the shell renders.
///
/// Lives for the whole session (provided at the root of `HouselyApp`).
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void setMode(ThemeMode mode) => emit(mode);

  void setLight() => emit(ThemeMode.light);

  void setDark() => emit(ThemeMode.dark);

  void useSystem() => emit(ThemeMode.system);

  /// Cycles system → light → dark → system (bound to the app bar action).
  void cycle() {
    emit(switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    });
  }

  /// Cycles light → dark → light, keeping `system` only as the entry state.
  void toggle() =>
      emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}
