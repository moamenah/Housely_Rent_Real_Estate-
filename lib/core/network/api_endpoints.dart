/// REST paths exposed by the Housely API.
///
/// Keep every literal path here — never inline a URL string in a data source.
abstract final class ApiEndpoints {
  ApiEndpoints._();

  /// `GET /properties` — paginated list of listings.
  static const String properties = '/properties';

  /// `GET /properties/{id}` — single listing detail.
  static String property(String id) => '$properties/$id';

  /// `GET /favorites` — server-side favourites of the signed-in user.
  static const String favorites = '/favorites';

  /// `POST /auth/login`.
  static const String login = '/auth/login';
}
