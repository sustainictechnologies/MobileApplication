import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<RefillRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = AuthService.instance.getRefillHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refill History')),
      body: FutureBuilder<List<RefillRecord>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const _EmptyHistory();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _RefillRecordCard(record: records[index]),
          );
        },
      ),
    );
  }
}

class _RefillRecordCard extends StatelessWidget {
  const _RefillRecordCard({required this.record});

  final RefillRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('d MMM yyyy · h:mm a').format(record.refillAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.water_drop_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.stationName, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(dateStr, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${record.litresFilled.toStringAsFixed(1)} L',
                  style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primary),
                ),
                Text(
                  '₹${record.amountPaid.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('No refills yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Your refill history will appear here', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
