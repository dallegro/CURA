// hospital_list_screen.dart

import 'package:firebase_auth/firebase_auth.dart';

// 필요한 패키지 및 모듈 import
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cura_health/services/api_service.dart';
import 'package:cura_health/screens/hospital_detail_screen.dart';

// 병원 검색을 담당하는 Delegate 클래스
class HospitalSearchDelegate extends SearchDelegate<void> {
  final List<Map<String, dynamic>> hospitalList; // 병원 목록
  final Function(String) onSearch; // 검색 함수
  final ApiService _apiService = ApiService(); // API 서비스 인스턴스

  HospitalSearchDelegate(this.hospitalList, this.onSearch);

  // 검색 입력창 오른쪽에 'Clear' 버튼 표시
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // 검색어 초기화
          showSuggestions(context); // 제안 목록 표시
        },
      ),
    ];
  }

  // 검색 입력창 왼쪽에 'Back' 버튼 표시
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // 검색 창 닫기
      },
    );
  }

  // 검색 결과 표시
  @override
  Widget buildResults(BuildContext context) {
    // 검색어가 비어있으면 안내 메시지 표시
    if (query.isEmpty) {
      return const Center(
        child: Text('검색어를 입력하세요.'),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _apiService.fetchHospitalList(yadmNm: query),
      builder: (context, snapshot) {
        // 데이터 로딩 중인 경우 로딩 표시
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // 에러 발생 시 에러 메시지 표시
          return Center(
            child: Text('에러: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // 검색 결과 없을 경우 안내 메시지 표시
          return const Center(
            child: Text('검색 결과 없음.'),
          );
        } else {
          // 검색 결과가 있는 경우 리스트로 표시
          List<Map<String, dynamic>> searchResults = snapshot.data!;
          return ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final hospital = searchResults[index];
              return ListTile(
                title: Text(hospital['yadmNm']),
                subtitle: Text(hospital['addr']),
                onTap: () {
                  onSearch(query);
                  close(context, null);
                },
              );
            },
          );
        }
      },
    );
  }

  // 검색어 제안 목록 표시
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = hospitalList.where((hospital) =>
        hospital['yadmNm'].toLowerCase().contains(query.toLowerCase()) ||
        hospital['addr'].toLowerCase().contains(query.toLowerCase()));

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final hospital = suggestionList.elementAt(index);
        return ListTile(
          title: Text(hospital['yadmNm']),
          subtitle: Text(hospital['addr']),
          onTap: () {
            onSearch(hospital['yadmNm']);
            close(context, null);
          },
        );
      },
    );
  }
}

// 병원 목록 화면 StatefulWidget 클래스
class HospitalListScreen extends StatefulWidget {
  @override
  _HospitalListScreenState createState() => _HospitalListScreenState();
}

// 병원 목록 화면 State 클래스
class _HospitalListScreenState extends State<HospitalListScreen> {
  bool _isLoading = false; // 데이터 로딩 중 여부
  bool isFilterVisible = false; // 필터 UI 표시 여부
  int _currentPage = 1; // 페이지 번호를 저장하는 변수

  FilterOptions selectedOptions = FilterOptions(); // 선택된 필터 옵션을 관리하는 객체

  Map<String, dynamic>? hospitalInfoData;
  Map<String, dynamic>? sidoData;

  final ApiService _apiService = ApiService(); // API 서비스 인스턴스

  List<Map<String, dynamic>> _hospitalList = []; // 병원 목록 데이터
  ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러
  TextEditingController _searchController = TextEditingController(); // 검색 컨트롤러

