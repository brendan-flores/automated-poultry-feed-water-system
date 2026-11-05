import '../models/device_state.dart';

/// Abstract repository for device state
abstract class DeviceStateRepository {
  /// Stream of device state updates (Realtime or mock)
  Stream<DeviceState> get deviceStateStream;

  /// Get current device state
  Future<DeviceState?> getCurrentState();

  /// Dispose resources
  void dispose();
}
