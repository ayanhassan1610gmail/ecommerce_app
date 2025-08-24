import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'check_status.dart';
import 'package:provider/provider.dart';
import '../widgets/connectivity_notifier.dart';
import '../providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'utils/connectivity_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint(navigatorKey.toString());
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => AuthProviders()),
        ChangeNotifierProxyProvider<AuthProviders, CartProvider>(
          create: (context) => CartProvider(
            Provider.of<AuthProviders>(context, listen: false),
          ),
          update: (_, authProvider, previousCartProvider) =>
              CartProvider(authProvider),
        ),
        Provider<ConnectivityService>(
          create: (_) => ConnectivityService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'Ecommerce App',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 60),
              textStyle: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: const Color(0xff4c505b),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: const Scaffold(
          body: ConnectivityNotifier(
            child: CheckStatus(),
          ),
        ),
      ),
    );
  }
}