  // 스크롤 이벤트 처리 함수
  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchHospitalList();
    }
  }

  // 병원 검색 화면 표시 함수
  void _showHospitalSearch() {
    showSearch(
      context: context,
      delegate: HospitalSearchDelegate(_hospitalList, _onSearchChanged),
    );
  }

  // 검색어 변경 시 처리 함수
  void _onSearchChanged(String query) {
    _fetchHospitalList(searchKeyword: query);
  }

  // 필터 UI 표시/숨김 토글 함수
  void toggleFilterVisibility() {
    setState(() {
      isFilterVisible = !isFilterVisible;
    });
  }

  // 필터 적용 함수
  void _applyFilters(FilterOptions selectedOptions) {
    String filterKeyword = selectedOptions.filterKeyword;
    _fetchHospitalList(searchKeyword: filterKeyword);
  }

  // 병원 세부 정보 표시 함수
  void showHospitalDetail(Map<String, dynamic> hospitalInfo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HospitalDetailScreen(hospitalInfo: hospitalInfo),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchJsonData(); // 병원 정보 및 지역 정보 가져오기
    _fetchHospitalList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 병원 목록 가져오는 함수
  Future<void> _fetchHospitalList({String searchKeyword = ''}) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      try {
        var hospitals = await _apiService.fetchHospitalList(
          yadmNm: searchKeyword,
          page: _currentPage, // 페이지 번호 추가
        );
        setState(() {
          _hospitalList.addAll(hospitals);
          _isLoading = false;
          _currentPage++; // 페이지 번호 증가
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('병원 목록 가져오기 오류: $e');
      }
    }
  }

  Future<void> fetchJsonData() async {
    try {
      // 병원 정보 가져오기
      final hospitalInfoJson =
          await rootBundle.loadString('assets/korean_hospital_Info.json');
      hospitalInfoData = jsonDecode(hospitalInfoJson);
      // print('hospitalInfoData: $hospitalInfoData');
      // 지역 정보 가져오기
      final sidoString =
          await rootBundle.loadString('assets/korean_regions.json');
      sidoData = jsonDecode(sidoString);
      // print('sidoData: $sidoData');
    } catch (error) {
      print('병원 정보 가져오기 에러: $error');
      // 에러 처리
    }
  }

// 필터 UI 위젯
  Widget buildFilterOptions() {
    return AnimatedOpacity(
      opacity: isFilterVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: isFilterVisible
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '의료 시설 분류',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: selectedOptions.medicalFacilityCode ?? '전체',
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedOptions.medicalFacilityCode = newValue!;
                          });
                        },
                        items: [
                          const DropdownMenuItem<String>(
                            value: '전체',
                            child: Text('전체'),
                          ),
                          ...(hospitalInfoData?['HospitalInfo']
                                      as Map<String, dynamic>?)
                                  ?.entries
                                  .map<DropdownMenuItem<String>>(
                                      (MapEntry<String, dynamic> entry) {
                                final String code = entry.key;
                                final Map<String, dynamic> info =
                                    entry.value as Map<String, dynamic>;
                                return DropdownMenuItem<String>(
                                  value: code,
                                  child: Text(info['name'] as String),
                                );
                              })?.toList() ??
                              [],
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '지역 옵션',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: selectedOptions.region,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedOptions.region = newValue!;
                          });
                        },
                        items: sidoData?['regions']
                                ?.map<DropdownMenuItem<String>>(
                                  (region) => DropdownMenuItem<String>(
                                    value: region['name'] as String,
                                    child: Text(region['name'] as String),
                                  ),
                                )
                                .toList() ??
                            [],
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: selectedOptions.district,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedOptions.district = newValue!;
                          });
                        },
                        items: (sidoData?['regions'] as List<dynamic>?)
                                ?.firstWhere(
                                  (region) =>
                                      region['name'] == selectedOptions.region,
                                )['districts']
                                ?.map<DropdownMenuItem<String>>(
                                  (district) => DropdownMenuItem<String>(
                                    value: district['name'] as String,
                                    child: Text(district['name'] as String),
                                  ),
                                )
                                .toList() ??
                            [],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }

  Widget buildHospitalListTile(BuildContext context, int index) {
    if (index < _hospitalList.length) {
      var hospital = _hospitalList[index];
      return ListTile(
        title: Text(hospital['yadmNm']),
        subtitle: Text(hospital['addr']),
        onTap: () {
          showHospitalDetail(hospital); // 병원 정보를 전달하여 이동
        },
      );
    } else {
      return Center(
        child: _isLoading ? CircularProgressIndicator() : Text('검색결과가 없습니다.'),
      );
    }
  }

  // 화면 빌드 함수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('병원 목록'),
        actions: [
          IconButton(
            onPressed: toggleFilterVisibility, // 필터 버튼 클릭 시 필터링 옵션 표시
            icon: Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _showHospitalSearch,
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              // Firebase Authentication으로 현재 사용자 가져오기
              User? currentUser = FirebaseAuth.instance.currentUser;

              if (currentUser != null) {
                // 사용자가 로그인한 경우
                Navigator.pushNamed(context, '/profile'); // 마이페이지로 이동
              } else {
                // 사용자가 로그인하지 않은 경우
                Navigator.pushNamed(context, '/login'); // 로그인 페이지로 이동
              }
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isFilterVisible) buildFilterOptions(),
          Expanded(
              child: _hospitalList.isNotEmpty
                  ? ListView.builder(
                      controller: _scrollController,
                      itemCount: _hospitalList.length + 1,
                      itemBuilder: buildHospitalListTile,
                    )
                  : Center(
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text('검색결과가 없습니다.'),
                    ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 페이지의 맨 위로 스크롤
          _scrollController.animateTo(
            0.0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        child: Icon(Icons.arrow_upward),
      ),
    );
  }
}

class FilterOptions {
  String? medicalFacilityCode = '전체'; // 선택된 의료 시설 분류 코드
  String region = ''; // 선택된 지역 (시/도)
  String district = ''; // 선택된 지역 (구/군)

  String get filterKeyword {
    String keyword = '';
    if (medicalFacilityCode != null) {
      keyword += medicalFacilityCode!;
    }
    if (region.isNotEmpty) {
      keyword += region;
    }
    if (district.isNotEmpty) {
      keyword += district;
    }
    return keyword;
  }
}
