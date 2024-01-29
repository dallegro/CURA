// profile_management.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cura_health/services/auth_service.dart';
import 'package:cura_health/utils/snackbar_helper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileManagement extends StatefulWidget {
  ProfileManagement({Key? key}) : super(key: key);

  @override
  _ProfileManagementState createState() => _ProfileManagementState();
}

class _ProfileManagementState extends State<ProfileManagement> {
  final AuthService _authenticationService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  late User? currentUser;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _birthdateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 사용자 데이터를 가져오거나 텍스트 컨트롤러를 사용자 데이터로 초기화합니다.
    currentUser = _authenticationService.getCurrentUser();
    _nameController.text = currentUser?.displayName ?? '';
    // 사용자의 생년월일 데이터 가져오기 (Firestore에 저장된 것으로 가정)
    // _birthdateController.text = ''; // 여기에 Firestore에서 가져온 생년월일 데이터 설정
  }

  void _selectImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // 프로필 사진이 선택된 경우
      // TODO: 선택된 이미지를 서버에 업로드하고 사용자 프로필 이미지 URL을 업데이트하는 로직을 구현하세요.
      // String imageUrl = await _authenticationService.uploadProfileImage(pickedFile);
      // currentUser?.updatePhotoURL(imageUrl);
    }
  }

  void _saveChanges() {
    // 사용자 정보를 저장하는 로직을 구현합니다.
    String name = _nameController.text;
    // TODO: 생년월일에 대한 로직을 추가하고, Firestore에 저장된 데이터 업데이트
    // String birthdate = _birthdateController.text;
    // _authenticationService.updateUserData(name, birthdate);
    Navigator.pop(context); // 화면 닫기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('개인정보 관리'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _selectImage,
              child: ClipOval(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(currentUser?.photoURL ?? ''),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _birthdateController,
              decoration: InputDecoration(labelText: '생년월일'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('변경 사항 저장'),
            ),
          ],
        ),
      ),
    );
  }
}
