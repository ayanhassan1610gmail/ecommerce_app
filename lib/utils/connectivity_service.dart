import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOffline = false;

  ConnectivityService() {
    _initializeConnectivity();
  }

  bool get isOffline => _isOffline;

  void _initializeConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      final isCurrentlyOffline = result.contains(ConnectivityResult.none);
      _isOffline = isCurrentlyOffline;
    });
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
