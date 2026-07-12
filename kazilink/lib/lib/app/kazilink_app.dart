import 'package:flutter/material.dart';

import 'kazilink_theme.dart';
import '../features/auth/auth_gate.dart';

class KaziLinkApp extends StatelessWidget {
  const KaziLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KaziLink ALU',
      theme: KaziLinkTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
