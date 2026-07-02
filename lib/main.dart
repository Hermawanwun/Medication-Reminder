import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'providers/obat_provider.dart';
import 'providers/riwayat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final firebaseService = FirebaseService();
  await firebaseService.init();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ObatProvider(firebaseService, notificationService),
        ),
        ChangeNotifierProvider(
          create: (_) => RiwayatProvider(firebaseService),
        ),
      ],
      child: const App(),
    ),
  );
}
