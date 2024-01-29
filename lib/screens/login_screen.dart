// login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cura_health/services/auth_service.dart';
import 'package:cura_health/utils/snackbar_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // AuthService 인스턴스 생성

  bool obscurePassword = true; // 비밀번호 가리기 여부

  // 로그인 처리
  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    try {
      final userCredential =
          await _authService.signInWithEmailAndPassword(email, password);

      if (userCredential != null) {
        SnackbarHelper.showSuccess(context, '로그인 성공');
        Navigator.pushReplacementNamed(context, '/hospital_list');
      } else {
        SnackbarHelper.showError(context, '이메일 또는 비밀번호가 일치하지 않습니다.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        SnackbarHelper.showError(context, '사용자를 찾을 수 없습니다.');
      } else if (e.code == 'wrong-password') {
        SnackbarHelper.showError(context, '비밀번호가 잘못되었습니다.');
      } else {
        SnackbarHelper.showError(context, '로그인 중 오류가 발생했습니다: ${e.toString()}');
      }
    } catch (e) {
      SnackbarHelper.showError(context, '로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 게스트로 로그인 처리

  Future<void> signInAnonymously(BuildContext context) async {
    try {
      UserCredential? userCredential =
          await FirebaseAuth.instance?.signInAnonymously();

      if (userCredential != null) {
        SnackbarHelper.showSuccess(context, '게스트로 로그인 성공');
        Navigator.pushReplacementNamed(context, '/hospital_list');
      } else {
        SnackbarHelper.showError(context, '게스트 로그인 실패');
      }
    } catch (e) {
      SnackbarHelper.showError(context, '게스트 로그인 실패: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CURA'), // 화면 제목
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: '이메일'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력하세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '비밀번호'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => signInWithEmailAndPassword(context),
                child: const Text('이메일/비밀번호로 로그인'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('회원가입'), // 회원가입 버튼
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => signInAnonymously(context),
                child: const Text('게스트로 시작하기'), // 게스트로 시작하기 버튼
              ),
            ],
          ),
        ),
      ),
    );
  }
}
