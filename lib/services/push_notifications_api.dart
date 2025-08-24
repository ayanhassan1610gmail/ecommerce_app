// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:app_settings/app_settings.dart';
//
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
// class FirebaseApi {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//   Future<void> initNotifications() async {
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       provisional: true,
//     );
//     final fCMToken = await _firebaseMessaging.getToken();
//     debugPrint('Token: $fCMToken');
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       debugPrint('User granted permission');
//
//       FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
//     } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
//       debugPrint('User declined or has not accepted permission');
//       _showPermissionDialog();
//       // _showPermissionDialogWithDelay();
//     } else {
//       debugPrint('Permission status: ${settings.authorizationStatus}');
//     }
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       debugPrint(
//           'Message received in foreground: ${message.notification?.title}');
//     });
//   }
//
//   void _showPermissionDialog() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (navigatorKey.currentContext != null) {
//         showDialog(
//           context: navigatorKey.currentContext!,
//           builder: (context) =>
//               AlertDialog(
//                 title: const Text('Enable Notifications'),
//                 content: const Text(
//                     'Please enable notifications to stay updated with new offers and products.'),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     child: const Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                       AppSettings.openAppSettings();
//                     },
//                     child: const Text('Settings'),
//                   ),
//                 ],
//               ),
//         );
//       } else {
//         debugPrint("navigatorKey.currentContext is null. Retrying...");
//         Future.delayed(const Duration(seconds: 1),
//             _showPermissionDialog); // Retry after 1 second
//       }
//     });
//   }
//
//
//   Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
//     debugPrint('Handling a background message: ${message.notification?.title}');
//   }
// }


import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications(BuildContext context) async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    final fCMToken = await _firebaseMessaging.getToken();
    debugPrint('Token: $fCMToken');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('User declined or has not accepted permission');

      if (context.mounted) {
        _showPermissionDialog(context);
      }
    } else {
      debugPrint('Permission status: ${settings.authorizationStatus}');
    }

    if (context.mounted) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
            'Message received in foreground: ${message.notification?.title}');
      });
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Notifications'),
        content: const Text(
            'Please enable notifications to stay updated with new offers and products.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppSettings.openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.notification?.title}');
}
