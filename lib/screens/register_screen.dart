//register_screen.dart
import 'package:flutter/material.dart';
import 'package:cura_health/services/auth_service.dart';
import 'package:cura_health/utils/snackbar_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); // 이메일 정규표현식
    return emailRegex.hasMatch(email);
  }

  Future<void> _register() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (!isEmailValid(email)) {
      SnackbarHelper.showError(context, '올바른 이메일 형식이 아닙니다.');
      return;
    }
    if (password != confirmPassword) {
      SnackbarHelper.showError(context, '비밀번호가 일치하지 않습니다.');
      return;
    }

    try {
      String? registerSuccess = await AuthService().register(email, password);
      if (registerSuccess == null) {
        SnackbarHelper.showSuccess(context, '회원가입이 성공적으로 완료되었습니다.');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // 더 세분화된 에러 처리
        if (registerSuccess == 'weak-password') {
          SnackbarHelper.showError(context, '비밀번호가 취약합니다. 다른 비밀번호를 시도해주세요.');
        } else if (registerSuccess == 'email-already-in-use') {
          SnackbarHelper.showError(
              context, '이미 사용 중인 이메일 주소입니다. 다른 이메일을 입력해주세요.');
        } else {
          SnackbarHelper.showError(context, '회원가입 중 오류가 발생했습니다.');
        }
      }
    } catch (e) {
      SnackbarHelper.showError(context, '회원가입 중 오류가 발생했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
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
                  labelText: '이메일',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
