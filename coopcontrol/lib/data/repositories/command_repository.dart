import '../models/device_command.dart';

/// Abstract repository for device commands
abstract class CommandRepository {
  /// Send a command to the device
  Future<DeviceCommand> sendCommand(DeviceCommand command);

  /// Stream of command updates
  Stream<DeviceCommand> get commandStream;

  /// Dispose resources
  void dispose();
}
