import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  // 3. Memastikan baris ini ada untuk inisialisasi Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Inisialisasi Firebase di sini
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: TrekkoApp()));
}
