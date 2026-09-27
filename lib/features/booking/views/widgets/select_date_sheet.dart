import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// "Select Date" bottom sheet from the Booking mockup: calendar row, month
/// header with ‹ › arrows, weekday strip and a tap-to-set range — solid
/// purple circles on both endpoints, pale purple on the days between.
class SelectDateSheet extends StatefulWidget {
  const SelectDateSheet({
    super.key,
    required this.initialStart,
    required this.initialEnd,
    required this.onSave,
  });

  /// Range the sheet opens with (the booking's current period).
  final DateTime initialStart;
  final DateTime initialEnd;

  /// Reports the new range after "Save"; the sheet has already popped.
  final void Function(DateTime start, DateTime end) onSave;

  /// Presents the sheet over [context].
  static Future<void> show(
    BuildContext context, {
    required DateTime initialStart,
    required DateTime initialEnd,
    required void Function(DateTime start, DateTime end) onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius2xl),
        ),
      ),
      builder: (sheetContext) => SelectDateSheet(
        initialStart: initialStart,
        initialEnd: initialEnd,
        onSave: (start, end) {
          Navigator.of(sheetContext).pop();
          onSave(start, end);
        },
      ),
    );
  }

  @override
  State<SelectDateSheet> createState() => _SelectDateSheetState();
}

class _SelectDateSheetState extends State<SelectDateSheet> {
  static const List<String> _weekdayLabels = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat',
  ];

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// The mockup's grid is always six rows (42 cells).
  static const int _cellCount = 42;

  late DateTime _visibleMonth;
  late DateTime _start;

  /// `null` while the user is mid-selection (start picked, end pending).
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.initialStart.year, widget.initialStart.month);
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  void _select(DateTime day) {
    setState(() {
      if (_end != null) {
        // Range already complete — the next tap starts a new one.
        _start = day;
        _end = null;
      } else if (day.isBefore(_start)) {
        _start = day;
      } else {
        _end = day;
      }
    });
  }

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePadding,
          AppDimensions.space8,
          AppDimensions.pagePadding,
          AppDimensions.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            Text(
              'Select Date',
              textAlign: TextAlign.center,
              style: theme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.space20),
            Row(
              children: [
                _OptionTile(icon: AppAssets.bookingCalendar),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calendar',
                        style: theme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space2),
                      Text(
                        'Set time on your calendar',
                        style: theme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),
            const Divider(),
            const SizedBox(height: AppDimensions.space16),
            Row(
              children: [
                Text(
                  '${_monthNames[_visibleMonth.month - 1]} '
                  '${_visibleMonth.year}',
                  style: theme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _MonthArrow(
                  icon: Icons.chevron_left,
                  onTap: () => _shiftMonth(-1),
                ),
                const SizedBox(width: AppDimensions.space8),
                _MonthArrow(
                  icon: Icons.chevron_right,
                  onTap: () => _shiftMonth(1),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space12),
            Row(
              children: [
                for (final label in _weekdayLabels)
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.space8),
            const Divider(),
            const SizedBox(height: AppDimensions.space4),
            ..._grid(),
            const SizedBox(height: AppDimensions.space16),
            ElevatedButton(
              onPressed: () => widget.onSave(_start, _end ?? _start),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  /// The six rows × seven columns of the visible month, leading/trailing
  /// days rendered gray and inert (the mockup shows them the same way).
  List<Widget> _grid() {
    final year = _visibleMonth.year;
    final month = _visibleMonth.month;
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // Sun = 0
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final daysInPrevious = DateTime(year, month, 0).day;

    Widget cell(int index) {
      final dayNumber = index - firstWeekday + 1;
      final inMonth = dayNumber >= 1 && dayNumber <= daysInMonth;

      if (!inMonth) {
        // Leading (previous month) or trailing (next month) day.
        final shown = dayNumber < 1
            ? daysInPrevious + dayNumber
            : dayNumber - daysInMonth;
        return _DayCell(dayNumber: shown, enabled: false);
      }

      final day = DateTime(year, month, dayNumber);
      final isEndpoint =
          _sameDay(day, _start) || (_end != null && _sameDay(day, _end!));
      final isBetween = _end != null &&
          day.isAfter(_start) &&
          day.isBefore(_end!);

      return _DayCell(
        dayNumber: dayNumber,
        enabled: true,
        selected: isEndpoint,
        between: isBetween,
        onTap: () => _select(day),
      );
    }

    return [
      for (var row = 0; row < _cellCount ~/ 7; row++)
        Row(
          children: [for (var col = 0; col < 7; col++) cell(row * 7 + col)],
        ),
    ];
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Pale-purple square tile holding one of the kit's 48px calendar/payment
/// glyphs — the mockup's leading icon for date-ish rows.
class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.space48,
      height: AppDimensions.space48,
      decoration: const BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusLg)),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        icon,
        width: AppDimensions.iconLg,
        height: AppDimensions.iconLg,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Outlined circle button paging the calendar one month back/forward.
class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(40, 40),
          fixedSize: const Size(40, 40),
          foregroundColor: AppColors.gray900,
          side: const BorderSide(color: AppColors.gray300),
          shape: const CircleBorder(),
        ),
        child: Icon(icon, size: AppDimensions.iconLg),
      ),
    );
  }
}

/// One weekday cell: endpoint → solid circle, in-range → pale fill,
/// out-of-month → gray digits with no tap.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dayNumber,
    required this.enabled,
    this.selected = false,
    this.between = false,
    this.onTap,
  });

  final int dayNumber;
  final bool enabled;
  final bool selected;
  final bool between;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;

    final Widget child;
    if (selected) {
      child = Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.primary600,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$dayNumber',
          style: theme.labelLarge?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    } else {
      child = Text(
        '$dayNumber',
        style: theme.bodyMedium?.copyWith(
          fontWeight: between ? FontWeight.w600 : FontWeight.w400,
          color: !enabled
              ? AppColors.gray300
              : between
                  ? AppColors.primary700
                  : AppColors.gray900,
        ),
      );
    }

    return Expanded(
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: between && !selected
              ? BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                )
              : null,
          child: child,
        ),
      ),
    );
  }
}
