//hospital_model.dart
//병원 정보 모델을 정의하는데 사용

class HospitalModel {
  // 결과 헤더 정보를 담는 Header 클래스
  Header header;

  // 병원 정보를 담는 Body 클래스
  Body body;

  // HospitalModel의 생성자
  HospitalModel({required this.header, required this.body});

  // JSON 형식의 Map을 HospitalModel 객체로 변환하는 팩토리 메서드
  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      header: Header.fromJson(json['header']),
      body: Body.fromJson(json['body']),
    );
  }

  // HospitalModel 객체를 JSON 형식의 Map으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['header'] = this.header.toJson();
    data['body'] = this.body.toJson();
    return data;
  }
}

// 결과 헤더 정보를 담는 Header 클래스
class Header {
  // 결과 코드
  String resultCode;

  // 결과 메시지
  String resultMsg;

  // Header의 생성자
  Header({required this.resultCode, required this.resultMsg});

  // JSON 형식의 Map을 Header 객체로 변환하는 팩토리 메서드
  factory Header.fromJson(Map<String, dynamic> json) {
    return Header(
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
    );
  }

  // Header 객체를 JSON 형식의 Map으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['resultCode'] = this.resultCode;
    data['resultMsg'] = this.resultMsg;
    return data;
  }
}

// 병원 정보를 담는 Body 클래스
class Body {
  // 병원 정보 리스트
  List<Item> items;

  // 조회된 결과의 행 수
  int numOfRows;

  // 현재 페이지 번호
  int pageNo;

  // 전체 결과 행 수
  int totalCount;

  // Body의 생성자
  Body({
    required this.items,
    required this.numOfRows,
    required this.pageNo,
    required this.totalCount,
  });

  // JSON 형식의 Map을 Body 객체로 변환하는 팩토리 메서드
  factory Body.fromJson(Map<String, dynamic> json) {
    var itemList = json['items'] as List;
    List<Item> itemsList =
        itemList.map((itemJson) => Item.fromJson(itemJson)).toList();

    return Body(
      items: itemsList,
      numOfRows: json['numOfRows'],
      pageNo: json['pageNo'],
      totalCount: json['totalCount'],
    );
  }

  // Body 객체를 JSON 형식의 Map으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['items'] = this.items.map((item) => item.toJson()).toList();
    data['numOfRows'] = this.numOfRows;
    data['pageNo'] = this.pageNo;
    data['totalCount'] = this.totalCount;
    return data;
  }
}

// 병원 정보를 담는 Item 클래스
class Item {
  String cmdcResdntCnt; // 의사 총 인원수
  String cmdcSdrCnt; // 외래 의사 수
  String pnursCnt; // 간호사 수
  String XPos; // X 좌표
  String YPos; // Y 좌표
  String distance; // 거리
  String detyGdrCnt; // 상세 정보_성별 인원수
  String detyIntnCnt; // 상세 정보_인턴 인원수
  String detyResdntCnt; // 상세 정보_레지던트 인원수
  String detySdrCnt; // 상세 정보_전문의 인원수
  String cmdcGdrCnt; // 전문의 인원수
  String cmdcIntnCnt; // 인턴 인원수
  String mdeptResdntCnt; // 레지던트 인원수
  String drTotCnt; // 총 의사 수
  String mdeptGdrCnt; // 상세 정보_전문의 인원수
  String mdeptIntnCnt; // 상세 정보_인턴 인원수
  String telno; // 전화번호
  String hospUrl; // 병원 홈페이지 URL
  String estbDd; // 설립일
  int sgguCdNm; // 시군구 코드명
  String emdongNm; // 읍면동 이름
  String postNo; // 우편번호
  int addr; // 주소
  int sidoCdNm; // 시도 코드명
  int sgguCd; // 시군구 코드
  String ykiho; // 암호화 병원 기호
  String yadmNm; // 병원명
  String clCd; // 종별 코드
  String clCdNm; // 종별 코드명
  int sidoCd; // 시도 코드
  String mdeptSdrCnt; // 상세 정보_전문의 인원수

