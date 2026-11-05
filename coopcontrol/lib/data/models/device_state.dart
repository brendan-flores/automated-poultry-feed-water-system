/// Device state model
/// Represents the current state of the ESP32 device
class DeviceState {
  final int feedWeightG;
  final HopperStatus hopperStatus;
  final ReservoirStatus reservoirStatus;
  final TroughStatus troughStatus;
  final SystemState systemState;
  final DateTime lastSeen;

  const DeviceState({
    required this.feedWeightG,
    required this.hopperStatus,
    required this.reservoirStatus,
    required this.troughStatus,
    required this.systemState,
    required this.lastSeen,
  });

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    return DeviceState(
      feedWeightG: json['feed_weight_g'] as int,
      hopperStatus: HopperStatus.fromString(json['hopper_status'] as String),
      reservoirStatus: ReservoirStatus.fromString(json['reservoir_status'] as String),
      troughStatus: TroughStatus.fromString(json['trough_status'] as String),
      systemState: SystemState.fromString(json['system_state'] as String),
      lastSeen: DateTime.parse(json['last_seen'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feed_weight_g': feedWeightG,
      'hopper_status': hopperStatus.value,
      'reservoir_status': reservoirStatus.value,
      'trough_status': troughStatus.value,
      'system_state': systemState.value,
      'last_seen': lastSeen.toIso8601String(),
    };
  }

  /// Check if device is online (last seen within threshold)
  bool isOnline(Duration threshold) {
    return DateTime.now().difference(lastSeen) < threshold;
  }

  /// Check if any sensor is in error state
  bool hasSensorError() {
    return hopperStatus == HopperStatus.error ||
        reservoirStatus == ReservoirStatus.error ||
        troughStatus == TroughStatus.error;
  }

  /// Check if feeding can be performed
  bool canFeed() {
    return !hasSensorError() &&
        hopperStatus != HopperStatus.empty &&
        systemState != SystemState.feeding;
  }

  /// Check if water refill can be performed
  bool canRefillWater() {
    return !hasSensorError() &&
        reservoirStatus != ReservoirStatus.low &&
        reservoirStatus != ReservoirStatus.error;
  }

  DeviceState copyWith({
    int? feedWeightG,
    HopperStatus? hopperStatus,
    ReservoirStatus? reservoirStatus,
    TroughStatus? troughStatus,
    SystemState? systemState,
    DateTime? lastSeen,
  }) {
    return DeviceState(
      feedWeightG: feedWeightG ?? this.feedWeightG,
      hopperStatus: hopperStatus ?? this.hopperStatus,
      reservoirStatus: reservoirStatus ?? this.reservoirStatus,
      troughStatus: troughStatus ?? this.troughStatus,
      systemState: systemState ?? this.systemState,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

enum HopperStatus {
  full('full'),
  low('low'),
  empty('empty'),
  error('error');

  final String value;
  const HopperStatus(this.value);

  static HopperStatus fromString(String value) {
    return HopperStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HopperStatus.error,
    );
  }
}

enum ReservoirStatus {
  ok('ok'),
  low('low'),
  error('error');

  final String value;
  const ReservoirStatus(this.value);

  static ReservoirStatus fromString(String value) {
    return ReservoirStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReservoirStatus.error,
    );
  }
}

enum TroughStatus {
  ok('ok'),
  low('low'),
  error('error');

  final String value;
  const TroughStatus(this.value);

  static TroughStatus fromString(String value) {
    return TroughStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TroughStatus.error,
    );
  }
}

enum SystemState {
  idle('idle'),
  feeding('feeding'),
  refilling('refilling');

  final String value;
  const SystemState(this.value);

  static SystemState fromString(String value) {
    return SystemState.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SystemState.idle,
    );
  }
}
