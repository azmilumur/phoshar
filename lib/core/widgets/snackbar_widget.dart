import 'package:flutter/material.dart';

enum NotificationType { success, error, warning, info }

class AppNotification {
  static void show(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final config = _getNotificationConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon ?? config.icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.color,
        behavior: behavior,
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.success,
      duration: duration ?? const Duration(seconds: 3),
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.error,
      duration: duration ?? const Duration(seconds: 4),
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.warning,
      duration: duration ?? const Duration(seconds: 3),
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    Duration? duration,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.info,
      duration: duration ?? const Duration(seconds: 3),
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static _NotificationConfig _getNotificationConfig(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return _NotificationConfig(
          color: Colors.green,
          icon: Icons.check_circle_outline,
        );
      case NotificationType.error:
        return _NotificationConfig(
          color: Colors.red,
          icon: Icons.error_outline,
        );
      case NotificationType.warning:
        return _NotificationConfig(
          color: Colors.orange,
          icon: Icons.warning_amber_outlined,
        );
      case NotificationType.info:
        return _NotificationConfig(
          color: Colors.blue,
          icon: Icons.info_outline,
        );
    }
  }
}

class _NotificationConfig {
  final Color color;
  final IconData icon;

  _NotificationConfig({required this.color, required this.icon});
}

// ============================================
// USAGE EXAMPLES
// ============================================

// Basic usage with type-specific methods:
// AppNotification.success(context, 'Operation completed successfully!');
// AppNotification.error(context, 'Something went wrong!');
// AppNotification.warning(context, 'Please check your input');
// AppNotification.info(context, 'New update available');

// Advanced usage with custom options:
// AppNotification.show(
//   context,
//   message: 'File deleted',
//   type: NotificationType.warning,
//   duration: Duration(seconds: 5),
//   icon: Icons.delete,
//   actionLabel: 'UNDO',
//   onAction: () {
//     // Handle undo action
//   },
// );

// With action button:
// AppNotification.error(
//   context,
//   'Connection failed',
//   actionLabel: 'RETRY',
//   onAction: () {
//     // Retry logic
//   },
// );
