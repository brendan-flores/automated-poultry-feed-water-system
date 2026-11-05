import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/schedule.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/mock/mock_schedule_repository.dart';

// Providers
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return MockScheduleRepository();
});

final schedulesProvider = StreamProvider<List<Schedule>>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.schedulesStream;
});

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(schedulesProvider);

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
              'Schedule',
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
      body: schedulesAsync.when(
        data: (schedules) => _buildContent(context, ref, schedules),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Schedule> schedules) {
    final totalWeight = schedules
        .where((s) => s.enabled)
        .fold<int>(0, (sum, s) => sum + s.targetWeightG);
    final enabledCount = schedules.where((s) => s.enabled).length;

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
                    'Feeding Schedule',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    'Automated daily dispense cycles',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Icon(
                  Icons.cloud_download,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spaceMd),

          // Summary banner
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(
                    Icons.grain,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Allocation',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Total: $totalWeight g / day • $enabledCount feedings',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceSm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryFixed,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.onPrimaryFixed,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // Schedule cards
          ...schedules.map((schedule) => _buildScheduleCard(context, ref, schedule)),

          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, WidgetRef ref, Schedule schedule) {
    return GestureDetector(
      onTap: () => _showEditModal(context, ref, schedule),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getTimeIcon(schedule.time.hour),
                          color: _getTimeIconColor(schedule.time.hour),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeLabel(schedule.time.hour),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          schedule.time.hour % 12 == 0
                              ? '12'
                              : '${schedule.time.hour % 12}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ':${schedule.time.minute.toString().padLeft(2, '0')} ${schedule.time.hour >= 12 ? 'PM' : 'AM'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Transform.scale(
                  scale: 1.0,
                  child: Switch(
                    value: schedule.enabled,
                    onChanged: (value) {
                      ref
                          .read(scheduleRepositoryProvider)
                          .toggleSchedule(schedule.id, value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spaceSm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceSm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.scale,
                          color: AppTheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Target: ${schedule.targetWeightG} g',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Tap to adjust',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.onSurfaceVariant,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal(BuildContext context, WidgetRef ref, Schedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ScheduleEditSheet(
        schedule: schedule,
        onSave: (updated) {
          ref.read(scheduleRepositoryProvider).updateSchedule(updated);
          Navigator.pop(context);
        },
        onDelete: () {
          ref.read(scheduleRepositoryProvider).deleteSchedule(schedule.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  IconData _getTimeIcon(int hour) {
    if (hour >= 5 && hour < 12) return Icons.wb_twilight;
    if (hour >= 12 && hour < 17) return Icons.wb_sunny;
    return Icons.bedtime;
  }

  Color _getTimeIconColor(int hour) {
    if (hour >= 5 && hour < 12) return AppTheme.tertiary;
    if (hour >= 12 && hour < 17) return AppTheme.secondary;
    return AppTheme.primary;
  }

  String _getTimeLabel(int hour) {
    if (hour >= 5 && hour < 12) return 'Morning feed';
    if (hour >= 12 && hour < 17) return 'Midday snack';
    return 'Evening meal';
  }
}

class _ScheduleEditSheet extends StatefulWidget {
  final Schedule schedule;
  final Function(Schedule) onSave;
  final VoidCallback onDelete;

  const _ScheduleEditSheet({
    required this.schedule,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_ScheduleEditSheet> createState() => _ScheduleEditSheetState();
}

class _ScheduleEditSheetState extends State<_ScheduleEditSheet> {
  late TimeOfDay _time;
  late int _weight;

  @override
  void initState() {
    super.initState();
    _time = widget.schedule.time;
    _weight = widget.schedule.targetWeightG;
  }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTimeLabel(_time.hour),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    ),
                  Text(
                    'Edit Feeding Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),

          // Time picker
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              children: [
                Text(
                  'Scheduled Dispense',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: AppTheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Text(
                      '${_time.hour % 12 == 0 ? 12 : _time.hour % 12}:${_time.minute.toString().padLeft(2, '0')} ${_time.hour >= 12 ? 'PM' : 'AM'}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _time = _adjustTime(_time, -15);
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme.surfaceContainerHighest,
                        foregroundColor: AppTheme.onSurface,
                      ),
                      child: const Text('-15 min'),
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _time = _adjustTime(_time, 15);
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme.surfaceContainerHighest,
                        foregroundColor: AppTheme.onSurface,
                      ),
                      child: const Text('+15 min'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),

          // Weight stepper
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dispense Quantity',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    'Hopper Calibrated',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove, size: 28),
                        onPressed: () {
                          setState(() {
                            _weight = (_weight - 25).clamp(50, 1000);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$_weight',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          Text(
                            'GRAMS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, size: 28),
                        onPressed: () {
                          setState(() {
                            _weight = (_weight + 25).clamp(50, 1000);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),

          // Preset chips
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Portion Presets',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Row(
                children: [150, 250, 300, 400].map((preset) {
                  final isSelected = _weight == preset;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spaceSm),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _weight = preset;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryFixed
                                : AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Text(
                            '${preset}g',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? AppTheme.onPrimaryFixed
                                  : AppTheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXl),

          // Action buttons
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(widget.schedule.copyWith(
                  time: _time,
                  targetWeightG: _weight,
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryContainer,
                foregroundColor: AppTheme.onPrimary,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 20),
                  SizedBox(width: 8),
                  Text('Save Changes'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.onDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorContainer,
                foregroundColor: AppTheme.onErrorContainer,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete, size: 20),
                  SizedBox(width: 8),
                  Text('Delete Schedule'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TimeOfDay _adjustTime(TimeOfDay time, int minutes) {
    var totalMinutes = time.hour * 60 + time.minute + minutes;
    totalMinutes = (totalMinutes % (24 * 60) + (24 * 60)) % (24 * 60);
    return TimeOfDay(
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
    );
  }

  String _getTimeLabel(int hour) {
    if (hour >= 5 && hour < 12) return 'Morning feed';
    if (hour >= 12 && hour < 17) return 'Midday snack';
    return 'Evening meal';
  }
}
