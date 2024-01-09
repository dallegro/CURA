// hospital_list_screen.dart

// 필요한 패키지 및 모듈 import
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:cura_health/services/data_fetch_service.dart';
import 'package:cura_health/services/api_service.dart';
import 'package:cura_health/screens/hospital_detail_screen.dart';
import 'package:cura_health/models/hospital_search_delegate.dart'; // Import 추가

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
  final DataFetchService _dataFetchService = DataFetchService();

  List<Map<String, dynamic>> _hospitalList = []; // 병원 목록 데이터
  ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchHospitalList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isLoading = false;
    super.dispose();
  }

  // 화면 빌드 함수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('병원 목록'),
        actions: [
          IconButton(
            onPressed: toggleFilterVisibility,
            icon: Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _showHospitalSearch,
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              User? currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                Navigator.pushNamed(context, '/profile');
              } else {
                Navigator.pushNamed(context, '/login');
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
                    itemBuilder: (context, index) {
                      return buildHospitalListTile(context, index);
                    },
                  )
                : Center(
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text('검색결과가 없습니다.'),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
                            selectedOptions.region = newValue ?? 'default';
                            selectedOptions.district = '';
                          });
                        },
                        items: (sidoData?['regions'] as List<dynamic>?)
                                ?.map<DropdownMenuItem<String>>(
                                  (region) => DropdownMenuItem<String>(
                                    value: region['name'] as String,
                                    child: Text(region['name'] as String),
                                  ),
                                )
                                .toList() ??
                            [
                              DropdownMenuItem<String>(
                                value: 'default',
                                child: Text('Default'),
                              ),
                            ],
                      )
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
          showHospitalDetail(hospital);
        },
      );
    } else {
      return Center(
        child: _isLoading ? CircularProgressIndicator() : Text('검색결과가 없습니다.'),
      );
    }
  }

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

  void _initializeData() async {
    await _fetchJsonData();
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
          page: _currentPage,
        );
        setState(() {
          _hospitalList.addAll(hospitals);
          _isLoading = false;
          _currentPage++;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('병원 목록 가져오기 오류: $e');
        // 에러 발생 시 더 자세한 에러 메시지를 사용자에게 표시할 수 있도록 수정
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('에러 발생'),
            content: Text('병원 목록을 가져오는 중 오류가 발생했습니다: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _fetchJsonData() async {
    hospitalInfoData = await _dataFetchService.fetchHospitalInfo();
    sidoData = await _dataFetchService.fetchSidoData();
    setState(() {}); // 필요한 경우 상태 갱신
  }
}

class FilterOptions {
  String medicalFacilityCode = '전체'; // 선택된 의료 시설 분류 코드
  String region = ''; // 선택된 지역 (시/도)
  String district = ''; // 선택된 지역 (구/군)

  String get filterKeyword {
    String keyword = '';
    if (medicalFacilityCode.isNotEmpty) {
      keyword += medicalFacilityCode;
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
