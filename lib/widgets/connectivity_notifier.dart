import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/connectivity_service.dart';

class ConnectivityNotifier extends StatefulWidget {
  final Widget child;

  const ConnectivityNotifier({super.key, required this.child});

  @override
  State<ConnectivityNotifier> createState() => _ConnectivityNotifierState();
}

class _ConnectivityNotifierState extends State<ConnectivityNotifier> {
  late final ConnectivityService _connectivityService;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      final isOffline = result.contains(ConnectivityResult.none);

      if (isOffline) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are offline'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ConnectivityService>.value(
      value: _connectivityService,
      child: widget.child,
    );
  }
}
