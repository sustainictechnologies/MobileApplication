import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../models/water_station.dart';

// ─────────────────────────────────────────────────────────────
//  Station Detail Bottom Sheet
//
//  Shows when the user taps a station pin or preview card.
//  Sections:
//    • Header  – name, status, rating, distance
//    • Water Quality – pH bar, TDS bar, quality badge, last tested
//    • Water Availability – fill gauge, liters available
//    • Station Info – price, amenities
//    • Actions – Get Directions + Start Refill
// ─────────────────────────────────────────────────────────────
class StationDetailSheet extends StatefulWidget {
  const StationDetailSheet({
    super.key,
    required this.station,
    required this.allStations,
    required this.onStationChanged,
  });

  final WaterStation station;
  final List<WaterStation> allStations;
  final ValueChanged<WaterStation> onStationChanged;

  @override
  State<StationDetailSheet> createState() => _StationDetailSheetState();
}

class _StationDetailSheetState extends State<StationDetailSheet>
    with SingleTickerProviderStateMixin {
  late WaterStation _current;

  // Drives the fill gauge animation
  late final AnimationController _gaugeCtrl;
  late Animation<double> _fillAnim;

  // Assumed max capacity for percentage calculation
  static const double _kMaxCapacity = 150.0;

  @override
  void initState() {
    super.initState();
    _current = widget.station;

    _gaugeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _buildFillAnim();
    _gaugeCtrl.forward();
  }

  void _buildFillAnim() {
    final target =
        (_current.availableCapacityLitres / _kMaxCapacity).clamp(0.0, 1.0);
    _fillAnim = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _gaugeCtrl, curve: Curves.easeOutCubic),
    );
  }

  void _switchStation(WaterStation s) {
    setState(() => _current = s);
    widget.onStationChanged(s);
    _gaugeCtrl.reset();
    _buildFillAnim();
    _gaugeCtrl.forward();
  }

  @override
  void dispose() {
    _gaugeCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      maxChildSize: 0.93,
      minChildSize: 0.38,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            const _DragHandle(),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildQualitySection(),
                    const SizedBox(height: 20),
                    _buildAvailabilitySection(),
                    const SizedBox(height: 20),
                    _buildInfoSection(),
                    const SizedBox(height: 20),
                    if (widget.allStations.length > 1)
                      _buildOtherStations(),
                    const SizedBox(height: 24),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status + distance + rating row
        Row(
          children: [
            _StatusBadge(isOnline: _current.isOnline),
            const SizedBox(width: 8),
            _DistanceBadge(km: _current.distanceKm),
            const Spacer(),
            const Icon(Icons.star_rounded,
                size: 16, color: Colors.amber),
            const SizedBox(width: 3),
            Text(
              _current.rating.toStringAsFixed(1),
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              ' (${_current.reviewCount})',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textHint),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Station name
        Text(
          _current.name,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        // Address
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 15, color: AppColors.textHint),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _current.address,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Water Quality section ───────────────────────────────────
  Widget _buildQualitySection() {
    final q = _current.waterQuality;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.science_outlined,
            label: 'Water Quality',
            trailing: _QualityBadge(label: q.label),
          ),
          const SizedBox(height: 16),
          // pH bar
          _LevelBar(
            label: 'pH Level',
            value: q.phLevel,
            min: 0,
            max: 14,
            goodMin: 6.5,
            goodMax: 8.5,
            displayText: q.phLevel.toStringAsFixed(1),
            unit: '',
          ),
          const SizedBox(height: 14),
          // TDS bar
          _LevelBar(
            label: 'TDS',
            value: q.tdsLevel,
            min: 0,
            max: 500,
            goodMin: 0,
            goodMax: 150,
            displayText: q.tdsLevel.toStringAsFixed(0),
            unit: ' ppm',
          ),
          const SizedBox(height: 14),
          // Last tested
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 13, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                'Last tested: 10 min ago',
                style: GoogleFonts.poppins(
                    fontSize: 11.5, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Water Availability section ──────────────────────────────
  Widget _buildAvailabilitySection() {
    final pct =
        (_current.availableCapacityLitres / _kMaxCapacity).clamp(0.0, 1.0);
    final isLow = pct < 0.25;
    final isMid = pct < 0.55;

    final Color gaugeColor = isLow
        ? AppColors.error
        : isMid
            ? AppColors.warning
            : AppColors.primary;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.water_drop_outlined,
            label: 'Water Availability',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Circular gauge
              AnimatedBuilder(
                animation: _fillAnim,
                builder: (_, _) => SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _CapacityGaugePainter(
                      fill: _fillAnim.value,
                      color: gaugeColor,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(pct * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: gaugeColor,
                            ),
                          ),
                          Text(
                            'full',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvailStat(
                      icon: Icons.opacity_rounded,
                      label: 'Available',
                      value:
                          '${_current.availableCapacityLitres.toStringAsFixed(0)} L',
                      color: gaugeColor,
                    ),
                    const SizedBox(height: 12),
                    _AvailStat(
                      icon: Icons.storage_rounded,
                      label: 'Max Capacity',
                      value:
                          '${_kMaxCapacity.toStringAsFixed(0)} L',
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    if (!_current.isOnline)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.error
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Station is currently offline',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Station Info section ────────────────────────────────────
  Widget _buildInfoSection() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              icon: Icons.info_outline_rounded,
              label: 'Station Info'),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoTile(
                icon: Icons.currency_rupee_rounded,
                label: 'Price',
                value:
                    '₹${_current.pricePerLitre.toStringAsFixed(2)}/L',
                color: AppColors.accent,
              ),
              const SizedBox(width: 12),
              _InfoTile(
                icon: Icons.water_drop_rounded,
                label: 'Quality',
                value: _current.waterQuality.label,
                color: _qualityColor(_current.waterQuality.label),
              ),
              const SizedBox(width: 12),
              _InfoTile(
                icon: Icons.star_rounded,
                label: 'Rating',
                value: _current.rating.toStringAsFixed(1),
                color: Colors.amber.shade700,
              ),
            ],
          ),
          if (_current.amenities.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Text(
              'Amenities',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _current.amenities
                  .map((a) => _AmenityChip(label: a))
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.update_rounded, size: 14, color: AppColors.textHint),
              const SizedBox(width: 6),
              Text(
                'Last updated: 10 min ago',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.cleaning_services_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Tank cleaned on 22 April 2026',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Other stations quick-switch ──────────────────────────────
  Widget _buildOtherStations() {
    final others = widget.allStations
        .where((s) => s.id != _current.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other nearby stations',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...others.map((s) => _OtherStationRow(
              station: s,
              onTap: () => _switchStation(s),
            )),
      ],
    );
  }

  // ── Action buttons ──────────────────────────────────────────
  Widget _buildActions() {
    return Row(
      children: [
        // Directions (outline)
        Expanded(
          child: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(
                color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ).wrap(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Directions',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        // Start Refill (filled)
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _current.isOnline ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_rounded,
                  size: 18,
                  color: _current.isOnline
                      ? Colors.white
                      : Colors.grey.shade400,
                ),
                const SizedBox(width: 6),
                Text(
                  'Start Refill',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _current.isOnline
                        ? Colors.white
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────
  Color _qualityColor(String label) {
    switch (label.toLowerCase()) {
      case 'excellent':
        return AppColors.success;
      case 'good':
        return AppColors.primaryLight;
      default:
        return AppColors.warning;
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  Circular capacity gauge painter
// ─────────────────────────────────────────────────────────────
class _CapacityGaugePainter extends CustomPainter {
  const _CapacityGaugePainter({
    required this.fill,   // 0.0 → 1.0
    required this.color,
  });

  final double fill;
  final Color color;

  static const double _strokeWidth = 9.0;
  static const double _startAngle  = -math.pi * 0.75; // 225°
  static const double _sweepTotal  = math.pi * 1.5;   // 270° arc

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - _strokeWidth) / 2;
    final rect   = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawArc(
      rect,
      _startAngle,
      _sweepTotal,
      false,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap   = StrokeCap.round
        ..color       = color.withValues(alpha: 0.12),
    );

    // Filled portion
    if (fill > 0) {
      canvas.drawArc(
        rect,
        _startAngle,
        _sweepTotal * fill,
        false,
        Paint()
          ..style       = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap   = StrokeCap.round
          ..color       = color,
      );
    }
  }

  @override
  bool shouldRepaint(_CapacityGaugePainter o) =>
      o.fill != fill || o.color != color;
}

// ─────────────────────────────────────────────────────────────
//  pH / TDS level bar with good-range indicator
// ─────────────────────────────────────────────────────────────
class _LevelBar extends StatelessWidget {
  const _LevelBar({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.goodMin,
    required this.goodMax,
    required this.displayText,
    required this.unit,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final double goodMin;
  final double goodMax;
  final String displayText;
  final String unit;

  bool get _isGood => value >= goodMin && value <= goodMax;

  Color get _barColor => _isGood ? AppColors.success : AppColors.warning;

  @override
  Widget build(BuildContext context) {
    final normalised = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final goodMinN   = ((goodMin - min) / (max - min)).clamp(0.0, 1.0);
    final goodMaxN   = ((goodMax - min) / (max - min)).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + value
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '$displayText$unit',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _barColor,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _barColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _isGood ? 'Good' : 'Check',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _barColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        // Bar
        LayoutBuilder(builder: (_, c) {
          return Stack(
            children: [
              // Background
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Good-range highlight
              Positioned(
                left: c.maxWidth * goodMinN,
                width:
                    c.maxWidth * (goodMaxN - goodMinN),
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.success
                        .withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Fill
              Container(
                height: 6,
                width: c.maxWidth * normalised,
                decoration: BoxDecoration(
                  color: _barColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Thumb
              Positioned(
                left: c.maxWidth * normalised - 5,
                top: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _barColor,
                    border:
                        Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _barColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 4),
        Text(
          'Optimal: $goodMin–$goodMax$unit',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Other station row (quick-switch)
// ─────────────────────────────────────────────────────────────
class _OtherStationRow extends StatelessWidget {
  const _OtherStationRow(
      {required this.station, required this.onTap});

  final WaterStation station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (station.isOnline
                        ? AppColors.primary
                        : Colors.grey.shade400)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.water_drop_rounded,
                size: 18,
                color: station.isOnline
                    ? AppColors.primary
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${station.distanceKm.toStringAsFixed(1)} km · '
                    '${station.waterQuality.label}',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Small reusable widgets
// ─────────────────────────────────────────────────────────────
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF2F5)),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.label,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color =
        isOnline ? AppColors.success : Colors.grey.shade500;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge({required this.km});
  final double km;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.near_me_rounded,
              size: 13, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            '${km.toStringAsFixed(1)} km away',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  const _QualityBadge({required this.label});
  final String label;

  Color get _color {
    switch (label.toLowerCase()) {
      case 'excellent':
        return AppColors.success;
      case 'good':
        return AppColors.primaryLight;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 10.5, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _AvailStat extends StatelessWidget {
  const _AvailStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.textHint),
            ),
          ],
        ),
      ],
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Extension to wrap OutlinedButtonStyle as a button
// ─────────────────────────────────────────────────────────────
extension _StyleWrap on ButtonStyle {
  Widget wrap({required Widget child, required VoidCallback onTap}) {
    return OutlinedButton(onPressed: onTap, style: this, child: child);
  }
}
