import '../models/schedule.dart';

/// Abstract repository for schedules
abstract class ScheduleRepository {
  /// Stream of schedules
  Stream<List<Schedule>> get schedulesStream;

  /// Get all schedules
  Future<List<Schedule>> getSchedules();

  /// Add a schedule
  Future<void> addSchedule(Schedule schedule);

  /// Update a schedule
  Future<void> updateSchedule(Schedule schedule);

  /// Delete a schedule
  Future<void> deleteSchedule(String id);

  /// Toggle schedule enabled state
  Future<void> toggleSchedule(String id, bool enabled);

  /// Dispose resources
  void dispose();
}
