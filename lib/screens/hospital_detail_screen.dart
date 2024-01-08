// HospitalDetailScreen.dart
import 'package:flutter/material.dart';

class HospitalDetailScreen extends StatelessWidget {
  final Map<String, dynamic> hospitalInfo;

  const HospitalDetailScreen({Key? key, required this.hospitalInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('병원 상세 정보'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('병원명: ${hospitalInfo['yadmNm']}'),
            Text('주소: ${hospitalInfo['addr']}'),
            // 다른 정보들을 추가하세요.
          ],
        ),
      ),
    );
  }
}
