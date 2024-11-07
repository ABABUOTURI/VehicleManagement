import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this file is generated using FlutterFire CLI
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vehicle/Auth/Signup.dart';
import 'package:vehicle/models/parking_slot.dart';
import 'package:vehicle/models/user.dart';
import 'package:vehicle/models/vehicle.dart';


import 'Auth/login.dart';
import 'Database/HiveAdminDb.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Ensure this is correct based on firebase_options.dart
  );

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // Register the UserAdapter (ensure build_runner is run)
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(VehicleAdapter());
  Hive.registerAdapter(ParkingSlotAdapter());

  // Open the boxes before running the app
  await Hive.openBox<User>('users');
  await Hive.openBox<Vehicle>('vehicles');
  await Hive.openBox<ParkingSlot>('parkingSlots');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Parking Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
