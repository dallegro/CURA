// api_service.dart

// 의료기관 검색결과 제공 API (요양기관명,주소,전화번호,URL)
// /getHospBasisList - 병원기본목록
// └── ServiceKey (string) (query) - 서비스키
//     └── pageNo (string) (query) - 페이지번호
//         └── numOfRows (string) (query) - 한 페이지 결과 수
//             └── sidoCd (string) (query) - 시도코드
//                 └── sgguCd (string) (query) - 시군구코드
//                     └── emdongNm (string) (query) - 읍면동명
//                         └── yadmNm (string) (query) - 병원명 (UTF-8 인코딩 필요)
//                             └── zipCd (string) (query) - 분류코드 (활용가이드 참조)
//                                 └── clCd (string) (query) - 종별코드 (활용가이드 참조)
//                                     └── dgsbjtCd (string) (query) - 진료과목코드 (활용가이드 참조)
//                                         └── xPos (string) (query) - x좌표 (소수점 15)
//                                             └── yPos (string) (query) - y좌표 (소수점 15)
//                                                 └── radius (string) (query) - 단위: 미터(m)

// 필요한 패키지 및 모듈 import
import 'package:xml/xml.dart' as xml;
import 'package:dio/dio.dart';

// ApiService 클래스 정의
class ApiService {
  // API 엔드포인트 및 키 상수 정의
  static const String baseUrl =
      'https://apis.data.go.kr/B551182/hospInfoServicev2/getHospBasisList';
  static const String serviceKey =
      'vb5RGCB4/miY9MgndaA0MBC/ltwXWvXKUuPXpnH/Tltya6A33lo5DkNZyfBNOQu+weTfNF156KwbUTnysEDIvw==';

  final Dio dio = Dio(); // Dio 인스턴스 생성

  // 병원 목록을 가져오는 비동기 함수
  Future<List<Map<String, dynamic>>> fetchHospitalList({
    String sidoCd = '',
    String yadmNm = '',
    int itemsPerPage = 20, // 페이지당 항목 수
    int page = 1, // 페이지 번호 추가
  }) async {
    // 쿼리 파라미터 설정
    var queryParams = {
      'ServiceKey': serviceKey,
      'numOfRows': '$itemsPerPage',
      'pageNo': '$page', // 페이지 번호 추가
      'sidoCd': sidoCd,
      'yadmNm': yadmNm,
    };

    var uri = Uri.parse(baseUrl);
    uri = uri.replace(queryParameters: queryParams);
    print('병원 API URL : $uri');

    try {
      var response = await dio.get(baseUrl, queryParameters: queryParams);

      if (response.statusCode == 200) {
        var parsedXml = xml.XmlDocument.parse(response.data.toString());

        List<Map<String, dynamic>> nextPageItems = [];

        var items = parsedXml.findAllElements('item');
        items.forEach((item) {
          nextPageItems.add({
            'yadmNm': item.findElements('yadmNm').first.innerText,
            'addr': item.findElements('addr').first.innerText,
          });
        });

        // 페이지 관리 로직 추가

        return nextPageItems;
      } else {
        // 오류 핸들링
        print('Failed with status code: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      // Dio 예외 처리
      print('Dio error: $e');
      return [];
    } on xml.XmlParserException catch (e) {
      // XML 파싱 예외 처리
      print('XML parsing exception: $e');
      return [];
    } catch (e) {
      // 일반적인 오류 처리
      print('Error: $e');
      return [];
    }
  }
}
