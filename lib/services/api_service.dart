// api_service.dart

// 필요한 패키지 및 모듈 import
import 'package:xml/xml.dart' as xml;
import 'package:dio/dio.dart';

// ApiService 클래스 정의
class ApiService {
  Future<List<Map<String, dynamic>>> fetchHospitalList({
    int page = 1,
    int itemsPerPage = 20,
    String clCd = '',
    String yadmNm = '',
    String sidoCd = '',
    String sgguCd = '',
  }) async {
    const String baseUrl =
        'https://apis.data.go.kr/B551182/hospInfoServicev2/getHospBasisList';
    const String serviceKey =
        'vb5RGCB4/miY9MgndaA0MBC/ltwXWvXKUuPXpnH/Tltya6A33lo5DkNZyfBNOQu+weTfNF156KwbUTnysEDIvw==';

    final Dio dio = Dio();

    // 쿼리 파라미터 설정
    var queryParams = {
      'ServiceKey': serviceKey,
      'numOfRows': '$itemsPerPage',
      'pageNo': '$page',
      'clCd': clCd,
      'sidoCd': sidoCd,
      'sgguCd': sgguCd,
      'yadmNm': yadmNm,
    };

    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    print('병원 API URL : $uri');

    try {
      var response = await dio.get(baseUrl, queryParameters: queryParams);

      if (response.statusCode == 200) {
        var parsedXml = xml.XmlDocument.parse(response.data.toString());

        List<Map<String, dynamic>> nextPageItems = [];

        var items = parsedXml.findAllElements('item');
        items.forEach((item) {
          Map<String, dynamic> hospitalInfo = {};

          item.children.whereType<xml.XmlElement>().forEach((element) {
            hospitalInfo[element.name.local] = element.innerText;
          });

          nextPageItems.add(hospitalInfo);
        });

        return nextPageItems;
      } else {
        print('상태 코드 오류: ${response.statusCode}');
        return [];
      }
    } on DioError catch (e) {
      print('Dio 오류: $e');
      return [];
    } on xml.XmlParserException catch (e) {
      print('XML 파싱 오류: $e');
      return [];
    } catch (e) {
      print('오류: $e');
      return [];
    }
  }
}

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
