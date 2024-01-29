// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_app_check_web/firebase_app_check_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cura_health/screens/login_screen.dart';
import 'package:cura_health/screens/profile_management.dart';
import 'package:cura_health/screens/hospital_list_screen.dart';
import 'package:cura_health/screens/register_screen.dart';
import 'package:cura_health/screens/profile_screen.dart';

// firebase_app_check
const String kWebRecaptchaSiteKey = '6LdtR1IpAAAAAEv9-b6LlW8gGpjvkS6UI0Bk1kpk';

Future<void> main() async {
  // 깔끔한 URL을 위해 경로 URL 전략 사용
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 옵션과 함께 Firebase 초기화
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // App Check 활성화
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider(kWebRecaptchaSiteKey),
      androidProvider: AndroidProvider.debug,
    );

    // App Check 토큰을 가져오고 자동 갱신을 활성화
    await FirebaseAppCheck.instance.getToken();
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

    // 계속하기 전에 사용자가 인증되었는지 확인
    await FirebaseAuth.instance.authStateChanges().first;

    // 앱 실행
    runApp(const WebApp());
  } catch (e) {
    print('Firebase 초기화 또는 AppCheck 초기화 오류: $e');
    // 초기화 오류를 적절히 처리합니다.
  }
}

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   try {
//     await FirebaseAppCheck.instance.activate(
//       webProvider: ReCaptchaV3Provider(kWebRecaptchaSiteKey),
//       androidProvider: AndroidProvider.debug,
//     );
// // Pass your reCAPTCHA v3 site key (public key) to activate(). Make sure this
// // key is the counterpart to the secret key you set in the Firebase console.

//     await FirebaseStorage.instance;

//     runApp(const WebApp());
//   } catch (e) {
//     print('Firebase 초기화 오류: $e');
//     // 초기화 오류를 적절히 처리합니다.
//   }
// }

class WebApp extends StatelessWidget {
  const WebApp({Key? key});

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
        '/profile_management': (context) => ProfileManagement(),
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
// │   │   ├── hospital_search_delegate.dart
// │   │   └── hospital_model.dart : 병원 정보와 관련된 데이터 모델을 정의합니다.
// │   │   ├── review_model.dart : 후기 정보와 관련된 데이터 모델을 정의합니다.
// │   ├── components/
// │   │   └── favorite_button.dart: 찜하기 기능을 담당하는 버튼을 정의합니다.
// │   ├── screens/
// │   │   ├── hospital_list_screen.dart: 병원 목록을 표시하고 필터링하는 화면을 관리합니다.
// │   │   ├── hospital_detail_screen.dart: 병원 세부 정보를 표시하고 찜하기 버튼을 관리합니다.
// │   │   ├── login_screen.dart: 사용자 로그인을 처리하는 화면을 관리합니다.
// │   │   ├── register_screen.dart: 사용자 등록을 처리하는 화면을 관리합니다.
// │   │   ├── profile_screen.dart: 사용자 프로필을 표시하고 관리하는 화면을 관리합니다.
// │   │   ├── write_review_screen.dart: 후기를 작성하는 화면을 관리합니다.
// │   │   ├── view_reviews_screen.dart: 후기를 조회하고 삭제하는 화면을 관리합니다
// │   │   └── ...
// │   ├── services/
// │   │   ├── review_service.dart: 후기 작성, 조회 및 삭제와 관련된 비즈니스 로직을 담당하는 서비스
// │   │   ├── favorite_service.dart: 찜하기와 관련된 비즈니스 로직을 담당하는 서비스를 정의합니다.
// │   │   ├── data_fetch_service.dart: 애플리케이션에서 필요한 외부 데이터를 가져오는 서비스를 정의합니다.
// │   │   ├── auth_service.dart: 사용자 인증과 관련된 비즈니스 로직을 담당하는 서비스를 정의합니다.
// │   │   └── api_service.dart: 외부 API와 통신하는 비즈니스 로직을 담당하는 서비스를 정의합니다.
// │   ├── utils/
// │   │   └── snackbar_helper.dart: 스낵바를 표시하는 등의 UI 피드백을 담당하는 헬퍼 함수를 정의합니다
// │   ├── widgets/
// │   │   └── review_tile.dart: 후기를 리스트로 표시하는데 사용되는 위젯을 정의합니다.
// │   └── main.dart
// ├── test/
// └── pubspec.yaml
