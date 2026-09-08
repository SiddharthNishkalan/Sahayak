import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class CustomVectorMap extends StatefulWidget {
  final double height;
  final bool showControls;
  final bool interactive;
  final String? locationLabel;
  final VoidCallback? onAdjustPin;

  const CustomVectorMap({
    super.key,
    this.height = 220,
    this.showControls = true,
    this.interactive = true,
    this.locationLabel,
    this.onAdjustPin,
  });

  @override
  State<CustomVectorMap> createState() => _CustomVectorMapState();
}

class _CustomVectorMapState extends State<CustomVectorMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _zoomScale = 1.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    setState(() {
      if (_zoomScale < 1.4) _zoomScale += 0.1;
    });
  }

  void _zoomOut() {
    setState(() {
      if (_zoomScale > 0.8) _zoomScale -= 0.1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SahayakColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // The Map Canvas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _zoomScale,
                  child: CustomPaint(
                    painter: _LocalVectorMapPainter(
                      pulseValue: _pulseController.value,
                    ),
                  ),
                );
              },
            ),
          ),

          // Unified Top Control Bar (Never Overlaps)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: SahayakColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: SahayakColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.locationLabel ?? 'Flat 302, Green Meadows Apt, Ward 5',
                            style: SahayakTypography.caption(color: SahayakColors.onSurface).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.showControls) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                      border: Border.all(color: SahayakColors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.layers_rounded, size: 12, color: SahayakColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'GIS Ward 5',
                          style: SahayakTypography.caption(color: SahayakColors.onSurface).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Unified Bottom Controls (Never Collides)
          if (widget.showControls)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: widget.onAdjustPin ?? () {},
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: SahayakColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: SahayakColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tune_rounded, size: 12, color: SahayakColors.onPrimary),
                          const SizedBox(width: 4),
                          Text(
                            'Adjust Pin on Map',
                            style: SahayakTypography.caption(color: SahayakColors.onPrimary).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: SahayakColors.surfaceContainerLowest.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                      border: Border.all(color: SahayakColors.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: _zoomIn,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Icon(Icons.add, size: 16, color: SahayakColors.onSurface),
                          ),
                        ),
                        Container(height: 1, width: 24, color: SahayakColors.outlineVariant.withValues(alpha: 0.3)),
                        InkWell(
                          onTap: _zoomOut,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Icon(Icons.remove, size: 16, color: SahayakColors.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LocalVectorMapPainter extends CustomPainter {
  final double pulseValue;

  _LocalVectorMapPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Base Background Landmass
    final basePaint = Paint()..color = const Color(0xFFF1F3F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), basePaint);

    // Green Belt / Sub-block 1
    final greenBlockPaint = Paint()..color = const Color(0xFFE5EDDF).withValues(alpha: 0.65);
    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.35, 0)
      ..lineTo(w * 0.3, h * 0.35)
      ..lineTo(0, h * 0.25)
      ..close();
    canvas.drawPath(path1, greenBlockPaint);

    // Sub-block 2 (North East)
    final blueBlockPaint = Paint()..color = const Color(0xFFE8EDF5).withValues(alpha: 0.8);
    final path2 = Path()
      ..moveTo(w * 0.65, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.4)
      ..lineTo(w * 0.72, h * 0.35)
      ..close();
    canvas.drawPath(path2, blueBlockPaint);

    // Park Zone Polygon (Shivaji Nagar Gardens)
    final parkPaint = Paint()..color = const Color(0xFFD1E7DD).withValues(alpha: 0.85);
    final parkPath = Path()
      ..moveTo(w * 0.12, h * 0.08)
      ..lineTo(w * 0.26, h * 0.1)
      ..lineTo(w * 0.22, h * 0.3)
      ..lineTo(w * 0.09, h * 0.25)
      ..close();
    canvas.drawPath(parkPath, parkPaint);

    // Kaveri Water Canal
    final canalPaint = Paint()
      ..color = const Color(0xFFB4C5FF).withValues(alpha: 0.8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    final canalPath = Path()
      ..moveTo(w * 0.78, 0)
      ..cubicTo(w * 0.8, h * 0.3, w * 0.84, h * 0.6, w * 0.88, h);
    canvas.drawPath(canalPath, canalPaint);

    // 2. Minor Streets (White lines)
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, h * 0.2), Offset(w, h * 0.16), streetPaint);
    canvas.drawLine(Offset(0, h * 0.8), Offset(w, h * 0.75), streetPaint);
    canvas.drawLine(Offset(w * 0.18, 0), Offset(w * 0.25, h), streetPaint);
    canvas.drawLine(Offset(w * 0.8, 0), Offset(w * 0.75, h), streetPaint);
    canvas.drawLine(Offset(w * 0.3, h * 0.5), Offset(w * 0.7, h * 0.5), streetPaint);

    // 3. Major Arterial Road: D.B. Road (Orange & White double line)
    final arterialCasing = Paint()
      ..color = const Color(0xFFFED7AA)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final arterialCore = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dbRoadStart = Offset(0, h * 0.44);
    final dbRoadEnd = Offset(w, h * 0.44);
    canvas.drawLine(dbRoadStart, dbRoadEnd, arterialCasing);
    canvas.drawLine(dbRoadStart, dbRoadEnd, arterialCore);

    final avinashiStart = Offset(w * 0.52, 0);
    final avinashiEnd = Offset(w * 0.52, h);
    canvas.drawLine(avinashiStart, avinashiEnd, arterialCasing);
    canvas.drawLine(avinashiStart, avinashiEnd, arterialCore);

    // 4. Green Meadows Apt Bounding Zone
    final meadowRect = Rect.fromLTWH(w * 0.38, h * 0.52, w * 0.25, h * 0.25);
    final meadowFill = Paint()..color = const Color(0xFF6CF8BB).withValues(alpha: 0.18);
    final meadowBorder = Paint()
      ..color = const Color(0xFF006C49)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(RRect.fromRectAndRadius(meadowRect, const Radius.circular(6)), meadowFill);
    canvas.drawRRect(RRect.fromRectAndRadius(meadowRect, const Radius.circular(6)), meadowBorder);

    // 5. Kaveri Water Tank Landmark
    final tankCenter = Offset(w * 0.3, h * 0.3);
    canvas.drawCircle(tankCenter, 10, Paint()..color = const Color(0xFF0053DB).withValues(alpha: 0.15));
    canvas.drawCircle(tankCenter, 3.5, Paint()..color = const Color(0xFF004AC6));

    // 6. User Address Pin Marker & Animated Pulse at (w * 0.49, h * 0.67)
    final pinCenter = Offset(w * 0.49, h * 0.67);

    // Pulse Ring
    final pulseRadius = 18.0 + (pulseValue * 20.0);
    final pulseOpacity = (1.0 - pulseValue).clamp(0.0, 1.0);
    final pulsePaint = Paint()
      ..color = SahayakColors.primary.withValues(alpha: pulseOpacity * 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(pinCenter, pulseRadius, pulsePaint);
    canvas.drawCircle(pinCenter, 14, Paint()..color = SahayakColors.primary.withValues(alpha: 0.15));

    // Pin Body
    final pinPaint = Paint()..color = SahayakColors.primary;
    final pinBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final pinPath = Path()
      ..moveTo(pinCenter.dx, pinCenter.dy)
      ..cubicTo(pinCenter.dx - 6, pinCenter.dy - 8, pinCenter.dx - 8, pinCenter.dy - 12, pinCenter.dx - 8, pinCenter.dy - 16)
      ..arcToPoint(
        Offset(pinCenter.dx + 8, pinCenter.dy - 16),
        radius: const Radius.circular(8),
      )
      ..cubicTo(pinCenter.dx + 8, pinCenter.dy - 12, pinCenter.dx + 6, pinCenter.dy - 8, pinCenter.dx, pinCenter.dy)
      ..close();

    canvas.drawPath(pinPath, pinPaint);
    canvas.drawPath(pinPath, pinBorderPaint);
    canvas.drawCircle(Offset(pinCenter.dx, pinCenter.dy - 16), 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _LocalVectorMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}
