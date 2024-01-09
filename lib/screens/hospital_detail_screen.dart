// HospitalDetailScreen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'URL을 열 수 없습니다: $url';
  }
}

class HospitalDetailScreen extends StatelessWidget {
  final Map<String, dynamic> hospitalInfo;

  const HospitalDetailScreen({Key? key, required this.hospitalInfo})
      : super(key: key);

  Widget buildListTile(String title, dynamic value, {Function()? onTap}) {
    return ListTile(
      title: Text(title),
      subtitle: value != null ? Text(value) : Text('$title 없음'),
      onTap: onTap != null ? () => onTap() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('병원 상세 정보'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildListTile('병원명', hospitalInfo['yadmNm']),
              buildListTile('주소', hospitalInfo['addr']),
              buildListTile('전화번호', hospitalInfo['telno']),
              buildListTile('병원 URL', hospitalInfo['hospUrl'], onTap: () {
                _launchURL(hospitalInfo['hospUrl']);
              }),
              buildListTile('시도코드명', hospitalInfo['시도코드명']),
              buildListTile('시군구명', hospitalInfo['sgguCdNm']),
              buildListTile('읍면동명', hospitalInfo['emdongNm']),
              buildListTile('우편번호', hospitalInfo['postNo']),
              buildListTile('시군구코드', hospitalInfo['sgguCd']),
              buildListTile('시도코드', hospitalInfo['sidoCd']),
              buildListTile('요양기관 번호', hospitalInfo['ykiho']),
              buildListTile('병원 종류 코드', hospitalInfo['clCd']),
              buildListTile('병원 종류명', hospitalInfo['clCdNm']),
              buildListTile('입원환자수', hospitalInfo['cmdcResdntCnt']),
              buildListTile('외래환자수', hospitalInfo['cmdcSdrCnt']),
              buildListTile('응급실', hospitalInfo['pnursCnt']),
              buildListTile('의사 총 인원수', hospitalInfo['drTotCnt']),
              buildListTile('좌표(X)', hospitalInfo['XPos']),
              buildListTile('좌표(Y)', hospitalInfo['YPos']),
              buildListTile('거리', hospitalInfo['distance']),
              buildListTile('일반의 인원수', hospitalInfo['detyGdrCnt']),
              buildListTile('인턴 인원수', hospitalInfo['detyIntnCnt']),
              buildListTile('레지던트 인원수', hospitalInfo['detyResdntCnt']),
              buildListTile('전문의 인원수', hospitalInfo['detySdrCnt']),
              buildListTile('일반외래 인원수', hospitalInfo['cmdcGdrCnt']),
              buildListTile('인턴외래 인원수', hospitalInfo['cmdcIntnCnt']),
              buildListTile('전문의외래 인원수', hospitalInfo['mdeptResdntCnt']),
              buildListTile('일반내과 의사 인원수', hospitalInfo['mdeptGdrCnt']),
              buildListTile('인턴내과 의사 인원수', hospitalInfo['mdeptIntnCnt']),
              buildListTile('전문의내과 의사 인원수', hospitalInfo['mdeptSdrCnt']),
              buildListTile('설립일', hospitalInfo['estbDd']),
            ],
          ),
        ),
      ),
    );
  }
}
