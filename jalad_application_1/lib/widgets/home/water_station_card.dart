import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/water_station.dart';

class WaterStationCard extends StatelessWidget {
  const WaterStationCard({
    super.key,
    required this.station,
    this.onTap,
  });

  final WaterStation station;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusBadge(isOnline: station.isOnline),
                  const Spacer(),
                  _RatingChip(rating: station.rating, reviewCount: station.reviewCount),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                station.name,
                style: theme.textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      station.address,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoTile(
                    icon: Icons.straighten_outlined,
                    value: '${station.distanceKm.toStringAsFixed(1)} km',
                    label: 'Distance',
                  ),
                  _InfoTile(
                    icon: Icons.currency_rupee,
                    value: '₹${station.pricePerLitre.toStringAsFixed(2)}/L',
                    label: 'Price',
                  ),
                  _InfoTile(
                    icon: Icons.water_drop_outlined,
                    value: station.waterQuality.label,
                    label: 'Quality',
                    valueColor: _qualityColor(station.waterQuality.label),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? AppColors.success.withValues(alpha: 0.12) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.success : Colors.grey,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isOnline ? AppColors.success : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating, required this.reviewCount});

  final double rating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        Text(
          ' ($reviewCount)',
          style: const TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}
