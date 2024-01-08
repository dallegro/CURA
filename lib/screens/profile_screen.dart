// profile_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cura_health/services/auth_service.dart';
import 'package:cura_health/utils/snackbar_helper.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final AuthService _auth = AuthService();

  void navigateToProfileManagement(BuildContext context) {
    // 개인정보 관리 페이지로 이동
    // Navigator.pushNamed(context, '/profile_management');
  }

  void navigateToAccountSettings(BuildContext context) {
    // 계정 설정 페이지로 이동
    // Navigator.pushNamed(context, '/account_settings');
  }

// 고객 지원 버튼을 눌렀을 때 실행되는 함수
  void navigateToCustomerSupport(BuildContext context) {
    sendEmail(context);
  }

  void _logout(BuildContext context) async {
    try {
      await _auth.logout();
      Navigator.pushReplacementNamed(context, '/login');
      SnackbarHelper.showSuccess(context, '계정이 성공적으로 로그아웃되었습니다.');
    } catch (e) {
      // 로그아웃 에러 처리
      print('로그아웃 에러: $e');
      SnackbarHelper.showSuccess(context, '로그아웃 중 에러가 발생했습니다.');
    }
  }

  void _deleteAccount(BuildContext context) async {
    try {
      await _auth.deleteAccount();
      Navigator.pushReplacementNamed(context, '/login');
      // 탈퇴 성공 시 사용자에게 메시지 표시
      SnackbarHelper.showSuccess(context, '계정이 성공적으로 삭제되었습니다.');
    } catch (e) {
      // 회원 탈퇴 에러 처리
      print('회원 탈퇴 에러: $e');
      SnackbarHelper.showError(context, '회원 탈퇴 중 에러가 발생했습니다.');
    }
  }

  void sendEmail(BuildContext context) async {
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'daseul.frontend@gmail.com',
      queryParameters: {
        'subject': '문의사항',
        'body': '안녕하세요, 여기에 내용을 입력해주세요.', // 이메일 본문 내용
      },
    );

    if (await canLaunch(_emailLaunchUri.toString())) {
      await launch(_emailLaunchUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이메일 앱을 열 수 없습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 화면'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: Icon(Icons.email),
              title: Text('이메일'),
              subtitle: Text(currentUser?.email ?? '이메일 없음'), // 사용자 이메일 표시
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('개인정보 관리'),
              onTap: () => navigateToProfileManagement(context),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('계정 설정'),
              onTap: () => navigateToAccountSettings(context),
            ),
            ListTile(
              leading: Icon(Icons.support),
              title: Text('고객 지원'),
              onTap: () => navigateToCustomerSupport(context),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('로그아웃'),
              onTap: () => _logout(context),
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('회원 탈퇴'),
              onTap: () => _deleteAccount(context),
            ),
          ],
        ),
      ),
    );
  }
}
