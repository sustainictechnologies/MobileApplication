import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../core/theme/app_theme.dart';
import '../../models/water_station.dart';
import '../../services/water_station_service.dart';
import 'station_detail_sheet.dart';

// ─────────────────────────────────────────────────────────────
//  Find Refill Station — Map Screen
// ─────────────────────────────────────────────────────────────
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Future<List<WaterStation>>? _stationsFuture;

  WaterStation? _selectedStation;

  // Mock user location (Bandra, Mumbai)
  static const LatLng _userLoc = LatLng(19.0596, 72.8295);

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  void _loadStations() {
    setState(() {
      _stationsFuture = WaterStationService.instance.getNearbyStations(
        latitude: _userLoc.latitude,
        longitude: _userLoc.longitude,
      );
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ── Tap a station (from pin or list card) ──────────────────
  void _selectStation(WaterStation station, List<WaterStation> all) {
    setState(() => _selectedStation = station);
    _mapController.move(
      LatLng(station.latitude, station.longitude),
      16.5,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => StationDetailSheet(
        station: station,
        allStations: all,
        onStationChanged: (s) {
          setState(() => _selectedStation = s);
          _mapController.move(LatLng(s.latitude, s.longitude), 16.5);
        },
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _selectedStation = null);
    });
  }

  // ── Build map markers ──────────────────────────────────────
  List<Marker> _buildMarkers(List<WaterStation> stations) {
    return [
      // User location
      Marker(
        point: _userLoc,
        width: 28,
        height: 28,
        child: const _UserLocationMarker(),
      ),
      // Station pins
      ...stations.map(
        (s) => Marker(
          point: LatLng(s.latitude, s.longitude),
          width: 52,
          height: 62,
          alignment: Alignment.bottomCenter,
          child: _StationPin(
            station: s,
            isSelected: _selectedStation?.id == s.id,
            onTap: () => _selectStation(s, stations),
          ),
        ),
      ),
    ];
  }

  // ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<WaterStation>>(
        future: _stationsFuture ?? Future.value([]),
        builder: (context, snapshot) {
          final stations = snapshot.data ?? [];
          final loading =
              snapshot.connectionState == ConnectionState.waiting;

          return Stack(
            children: [
              // ── Full-screen map ──────────────────────────
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _userLoc,
                  initialZoom: 15.5,
                  maxZoom: 19,
                  minZoom: 10,
                  onTap: (_, __) =>
                      setState(() => _selectedStation = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sustainic.jalad',
                    maxNativeZoom: 19,
                  ),
                  if (stations.isNotEmpty)
                    MarkerLayer(markers: _buildMarkers(stations)),
                ],
              ),

              // ── Top gradient for readability ─────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── AppBar ────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: _TopBar(stationCount: stations.length),
                  ),
                ),
              ),

              // ── Loading overlay ───────────────────────────
              if (loading)
                Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                                color: AppColors.primary),
                            SizedBox(height: 12),
                            Text('Finding stations nearby…'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Bottom station cards ──────────────────────
              if (!loading)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _BottomStationPanel(
                    stations: stations,
                    selectedId: _selectedStation?.id,
                    onTap: (s) => _selectStation(s, stations),
                  ),
                ),

              // ── My-location FAB ───────────────────────────
              Positioned(
                right: 16,
                bottom: 210,
                child: FloatingActionButton.small(
                  heroTag: 'my_location_fab',
                  backgroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () =>
                      _mapController.move(_userLoc, 15.5),
                  tooltip: 'My location',
                  child: const Icon(Icons.my_location_rounded,
                      color: AppColors.accent, size: 22),
                ),
              ),

              // ── Refresh FAB ───────────────────────────────
              Positioned(
                right: 16,
                bottom: 260,
                child: FloatingActionButton.small(
                  heroTag: 'refresh_fab',
                  backgroundColor: Colors.white,
                  elevation: 4,
                  onPressed: _loadStations,
                  tooltip: 'Refresh stations',
                  child: const Icon(Icons.refresh_rounded,
                      color: AppColors.primary, size: 22),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Top bar (overlaid on map)
// ─────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.stationCount});

  final int stationCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back
        Material(
          color: Colors.white,
          elevation: 2,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(9),
              child: Icon(Icons.arrow_back_rounded,
                  color: AppColors.textPrimary, size: 22),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Search bar (visual only)
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded,
                    color: AppColors.textHint, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Search refill stations…',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Filter
        Material(
          color: AppColors.primary,
          elevation: 2,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.tune_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Bottom horizontal cards panel
// ─────────────────────────────────────────────────────────────
class _BottomStationPanel extends StatelessWidget {
  const _BottomStationPanel({
    required this.stations,
    required this.selectedId,
    required this.onTap,
  });

  final List<WaterStation> stations;
  final String? selectedId;
  final ValueChanged<WaterStation> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "N stations nearby" pill
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${stations.length} stations nearby',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Scrollable cards
        SizedBox(
          height: 172,
          child: ListView.builder(
            padding: const EdgeInsets.only(
                left: 16, right: 16, bottom: 16),
            scrollDirection: Axis.horizontal,
            itemCount: stations.length,
            itemBuilder: (_, i) => _StationPreviewCard(
              station: stations[i],
              isSelected: stations[i].id == selectedId,
              onTap: () => onTap(stations[i]),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Compact horizontal preview card
// ─────────────────────────────────────────────────────────────
class _StationPreviewCard extends StatelessWidget {
  const _StationPreviewCard({
    required this.station,
    required this.isSelected,
    required this.onTap,
  });

  final WaterStation station;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        station.isOnline ? AppColors.primary : Colors.grey.shade500;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 215,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.10),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusDot(isOnline: station.isOnline),
                const Spacer(),
                // Distance
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.near_me_rounded,
                        size: 12, color: AppColors.accent),
                    const SizedBox(width: 3),
                    Text(
                      '${station.distanceKm.toStringAsFixed(1)} km',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              station.name,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              station.address,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.textHint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                _QualityChip(label: station.waterQuality.label),
                const Spacer(),
                Text(
                  '₹${station.pricePerLitre.toStringAsFixed(2)}/L',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Map station pin
// ─────────────────────────────────────────────────────────────
class _StationPin extends StatelessWidget {
  const _StationPin({
    required this.station,
    required this.isSelected,
    required this.onTap,
  });

  final WaterStation station;
  final bool isSelected;
  final VoidCallback onTap;

  Color get _color {
    if (!station.isOnline) return Colors.grey.shade500;
    if (station.availableCapacityLitres < 25) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.water_drop_rounded,
                  color: Colors.white, size: 22),
            ),
            CustomPaint(
              size: const Size(14, 9),
              painter: _PinTailPainter(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  const _PinTailPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PinTailPainter o) => o.color != color;
}

// ─────────────────────────────────────────────────────────────
//  User location marker
// ─────────────────────────────────────────────────────────────
class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent.withValues(alpha: 0.18),
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Shared small widgets
// ─────────────────────────────────────────────────────────────
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline
                ? AppColors.success
                : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isOnline ? 'Online' : 'Offline',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isOnline
                ? AppColors.success
                : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _QualityChip extends StatelessWidget {
  const _QualityChip({required this.label});
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
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
