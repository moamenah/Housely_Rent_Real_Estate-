/// Formatting helpers for numeric UI values.
extension NumberFormattingX on double {
  /// `1250000.toPrice()` → `1,250,000`
  String toPrice({String currency = r'$'}) {
    final rounded = round();
    final formatted = rounded.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
    return '$currency$formatted';
  }

  /// `4.5.toRating()` → `4.5`
  String toRating() => toStringAsFixed(1);

  /// `95.toArea()` → `95 m²`
  String toArea({String unit = r'm²'}) => '${round()} $unit';
}
