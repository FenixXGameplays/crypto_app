import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/route/app_route.dart';
import 'infrastucture/providers/providers.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CryptoProvider())
      ],
      child: MaterialApp.router(
        routerConfig: appRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
