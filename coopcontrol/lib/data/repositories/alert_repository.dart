import '../models/app_alert.dart';

/// Abstract repository for alerts
abstract class AlertRepository {
  /// Stream of alerts
  Stream<List<AppAlert>> get alertsStream;

  /// Get all alerts
  Future<List<AppAlert>> getAlerts();

  /// Mark alert as read
  Future<void> markAsRead(String id);

  /// Mark all alerts as read
  Future<void> markAllAsRead();

  /// Delete an alert
  Future<void> deleteAlert(String id);

  /// Get unread count
  Stream<int> get unreadCountStream;

  /// Dispose resources
  void dispose();
}
