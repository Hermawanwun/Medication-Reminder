import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/obat_provider.dart';
import 'providers/riwayat_provider.dart';
import 'screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pengingat Obat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: Consumer2<ObatProvider, RiwayatProvider>(
        builder: (context, obatProvider, riwayatProvider, _) {
          return const HomeScreen();
        },
      ),
    );
  }
}
