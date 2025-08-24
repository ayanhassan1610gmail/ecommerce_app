// import 'package:flutter/material.dart';
// import '../screens/sign_in_screen.dart';
// import 'services/push_notifications_api.dart';
// import 'utils/user_secure_storage.dart';
// import 'screens/home_screen.dart';
//
// class CheckStatus extends StatefulWidget {
//   const CheckStatus({super.key});
//
//   @override
//   State<CheckStatus> createState() => _CheckStatusState();
// }
//
// class _CheckStatusState extends State<CheckStatus> {
//   final FirebaseApi _firebaseApi = FirebaseApi();
//   @override
//   void initState() {
//     super.initState();
//     _initializeNotifications();
//   }
//
//   Future<void> _initializeNotifications() async {
//     await _firebaseApi.initNotifications(context);
//   }
//   Future<bool> checkLoginStatus() async {
//     final uid = await UserSecureStorage.read('uid');
//     debugPrint('uid: $uid');
//     if (uid == null) return false;
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) => FutureBuilder(
//         future: checkLoginStatus(),
//         builder: (context, snapshot) {
//           if (snapshot.data == false) {
//             return const SignInScreen();
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           return const HomeScreen();
//         },
//       );
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/sign_in_screen.dart';
import '../screens/home_screen.dart';
import 'services/push_notifications_api.dart';
import 'utils/user_secure_storage.dart';

class CheckStatus extends StatefulWidget {
  const CheckStatus({super.key});

  @override
  State<CheckStatus> createState() => _CheckStatusState();
}

class _CheckStatusState extends State<CheckStatus> {
  final FirebaseApi _firebaseApi = FirebaseApi();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      await _firebaseApi.initNotifications(context);
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<bool> checkLoginStatus() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final uid = authProvider.getCurrentUserId();
    debugPrint('Firebase UID: $uid');
    if (uid != null) {
      final storedUid = await UserSecureStorage.read('uid');
      debugPrint('Stored UID: $storedUid');
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Error checking login status. Please try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (snapshot.data == false) {
          return const SignInScreen();
        }
        return const HomeScreen();
      },
    );
  }
}
