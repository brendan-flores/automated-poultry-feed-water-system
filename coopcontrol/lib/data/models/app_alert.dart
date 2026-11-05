/// App alert model
/// Represents an alert from the device
class AppAlert {
  final String id;
  final AlertType type;
  final String message;
  final AlertSeverity severity;
  final DateTime createdAt;
  final bool read;

  const AppAlert({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    required this.createdAt,
    required this.read,
  });

  factory AppAlert.fromJson(Map<String, dynamic> json) {
    return AppAlert(
      id: json['id'] as String,
      type: AlertType.fromString(json['type'] as String),
      message: json['message'] as String,
      severity: AlertSeverity.fromString(json['severity'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      read: json['read'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'message': message,
      'severity': severity.value,
      'created_at': createdAt.toIso8601String(),
      'read': read,
    };
  }

  AppAlert copyWith({
    String? id,
    AlertType? type,
    String? message,
    AlertSeverity? severity,
    DateTime? createdAt,
    bool? read,
  }) {
    return AppAlert(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}

enum AlertType {
  hopperLow('hopper_low'),
  hopperEmpty('hopper_empty'),
  reservoirLow('reservoir_low'),
  feedingFailed('feeding_failed'),
  feedingTimeout('feeding_timeout'),
  pumpTimeout('pump_timeout'),
  sensorError('sensor_error'),
  deviceOffline('device_offline'),
  deviceOnline('device_online'),
  feedingCompleted('feeding_completed');

  final String value;
  const AlertType(this.value);

  static AlertType fromString(String value) {
    return AlertType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AlertType.sensorError,
    );
  }
}

enum AlertSeverity {
  info('info'),
  warning('warning'),
  critical('critical');

  final String value;
  const AlertSeverity(this.value);

  static AlertSeverity fromString(String value) {
    return AlertSeverity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AlertSeverity.info,
    );
  }
}
