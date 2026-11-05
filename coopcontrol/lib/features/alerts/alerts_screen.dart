import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/app_alert.dart';
import '../../data/repositories/alert_repository.dart';
import '../../data/repositories/mock/mock_alert_repository.dart';

// Providers
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return MockAlertRepository();
});

final alertsProvider = StreamProvider<List<AppAlert>>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  return repository.alertsStream;
});

final unreadCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  return repository.unreadCountStream;
});

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  String _filter = 'active';

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CoopControl',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'Alerts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: const Icon(
            Icons.eco,
            color: AppTheme.onPrimary,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppTheme.onPrimary,
              size: 18,
            ),
          ),
        ],
      ),
      body: alertsAsync.when(
        data: (alerts) => _buildContent(context, ref, alerts, unreadCountAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<AppAlert> alerts,
    AsyncValue<int> unreadCountAsync,
  ) {
    final filteredAlerts = _filterAlerts(alerts);
    final hasCritical = filteredAlerts.any((a) => a.severity == AlertSeverity.critical);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Telemetric Status',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Alerts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(alertRepositoryProvider).markAllAsRead();
                  },
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Clear Info'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // Filter tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterTab(
                    'Active',
                    'active',
                    _filter,
                    () => setState(() => _filter = 'active'),
                  ),
                ),
                Expanded(
                  child: _buildFilterTab(
                    'History',
                    'history',
                    _filter,
                    () => setState(() => _filter = 'history'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // Critical banner
          if (hasCritical && _filter == 'active')
            Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spaceLg),
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.errorContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: const Icon(
                      Icons.priority_high,
                      color: AppTheme.onError,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Action Needed',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: AppTheme.error,
                              ),
                            ),
                            Text(
                              'Coop East #02',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.onErrorContainer.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Water safety interlock active. Pump disabled until refilled.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Alert cards
          if (filteredAlerts.isEmpty)
            _buildEmptyState(context)
          else
            ...filteredAlerts.map((alert) => _buildAlertCard(context, ref, alert)),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value, String selected, VoidCallback onTap) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, WidgetRef ref, AppAlert alert) {
    final severityColor = _getSeverityColor(alert.severity);
    final severityIcon = _getSeverityIcon(alert.severity);
    final severityLabel = _getSeverityLabel(alert.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            decoration: BoxDecoration(
              color: severityColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMd),
                bottomLeft: Radius.circular(AppTheme.radiusMd),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _getSeverityIconBg(alert.severity),
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Icon(
                              severityIcon,
                              color: severityColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            severityLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: severityColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatTimeAgo(alert.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getAlertDetail(alert),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (alert.type == AlertType.hopperLow)
                          Row(
                            children: [
                              const Icon(
                                Icons.scale,
                                color: AppTheme.tertiary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Level: 14% (0.4 kg)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        if (alert.severity == AlertSeverity.critical)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spaceSm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.errorContainer,
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppTheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Dry-run lock on',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: TextButton(
                            onPressed: () {
                              ref.read(alertRepositoryProvider).markAsRead(alert.id);
                            },
                            child: const Text('Acknowledge'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.onSurface,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceXl),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: AppTheme.primaryFixed.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppTheme.onPrimary,
                  size: 40,
                ),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.tertiaryFixed,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: AppTheme.tertiary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceSm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.onPrimaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Coop Tranquil & Balanced',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'All good! No alerts.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your feed hopper, water reservoir, and automated schedules are running smoothly.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '84%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      'Feed Silo',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: AppTheme.outlineVariant,
                ),
                Column(
                  children: [
                    Text(
                      '92%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.secondary,
                      ),
                    ),
                    Text(
                      'Water Tank',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: AppTheme.outlineVariant,
                ),
                Column(
                  children: [
                    Text(
                      '06:00',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    Text(
                      'Next Feed',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<AppAlert> _filterAlerts(List<AppAlert> alerts) {
    switch (_filter) {
      case 'active':
        return alerts.where((a) => !a.read).toList();
      case 'history':
        return alerts.where((a) => a.read).toList();
      default:
        return alerts;
    }
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return AppTheme.primary;
      case AlertSeverity.warning:
        return AppTheme.tertiary;
      case AlertSeverity.critical:
        return AppTheme.error;
    }
  }

  Color _getSeverityIconBg(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return AppTheme.onPrimaryContainer.withOpacity(0.4);
      case AlertSeverity.warning:
        return AppTheme.tertiaryFixed;
      case AlertSeverity.critical:
        return AppTheme.errorContainer;
    }
  }

  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return Icons.check_circle;
      case AlertSeverity.warning:
        return Icons.grain;
      case AlertSeverity.critical:
        return Icons.water_drop;
    }
  }

  String _getSeverityLabel(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return 'Completed';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  String _getAlertDetail(AppAlert alert) {
    switch (alert.type) {
      case AlertType.hopperLow:
        return 'Estimated 1 feeding remaining in the silo reservoir.';
      case AlertType.reservoirLow:
        return 'Pump auto-shutoff activated to prevent dry run burn-in.';
      case AlertType.feedingCompleted:
        return 'Tray weight reached target in 14 seconds via sunrise rule.';
      case AlertType.feedingFailed:
        return 'Auger jam detected, cleared automatically on reverse cycle.';
      case AlertType.deviceOffline:
        return 'Reconnected after 4 minutes. Cached logs synchronized.';
      default:
        return '';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
