import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/device_state.dart';
import '../../data/repositories/device_state_repository.dart';
import '../../data/repositories/command_repository.dart';
import '../../data/repositories/mock/mock_device_state_repository.dart';
import '../../data/repositories/mock/mock_command_repository.dart';

// Providers
final deviceStateRepositoryProvider = Provider<DeviceStateRepository>((ref) {
  return MockDeviceStateRepository();
});

final deviceStateProvider = StreamProvider<DeviceState>((ref) {
  final repository = ref.watch(deviceStateRepositoryProvider);
  return repository.deviceStateStream;
});

final commandRepositoryProvider = Provider<CommandRepository>((ref) {
  return MockCommandRepository();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceStateAsync = ref.watch(deviceStateProvider);

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
              'Home',
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
      body: deviceStateAsync.when(
        data: (state) => _buildContent(context, ref, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, DeviceState state) {
    final isOnline = state.isOnline(const Duration(seconds: 90));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection pill
          _buildConnectionPill(context, isOnline, state.lastSeen),

          const SizedBox(height: AppTheme.spaceSm),

          // Sensor error banner
          if (state.hasSensorError())
            _buildSensorErrorBanner(context),

          const SizedBox(height: AppTheme.spaceMd),

          // Main telemetry cards
          _buildSystemStatusCard(context, state),
          const SizedBox(height: AppTheme.spaceMd),
          _buildFeedAndHopperCards(context, state),
          const SizedBox(height: AppTheme.spaceMd),
          _buildWaterCards(context, state),
          const SizedBox(height: AppTheme.spaceMd),

          // Action buttons
          _buildActionButtons(context, ref, state),
        ],
      ),
    );
  }

  Widget _buildConnectionPill(BuildContext context, bool isOnline, DateTime lastSeen) {
    final timeAgo = DateTime.now().difference(lastSeen);
    final timeText = timeAgo.inMinutes > 0
        ? '${timeAgo.inMinutes}m ago'
        : '${timeAgo.inSeconds}s ago';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: isOnline ? AppTheme.primaryFixed : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? AppTheme.primary : AppTheme.outline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
          Text(
            isOnline ? 'Online • $timeText' : 'Offline • $timeText',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
              color: isOnline ? AppTheme.onPrimaryFixed : AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorErrorBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.errorContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.error,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(
              Icons.warning,
              color: AppTheme.onError,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Sensor Warning',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        'Paused',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                          color: AppTheme.onError,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Sensor error – feeding paused',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: AppTheme.onErrorContainer,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatusCard(BuildContext context, DeviceState state) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Text(
                      'ESP32 Core Telemetry',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'System Status: ${_formatSystemState(state.systemState)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.onSurface,
                  ),
                ),
                Text(
                  'All sensors operating normally',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: const Icon(
              Icons.agriculture,
              color: AppTheme.primaryContainer,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedAndHopperCards(BuildContext context, DeviceState state) {
    return Row(
      children: [
        Expanded(
          child: _buildFeedCard(context, state),
        ),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: _buildHopperCard(context, state),
        ),
      ],
    );
  }

  Widget _buildFeedCard(BuildContext context, DeviceState state) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.scale,
                    color: AppTheme.primary,
                    size: 16,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  'Tray 1',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${state.feedWeightG}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'g',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            'Current tray weight',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHopperCard(BuildContext context, DeviceState state) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.grain,
                    color: AppTheme.primary,
                    size: 16,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryFixed,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  _formatHopperStatus(state.hopperStatus),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.onPrimaryFixed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Vertical fill meter
              Container(
                width: 40,
                height: 112,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      height: _getHopperFillHeight(state.hopperStatus),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feed level',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
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

  Widget _buildWaterCards(BuildContext context, DeviceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Water',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            Text(
              '1.8 Bar',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          children: [
            Expanded(
              child: _buildWaterCard(
                context,
                'Main Reservoir',
                Icons.water_drop,
                _formatReservoirStatus(state.reservoirStatus),
                state.reservoirStatus == ReservoirStatus.ok ? 80 : 20,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildWaterCard(
                context,
                'Drinking Trough',
                Icons.waves,
                _formatTroughStatus(state.troughStatus),
                state.troughStatus == TroughStatus.ok ? 95 : 30,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWaterCard(
    BuildContext context,
    String title,
    IconData icon,
    String status,
    double fillPercentage,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryFixed,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.onSecondaryFixed,
                  size: 18,
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryFixed,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                      color: AppTheme.onPrimaryFixed,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
              color: AppTheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: FractionallySizedBox(
              widthFactor: fillPercentage / 100,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, DeviceState state) {
    final canFeed = state.canFeed();
    final canRefill = state.canRefillWater();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: canFeed
                    ? () => _showFeedConfirmation(context, ref)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: AppTheme.onPrimary,
                  minimumSize: const Size(0, 54),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.set_meal, size: 20),
                    SizedBox(width: 8),
                    Text('Feed Now'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: ElevatedButton(
                onPressed: canRefill
                    ? () => _showWaterConfirmation(context, ref)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: AppTheme.onSecondary,
                  minimumSize: const Size(0, 54),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.water_drop, size: 20),
                    SizedBox(width: 8),
                    Text('Refill Water'),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (!canFeed || !canRefill)
          Container(
            margin: const EdgeInsets.only(top: AppTheme.spaceSm),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMd,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock_clock,
                      color: AppTheme.outline,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      !canFeed ? 'Feed disabled' : 'Refill disabled',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceSm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    !canFeed ? 'Hopper safeguard' : 'Reservoir safeguard',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showFeedConfirmation(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeedConfirmationSheet(
        onConfirm: () {
          Navigator.pop(context);
          // TODO: Send feed command
        },
      ),
    );
  }

  void _showWaterConfirmation(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WaterConfirmationSheet(
        onConfirm: () {
          Navigator.pop(context);
          // TODO: Send water command
        },
      ),
    );
  }

  String _formatSystemState(SystemState state) {
    switch (state) {
      case SystemState.idle:
        return 'Idle';
      case SystemState.feeding:
        return 'Feeding';
      case SystemState.refilling:
        return 'Refilling';
    }
  }

  String _formatHopperStatus(HopperStatus status) {
    switch (status) {
      case HopperStatus.full:
        return 'Full (85%)';
      case HopperStatus.low:
        return 'Low (25%)';
      case HopperStatus.empty:
        return 'Empty (0%)';
      case HopperStatus.error:
        return 'Error';
    }
  }

  double _getHopperFillHeight(HopperStatus status) {
    switch (status) {
      case HopperStatus.full:
        return 100;
      case HopperStatus.low:
        return 25;
      case HopperStatus.empty:
        return 0;
      case HopperStatus.error:
        return 0;
    }
  }

  String _formatReservoirStatus(ReservoirStatus status) {
    switch (status) {
      case ReservoirStatus.ok:
        return 'OK';
      case ReservoirStatus.low:
        return 'Low';
      case ReservoirStatus.error:
        return 'Error';
    }
  }

  String _formatTroughStatus(TroughStatus status) {
    switch (status) {
      case TroughStatus.ok:
        return 'OK';
      case TroughStatus.low:
        return 'Low';
      case TroughStatus.error:
        return 'Error';
    }
  }
}

class _FeedConfirmationSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const _FeedConfirmationSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 6,
            margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
          ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryFixed,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: const Icon(
                  Icons.lunch_dining,
                  color: AppTheme.onPrimaryFixed,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dispense Feed Now?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    Text(
                      'Will activate the auger motor',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target Batch:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '250 g',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryContainer,
                foregroundColor: AppTheme.onPrimary,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 20),
                  SizedBox(width: 8),
                  Text('Confirm Dispense'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.surfaceContainer,
                foregroundColor: AppTheme.onSurface,
              ),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterConfirmationSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const _WaterConfirmationSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 6,
            margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
          ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryFixed,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: AppTheme.onSecondaryFixed,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refill Water Now?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    Text(
                      'Will activate the water pump',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: AppTheme.onSecondary,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 20),
                  SizedBox(width: 8),
                  Text('Confirm Refill'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.surfaceContainer,
                foregroundColor: AppTheme.onSurface,
              ),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
