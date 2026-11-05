/// Device command model
/// Represents a command sent to the ESP32
class DeviceCommand {
  final String id;
  final CommandType type;
  final CommandStatus status;
  final String? reason;
  final DateTime createdAt;

  const DeviceCommand({
    required this.id,
    required this.type,
    required this.status,
    this.reason,
    required this.createdAt,
  });

  factory DeviceCommand.fromJson(Map<String, dynamic> json) {
    return DeviceCommand(
      id: json['id'] as String,
      type: CommandType.fromString(json['type'] as String),
      status: CommandStatus.fromString(json['status'] as String),
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'status': status.value,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  DeviceCommand copyWith({
    String? id,
    CommandType? type,
    CommandStatus? status,
    String? reason,
    DateTime? createdAt,
  }) {
    return DeviceCommand(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum CommandType {
  feedNow('feed_now'),
  refillWater('refill_water');

  final String value;
  const CommandType(this.value);

  static CommandType fromString(String value) {
    return CommandType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CommandType.feedNow,
    );
  }
}

enum CommandStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected'),
  done('done'),
  failed('failed');

  final String value;
  const CommandStatus(this.value);

  static CommandStatus fromString(String value) {
    return CommandStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CommandStatus.pending,
    );
  }
}
