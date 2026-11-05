import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/schedule.dart';
import '../schedule_repository.dart';

/// Mock implementation of ScheduleRepository
/// Returns simulated schedule data
class MockScheduleRepository implements ScheduleRepository {
  final _controller = StreamController<List<Schedule>>.broadcast();
  final List<Schedule> _schedules = [];

  MockScheduleRepository() {
    // Use Future.microtask to ensure data is emitted after constructor
    Future.microtask(() => _initializeMockData());
  }

  void _initializeMockData() {
    // Create mock schedules based on the design
    _schedules.addAll([
      Schedule(
        id: '1',
        time: const TimeOfDay(hour: 6, minute: 0),
        targetWeightG: 300,
        enabled: true,
      ),
      Schedule(
        id: '2',
        time: const TimeOfDay(hour: 12, minute: 0),
        targetWeightG: 250,
        enabled: true,
      ),
      Schedule(
        id: '3',
        time: const TimeOfDay(hour: 17, minute: 0),
        targetWeightG: 300,
        enabled: true,
      ),
    ]);
    _controller.add(List.from(_schedules));
  }

  @override
  Stream<List<Schedule>> get schedulesStream => _controller.stream;

  @override
  Future<List<Schedule>> getSchedules() async {
    return List.from(_schedules);
  }

  @override
  Future<void> addSchedule(Schedule schedule) async {
    _schedules.add(schedule);
    _controller.add(List.from(_schedules));
  }

  @override
  Future<void> updateSchedule(Schedule schedule) async {
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _schedules[index] = schedule;
      _controller.add(List.from(_schedules));
    }
  }

  @override
  Future<void> deleteSchedule(String id) async {
    _schedules.removeWhere((s) => s.id == id);
    _controller.add(List.from(_schedules));
  }

  @override
  Future<void> toggleSchedule(String id, bool enabled) async {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = _schedules[index].copyWith(enabled: enabled);
      _controller.add(List.from(_schedules));
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}
