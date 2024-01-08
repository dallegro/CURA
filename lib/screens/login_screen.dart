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
  Future<void> login(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    try {
      final userCredential = await _authService.login(email, password);

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

  Future<void> enterAsGuest(BuildContext context) async {
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
        title: Text('인증 화면'), // 화면 제목
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '이메일', // 이메일 입력란
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: '비밀번호', // 비밀번호 입력란
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => login(context),
                child: Text('로그인'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('회원가입'), // 회원가입 버튼
              ),
              ElevatedButton(
                onPressed: () => enterAsGuest(context),
                child: Text('게스트로 시작하기'), // 게스트로 시작하기 버튼
              ),
            ],
          ),
        ),
      ),
    );
  }
}
