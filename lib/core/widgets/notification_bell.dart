// lib/core/widgets/notification_bell.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/notification_service.dart';
import '../../../screens/notifications/notifications_screen.dart';
import '../../../core/constants/colors.dart';class NotificationBell extends StatelessWidget {
  final bool isDark;

  const NotificationBell({
    Key? key,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = NotificationService();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return SizedBox.shrink();
    }

    return StreamBuilder<int>(
      stream: notificationService.getUnseenCount(userId),
      builder: (context, snapshot) {
        final unseenCount = snapshot.data ?? 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ),
                );
              },
              icon: Icon(
                unseenCount > 0
                    ? Icons.notifications_active
                    : Icons.notifications_outlined,
                size: 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            if (unseenCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: unseenCount > 9 ? 5 : 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.purplePrimary, AppColors.purpleLight],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Color(0xFF1E1E1E) : Colors.white,
                      width: 2,
                    ),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      unseenCount > 99 ? '99+' : unseenCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: unseenCount > 9 ? 9 : 10,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}