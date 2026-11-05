import 'dart:async';
import '../../models/app_alert.dart';
import '../alert_repository.dart';

/// Mock implementation of AlertRepository
/// Returns simulated alert data
class MockAlertRepository implements AlertRepository {
  final _controller = StreamController<List<AppAlert>>.broadcast();
  final _unreadController = StreamController<int>.broadcast();
  final List<AppAlert> _alerts = [];

  MockAlertRepository() {
    // Use Future.microtask to ensure data is emitted after constructor
    Future.microtask(() => _initializeMockData());
  }

  void _initializeMockData() {
    // Create mock alerts based on the design
    _alerts.addAll([
      AppAlert(
        id: '1',
        type: AlertType.hopperLow,
        message: 'Hopper is low – refill feed soon',
        severity: AlertSeverity.warning,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        read: false,
      ),
      AppAlert(
        id: '2',
        type: AlertType.reservoirLow,
        message: 'Reservoir water is low – pump paused',
        severity: AlertSeverity.critical,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        read: false,
      ),
      AppAlert(
        id: '3',
        type: AlertType.feedingCompleted,
        message: 'Feeding completed: 300 g dispensed',
        severity: AlertSeverity.info,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        read: true,
      ),
    ]);
    _controller.add(List.from(_alerts));
    _unreadController.add(_alerts.where((a) => !a.read).length);
  }

  @override
  Stream<List<AppAlert>> get alertsStream => _controller.stream;

  @override
  Future<List<AppAlert>> getAlerts() async {
    return List.from(_alerts);
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(read: true);
      _controller.add(List.from(_alerts));
      _unreadController.add(_alerts.where((a) => !a.read).length);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _alerts.length; i++) {
      _alerts[i] = _alerts[i].copyWith(read: true);
    }
    _controller.add(List.from(_alerts));
    _unreadController.add(0);
  }

  @override
  Future<void> deleteAlert(String id) async {
    _alerts.removeWhere((a) => a.id == id);
    _controller.add(List.from(_alerts));
    _unreadController.add(_alerts.where((a) => !a.read).length);
  }

  @override
  Stream<int> get unreadCountStream => _unreadController.stream;

  @override
  void dispose() {
    _controller.close();
    _unreadController.close();
  }
}
