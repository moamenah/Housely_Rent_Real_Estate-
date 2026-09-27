import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../../features/auth/datasources/auth_data_source.dart';
import '../../features/auth/datasources/mock_auth_data_source.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/repositories/auth_repository_impl.dart';
import '../../features/booking/datasources/booking_data_source.dart';
import '../../features/booking/datasources/mock_booking_data_source.dart';
import '../../features/booking/repositories/booking_repository.dart';
import '../../features/booking/repositories/booking_repository_impl.dart';
import '../../features/home/datasources/home_data_source.dart';
import '../../features/home/datasources/mock_home_data_source.dart';
import '../../features/home/repositories/home_repository.dart';
import '../../features/home/repositories/home_repository_impl.dart';
import '../../features/location/datasources/location_data_source.dart';
import '../../features/location/datasources/mock_location_data_source.dart';
import '../../features/location/repositories/location_repository.dart';
import '../../features/location/repositories/location_repository_impl.dart';
import '../../features/password_recovery/datasources/mock_password_recovery_data_source.dart';
import '../../features/password_recovery/datasources/password_recovery_data_source.dart';
import '../../features/password_recovery/repositories/password_recovery_repository.dart';
import '../../features/password_recovery/repositories/password_recovery_repository_impl.dart';
import '../../features/profile/datasources/mock_profile_data_source.dart';
import '../../features/profile/datasources/profile_data_source.dart';
import '../../features/profile/repositories/profile_repository.dart';
import '../../features/profile/repositories/profile_repository_impl.dart';
import '../../features/properties/datasources/mock_property_data_source.dart';
import '../../features/properties/datasources/property_data_source.dart';
import '../../features/properties/datasources/property_remote_data_source.dart';
import '../../features/properties/repositories/property_repository.dart';
import '../../features/properties/repositories/property_repository_impl.dart';

/// The service locator.
///
/// Rule of thumb: **only** long-lived objects (data sources, repositories,
/// API clients) are registered here. ViewModels (Cubits) are created per
/// screen with `BlocProvider` so they can never leak between routes.
final GetIt sl = GetIt.instance;

/// Bootstraps the object graph. Call once from `main()` before `runApp`.
Future<void> configureDependencies() async {
  await sl.reset();

  _registerCore();
  _registerFeatures();
}

void _registerCore() {
  sl.registerLazySingleton<ApiClient>(ApiClient.new);
}

void _registerFeatures() {
  // ── Auth ────────────────────────────────────────────────────────────────
  // Offline credential check; replace with a REST/OAuth data source here and
  // the ViewModels stay untouched.
  sl.registerLazySingleton<AuthDataSource>(MockAuthDataSource.new);

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl<AuthDataSource>()),
  );

  // ── Password recovery ────────────────────────────────────────────────────
  // Masked contact list + code check + password reset; swap the mock for a
  // REST data source and the wizard's ViewModel stays untouched.
  sl.registerLazySingleton<PasswordRecoveryDataSource>(
    MockPasswordRecoveryDataSource.new,
  );

  sl.registerLazySingleton<PasswordRecoveryRepository>(
    () => PasswordRecoveryRepositoryImpl(
      dataSource: sl<PasswordRecoveryDataSource>(),
    ),
  );

  // ── Properties ──────────────────────────────────────────────────────────
  // Real backend client (kept ready for when the API ships)…
  sl.registerLazySingleton<PropertyRemoteDataSource>(
    () => PropertyRemoteDataSource(apiClient: sl<ApiClient>()),
  );
  // …but the app currently runs on the offline fixture. Swap these two lines
  // to move to the real API — nothing else in the app changes.
  sl.registerLazySingleton<PropertyDataSource>(MockPropertyDataSource.new);

  sl.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(dataSource: sl<PropertyDataSource>()),
  );

  // ── Home ────────────────────────────────────────────────────────────────
  // Section membership for the feed; the repository joins it against
  // PropertyRepository so Home, Explore and Favorites share one corpus.
  sl.registerLazySingleton<HomeDataSource>(MockHomeDataSource.new);

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      dataSource: sl<HomeDataSource>(),
      propertyRepository: sl<PropertyRepository>(),
    ),
  );

  // ── Location ────────────────────────────────────────────────────────────
  // Address resolution for the map step; swap the mock for a geocoding
  // provider and the picker's ViewModel stays untouched.
  sl.registerLazySingleton<LocationDataSource>(MockLocationDataSource.new);

  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(dataSource: sl<LocationDataSource>()),
  );

  // ── Profile ─────────────────────────────────────────────────────────────
  // Demo account store behind Profile / Edit Profile.
  sl.registerLazySingleton<ProfileDataSource>(MockProfileDataSource.new);

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(dataSource: sl<ProfileDataSource>()),
  );

  // ── Booking ─────────────────────────────────────────────────────────────
  // Checkout session (My Booking tab / "Rent now"): confirm runs through
  // the mock gateway with real latency.
  sl.registerLazySingleton<BookingDataSource>(MockBookingDataSource.new);

  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(dataSource: sl<BookingDataSource>()),
  );
}
