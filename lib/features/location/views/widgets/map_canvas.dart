import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// The stylized street map behind the location picker.
///
/// A deterministic `CustomPainter` (block grid, diagonal avenue, river, park)
/// with a few street labels layered on top — enough to reproduce the mockup
/// without pulling in a map SDK, and swappable for `google_maps_flutter`
/// later without touching the screen around it.
class MapCanvas extends StatelessWidget {
  const MapCanvas({super.key});

  /// Street names shown on the canvas (fraction-based positions, so they
  /// survive any viewport).
  static const List<_StreetLabel> _labels = [
    _StreetLabel('Jl. Jend. Sudirman', left: 0.07, top: 0.40, tilt: -0.10),
    _StreetLabel('Jl. Kricak', left: 0.55, top: 0.20, tilt: 0.10),
    _StreetLabel('Gg. Mawar', left: 0.44, top: 0.60, tilt: 0.08),
    _StreetLabel('Jl. Jatimulyo', left: 0.10, top: 0.80, tilt: -0.06),
    _StreetLabel('Jl. Kricak Kidul', left: 0.72, top: 0.50, tilt: 0.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _MapPainter()),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            return Stack(
              children: [
                for (final label in _labels)
                  Positioned(
                    left: width * label.left,
                    top: height * label.top,
                    child: Transform.rotate(
                      angle: label.tilt,
                      child: Text(
                        label.text,
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.2,
                          letterSpacing: 0.2,
                          color: AppColors.gray500,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// One street caption: position is a fraction of the canvas, [tilt] in radians.
class _StreetLabel {
  const _StreetLabel(
    this.text, {
    required this.left,
    required this.top,
    required this.tilt,
  });

  final String text;
  final double left;
  final double top;
  final double tilt;
}

class _MapPainter extends CustomPainter {
  static const int _cols = 5;
  static const int _rows = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final cellWidth = width / _cols;
    final cellHeight = height / _rows;

    // Land.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.mapLand,
    );

    // City blocks — one cell is left open for the park.
    final block = Paint()..color = AppColors.mapBlock;
    for (var col = 0; col < _cols; col++) {
      for (var row = 0; row < _rows; row++) {
        if (col == 3 && row == 0) continue;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              col * cellWidth + 8,
              row * cellHeight + 8,
              cellWidth - 16,
              cellHeight - 16,
            ),
            const Radius.circular(AppDimensions.radiusSm),
          ),
          block,
        );
      }
    }

    // Park.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          3 * cellWidth + 8,
          8,
          cellWidth - 16,
          cellHeight - 16,
        ),
        const Radius.circular(AppDimensions.radiusMd),
      ),
      Paint()..color = AppColors.mapPark,
    );

    // River — drawn under the streets so the grid reads as bridges.
    final river = Path()
      ..moveTo(-20, height * 0.64)
      ..cubicTo(
        width * 0.28,
        height * 0.56,
        width * 0.44,
        height * 0.80,
        width + 20,
        height * 0.70,
      );
    canvas.drawPath(
      river,
      Paint()
        ..color = AppColors.mapWater
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Street grid.
    final road = Paint()
      ..color = AppColors.mapRoad
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var col = 1; col < _cols; col++) {
      canvas.drawLine(
        Offset(col * cellWidth, 0),
        Offset(col * cellWidth, height),
        road,
      );
    }
    for (var row = 1; row < _rows; row++) {
      canvas.drawLine(
        Offset(0, row * cellHeight),
        Offset(width, row * cellHeight),
        road,
      );
    }

    // Diagonal avenue.
    canvas.drawLine(
      Offset(width * 0.86, -20),
      Offset(width * 0.18, height + 20),
      road..strokeWidth = 14,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => false;
}
