/// Formatting helpers for numeric UI values.
extension NumberFormattingX on double {
  /// `1250000.toPrice()` → `1,250,000`
  /// `320.toPrice(decimals: 2)` → `$320.00` — the booking sheet's money rows
  /// always show cents, the feeds never do.
  String toPrice({String currency = r'$', int? decimals}) {
    final value = decimals == null ? round().toString() : toStringAsFixed(decimals);
    final dot = value.indexOf('.');
    final whole = dot == -1 ? value : value.substring(0, dot);
    final tail = dot == -1 ? '' : value.substring(dot);
    final formatted = whole.replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
    return '$currency$formatted$tail';
  }

  /// `4.5.toRating()` → `4.5`
  String toRating() => toStringAsFixed(1);

  /// `95.toArea()` → `95 m²`
  String toArea({String unit = r'm²'}) => '${round()} $unit';

  /// `175.0.toSqft()` → `1,880 sqft` — the details screen bills floor area
  /// in square feet (per the design), while feed cards keep [toArea].
  String toSqft() {
    final grouped = (this * 10.7639)
        .round()
        .toString()
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        );
    return '$grouped sqft';
  }
}
