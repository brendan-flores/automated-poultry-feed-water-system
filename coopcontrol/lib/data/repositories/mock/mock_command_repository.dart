import 'dart:async';
import '../../models/device_command.dart';
import '../command_repository.dart';

/// Mock implementation of CommandRepository
/// Simulates sending commands to the device
class MockCommandRepository implements CommandRepository {
  final _controller = StreamController<DeviceCommand>.broadcast();

  @override
  Future<DeviceCommand> sendCommand(DeviceCommand command) async {
    // Simulate command acceptance
    final updated = command.copyWith(
      status: CommandStatus.accepted,
    );
    _controller.add(updated);

    // Simulate completion after delay
    await Future.delayed(const Duration(seconds: 3));
    final completed = updated.copyWith(
      status: CommandStatus.done,
    );
    _controller.add(completed);

    return completed;
  }

  @override
  Stream<DeviceCommand> get commandStream => _controller.stream;

  @override
  void dispose() {
    _controller.close();
  }
}
