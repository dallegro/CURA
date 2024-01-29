// profile_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cura_health/services/auth_service.dart';
import 'package:cura_health/utils/snackbar_helper.dart';
import 'package:cura_health/services/favorite_service.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authenticationService = AuthService();
  final FavoriteService _favoriteService = FavoriteService();
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    // initState에서 사용자 정보를 가져옵니다.
    currentUser = _authenticationService.getCurrentUser();
  }

  void navigateToProfileManagement(BuildContext context) {
    // 개인정보 관리 페이지로 이동
    Navigator.pushNamed(context, '/profile_management');
  }

  void navigateToAccountSettings(BuildContext context) {
    // 계정 설정 페이지로 이동
    // Navigator.pushNamed(context, '/account_settings');
  }

  void navigateToCustomerSupport(BuildContext context) {
    sendEmail(context);
  }

  void _logout(BuildContext context) async {
    try {
      await _authenticationService.logout();
      Navigator.pushReplacementNamed(context, '/login');
      SnackbarHelper.showSuccess(context, '계정이 성공적으로 로그아웃되었습니다.');
    } catch (e) {
      print('로그아웃 에러: $e');
      SnackbarHelper.showSuccess(context, '로그아웃 중 에러가 발생했습니다.');
    }
  }

  void _deleteAccount(BuildContext context) async {
    try {
      await _authenticationService.deleteAccount();
      Navigator.pushReplacementNamed(context, '/login');
      SnackbarHelper.showSuccess(context, '계정이 성공적으로 삭제되었습니다.');
    } catch (e) {
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
        'body': '안녕하세요, 여기에 내용을 입력해주세요.',
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
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 화면'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipOval(
              child: Container(
                width: 100, // 이미지 원형의 크기를 조절
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(currentUser?.photoURL ?? ''),
                    fit: BoxFit.contain, // 이미지를 원형 영역에 맞추도록 설정
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              // 사용자 이름 표시
              currentUser?.displayName ?? '사용자 이름 없음',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              // 사용자 이메일 표시
              currentUser?.email ?? '이메일 없음',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigateToProfileManagement(context),
              child: Text('개인정보 관리'),
            ),
            ElevatedButton(
              onPressed: () => navigateToAccountSettings(context),
              child: Text('계정 설정'),
            ),
            ElevatedButton(
              onPressed: () => navigateToCustomerSupport(context),
              child: Text('고객 지원'),
            ),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text('로그아웃'),
            ),
            ElevatedButton(
              onPressed: () => _deleteAccount(context),
              child: Text('회원 탈퇴'),
            ),
          ],
        ),
      ),
    );
  }
}