  // Item 클래스의 생성자
  Item({
    required this.cmdcResdntCnt,
    required this.cmdcSdrCnt,
    required this.pnursCnt,
    required this.XPos,
    required this.YPos,
    required this.distance,
    required this.detyGdrCnt,
    required this.detyIntnCnt,
    required this.detyResdntCnt,
    required this.detySdrCnt,
    required this.cmdcGdrCnt,
    required this.cmdcIntnCnt,
    required this.mdeptResdntCnt,
    required this.drTotCnt,
    required this.mdeptGdrCnt,
    required this.mdeptIntnCnt,
    required this.telno,
    required this.hospUrl,
    required this.estbDd,
    required this.sgguCdNm,
    required this.emdongNm,
    required this.postNo,
    required this.addr,
    required this.sidoCdNm,
    required this.sgguCd,
    required this.ykiho,
    required this.yadmNm,
    required this.clCd,
    required this.clCdNm,
    required this.sidoCd,
    required this.mdeptSdrCnt,
  });

  // JSON 형식의 Map을 Item 객체로 변환하는 팩토리 메서드
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      cmdcResdntCnt: json['cmdcResdntCnt'],
      cmdcSdrCnt: json['cmdcSdrCnt'],
      pnursCnt: json['pnursCnt'],
      XPos: json['XPos'],
      YPos: json['YPos'],
      distance: json['distance'],
      detyGdrCnt: json['detyGdrCnt'],
      detyIntnCnt: json['detyIntnCnt'],
      detyResdntCnt: json['detyResdntCnt'],
      detySdrCnt: json['detySdrCnt'],
      cmdcGdrCnt: json['cmdcGdrCnt'],
      cmdcIntnCnt: json['cmdcIntnCnt'],
      mdeptResdntCnt: json['mdeptResdntCnt'],
      drTotCnt: json['drTotCnt'],
      mdeptGdrCnt: json['mdeptGdrCnt'],
      mdeptIntnCnt: json['mdeptIntnCnt'],
      telno: json['telno'],
      hospUrl: json['hospUrl'],
      estbDd: json['estbDd'],
      sgguCdNm: json['sgguCdNm'],
      emdongNm: json['emdongNm'],
      postNo: json['postNo'],
      addr: json['addr'],
      sidoCdNm: json['sidoCdNm'],
      sgguCd: json['sgguCd'],
      ykiho: json['ykiho'],
      yadmNm: json['yadmNm'],
      clCd: json['clCd'],
      clCdNm: json['clCdNm'],
      sidoCd: json['sidoCd'],
      mdeptSdrCnt: json['mdeptSdrCnt'],
    );
  }

  // Item 객체를 JSON 형식의 Map으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['cmdcResdntCnt'] = this.cmdcResdntCnt;
    data['cmdcSdrCnt'] = this.cmdcSdrCnt;
    data['pnursCnt'] = this.pnursCnt;
    data['XPos'] = this.XPos;
    data['YPos'] = this.YPos;
    data['distance'] = this.distance;
    data['detyGdrCnt'] = this.detyGdrCnt;
    data['detyIntnCnt'] = this.detyIntnCnt;
    data['detyResdntCnt'] = this.detyResdntCnt;
    data['detySdrCnt'] = this.detySdrCnt;
    data['cmdcGdrCnt'] = this.cmdcGdrCnt;
    data['cmdcIntnCnt'] = this.cmdcIntnCnt;
    data['mdeptResdntCnt'] = this.mdeptResdntCnt;
    data['drTotCnt'] = this.drTotCnt;
    data['mdeptGdrCnt'] = this.mdeptGdrCnt;
    data['mdeptIntnCnt'] = this.mdeptIntnCnt;
    data['telno'] = this.telno;
    data['hospUrl'] = this.hospUrl;
    data['estbDd'] = this.estbDd;
    data['sgguCdNm'] = this.sgguCdNm;
    data['emdongNm'] = this.emdongNm;
    data['postNo'] = this.postNo;
    data['addr'] = this.addr;
    data['sidoCdNm'] = this.sidoCdNm;
    data['sgguCd'] = this.sgguCd;
    data['ykiho'] = this.ykiho;
    data['yadmNm'] = this.yadmNm;
    data['clCd'] = this.clCd;
    data['clCdNm'] = this.clCdNm;
    data['sidoCd'] = this.sidoCd;
    data['mdeptSdrCnt'] = this.mdeptSdrCnt;
    return data;
  }
}

class HospitalInfo {
  final String name;
  final String icon;
  final String color;

  HospitalInfo({required this.name, required this.icon, required this.color});

  factory HospitalInfo.fromJson(Map<String, dynamic> json) {
    return HospitalInfo(
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '',
    );
  }
}
