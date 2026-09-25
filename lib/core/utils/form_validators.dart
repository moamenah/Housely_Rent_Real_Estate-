/// Input checks shared by the auth ViewModels (sign-in and sign-up).
///
/// Messages are user-safe and final — there is no localisation layer yet, so
/// they live next to the rules that produce them instead of inside a Cubit.
abstract final class FormValidators {
  FormValidators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// `null` when [value] is a usable email, otherwise the inline message.
  static String? email(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Email is required.';
    if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address.';
    return null;
  }

  /// `null` when [value] has non-whitespace content, otherwise
  /// `'<label> is required.'`.
  static String? notBlank(String value, String label) =>
      value.trim().isEmpty ? '$label is required.' : null;
}
