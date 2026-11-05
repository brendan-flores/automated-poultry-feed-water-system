import 'dart:async';
import '../../models/device_state.dart';
import '../device_state_repository.dart';

/// Mock implementation of DeviceStateRepository
/// Returns simulated realistic data for UI testing
class MockDeviceStateRepository implements DeviceStateRepository {
  final _controller = StreamController<DeviceState>.broadcast();
  Timer? _timer;

  MockDeviceStateRepository() {
    // Use Future.microtask to ensure data is emitted after constructor
    Future.microtask(() {
      _startSimulation();
      _controller.add(_generateMockState());
    });
  }

  void _startSimulation() {
    // Simulate periodic updates
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _updateState();
    });
  }

  void _updateState() {
    final currentState = _generateMockState();
    _controller.add(currentState);
  }

  DeviceState _generateMockState() {
    // Generate realistic mock data based on the design
    return DeviceState(
      feedWeightG: 250,
      hopperStatus: HopperStatus.full,
      reservoirStatus: ReservoirStatus.ok,
      troughStatus: TroughStatus.ok,
      systemState: SystemState.idle,
      lastSeen: DateTime.now(),
    );
  }

  @override
  Stream<DeviceState> get deviceStateStream {
    return _controller.stream;
  }

  @override
  Future<DeviceState?> getCurrentState() async {
    return _generateMockState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
