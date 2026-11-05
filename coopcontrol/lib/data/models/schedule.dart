import 'package:flutter/material.dart';

/// Schedule model
/// Represents a feeding schedule
class Schedule {
  final String id;
  final TimeOfDay time;
  final int targetWeightG;
  final bool enabled;

  const Schedule({
    required this.id,
    required this.time,
    required this.targetWeightG,
    required this.enabled,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final timeStr = json['time'] as String;
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return Schedule(
      id: json['id'] as String,
      time: TimeOfDay(hour: hour, minute: minute),
      targetWeightG: json['target_weight_g'] as int,
      enabled: json['enabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'target_weight_g': targetWeightG,
      'enabled': enabled,
    };
  }

  Schedule copyWith({
    String? id,
    TimeOfDay? time,
    int? targetWeightG,
    bool? enabled,
  }) {
    return Schedule(
      id: id ?? this.id,
      time: time ?? this.time,
      targetWeightG: targetWeightG ?? this.targetWeightG,
      enabled: enabled ?? this.enabled,
    );
  }
}

