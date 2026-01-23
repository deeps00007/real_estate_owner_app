import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // For service locator
import 'core/firebase_service.dart';
import 'features/map/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RealEstateApp());
}

class RealEstateApp extends StatelessWidget {
  const RealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => FirebaseService(),
      child: MaterialApp(
        title: 'Real Estate Owner',
        theme: ThemeData(primarySwatch: Colors.teal),
        home: const MapScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
