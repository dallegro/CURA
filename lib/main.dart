// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cura_health/screens/login_screen.dart';
import 'package:cura_health/screens/hospital_list_screen.dart';
import 'package:cura_health/screens/register_screen.dart';
import 'package:cura_health/screens/profile_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    print('Firebase 초기화 오류: $e');
    // 초기화 오류를 적절히 처리합니다.
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CURA',
      theme: ThemeData(
        fontFamily: 'NotoSans',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black87),
          titleLarge: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(),
        ),
        appBarTheme: const AppBarTheme(
            // backgroundColor: Color(0xFF00FFA4),
            ),
        scaffoldBackgroundColor: Colors.white,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/hospital_list': (context) => HospitalListScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}


// // cura_health/
// ├── android/
// ├── assets/
// │   ├── fonts/
// │   │   ├── NotoSans-Bold.ttf
// │   │   └── NotoSans-Regular.ttf
// │   ├── korean_hospital_info.json
// │   ├── korean_regions.json
// │   └── healthcare_data_structure.json
// ├── ios/
// ├── lib/
// │   ├── models/
// │   │   └── hospital_model.dart
// │   ├── components/
// │   │   ├── custom_button.dart
// │   │   └── ...
// │   ├── screens/
// │   │   ├── hospital_list_screen.dart
// │   │   ├── hospital_detail_screen.dart
// │   │   ├── login_screen.dart
// │   │   ├── register_screen.dart
// │   │   ├── profile_screen.dart
// │   │   └── ...
// │   ├── services/
// │   │   ├── auth_service.dart
// │   │   └── api_service.dart
// │   ├── utils/ 
// │   │   └── snackbar_helper.dart 
// │   └── main.dart
// ├── test/
// └── pubspec.yaml