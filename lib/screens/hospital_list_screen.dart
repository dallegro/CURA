// hospital_list_screen.dart

// 필요한 패키지 및 모듈 import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cura_health/services/data_fetch_service.dart';
import 'package:cura_health/services/api_service.dart';
import 'package:cura_health/screens/hospital_detail_screen.dart';
import 'package:cura_health/models/hospital_search_delegate.dart'; // Import 추가

// 상수 정의
const String allOption = '전체';

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
  FilterOptions currentOptions = FilterOptions(); // currentOptions 추가

  Map<String, dynamic>? hospitalInfoData;
  Map<String, dynamic>? sidoData;

  final ApiService _apiService = ApiService(); // API 서비스 인스턴스
  final DrugInfo _drugInfo = DrugInfo(); // API 서비스 인스턴스
  final DataFetchService _dataFetchService = DataFetchService();

  final List<Map<String, dynamic>> _hospitalList = []; // 병원 목록 데이터
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러

  IconData getIconForCode(String code) {
    if (hospitalInfoData != null &&
        hospitalInfoData!['HospitalInfo'] != null &&
        hospitalInfoData!['HospitalInfo'][code] != null) {
      // IconData를 상수 값으로 변경
      return Icons.local_hospital; // 예를 들어, 기본 값으로 변경
    } else {
      return Icons.local_hospital;
    }
  }

  Color getColorForCode(String code) {
    if (hospitalInfoData != null &&
        hospitalInfoData!['HospitalInfo'] != null &&
        hospitalInfoData!['HospitalInfo'][code] != null) {
      return Color(int.parse(hospitalInfoData!['HospitalInfo'][code]['color']
          .replaceAll('#', '0xFF')));
    } else {
      // 병원 코드에 매칭되는 정보가 없는 경우 기본 색상 반환
      return Colors.black; // 여기에 기본 색상 지정 가능
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
    currentOptions = getCurrentFilterOptions(); // 현재 필터 옵션 초기화
    _fetchHospitalList(options: currentOptions);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isLoading = false;
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _fetchJsonData();
  }

  // 병원 목록 화면을 새로고침하는 함수
  Future<void> _refresh() async {
    setState(() {
      _hospitalList.clear();
      _currentPage = 1;
    });

    await _fetchHospitalList(options: currentOptions); // 데이터 새로고침
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: GestureDetector(
          onTap: _refresh, // 헤더 클릭 시 새로고침
          child: const Text('병원 목록'),
        ),
        actions: [
          IconButton(
            onPressed: toggleFilterVisibility,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _showHospitalSearch,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: _navigateToProfileOrLogin,
            icon: const Icon(Icons.person),
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
                        ? const CircularProgressIndicator()
                        : const Text('검색결과가 없습니다.'),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }

  // 필터 UI 위젯
  Widget buildFilterOptions() {
    return AnimatedOpacity(
      opacity: isFilterVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: isFilterVisible
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300]!,
                        spreadRadius: 1,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildFilterSection(
                          '의료 시설 분류', buildMedicalFacilityDropdown()),
                      const SizedBox(height: 16),
                      buildFilterSection('시/도', buildSidoDropdown()),
                      const SizedBox(height: 16),
                      buildFilterSection('군/구', buildDistrictDropdown()),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget buildSidoDropdown() {
    return DropdownButton<String>(
      value: selectedOptions.selectedSidoCode ?? '',
      onChanged: (String? newValue) {
        setState(() {
          selectedOptions.selectedSidoCode = newValue!;
          selectedOptions.selectedSgguCode = ''; // 변경 시 군구 초기화
        });
        applyFilters(selectedOptions);
      },
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text(allOption),
        ),
        if (sidoData != null)
          for (var sido in sidoData!['regions'] as List<dynamic>)
            DropdownMenuItem<String>(
              value: sido['code'].toString(),
              child: Text(sido['name'] as String),
            ),
      ],
    );
  }

  Widget buildDistrictDropdown() {
    final selectedSido = selectedOptions.selectedSidoCode;
    List<Map<String, dynamic>>? districts = [];

    if (sidoData != null) {
      final selectedSidoData = (sidoData!['regions'] as List<dynamic>)
          .firstWhere((region) => region['code'] == selectedSido,
              orElse: () => null);

      if (selectedSidoData != null) {
        final dynamic districtsData = selectedSidoData['districts'];
        if (districtsData is List) {
          districts = List<Map<String, dynamic>>.from(districtsData);
        }
      }
    }

    return DropdownButton<String>(
      value: selectedOptions.selectedSgguCode ?? '',
      onChanged: (String? newValue) {
        setState(() {
          selectedOptions.selectedSgguCode = newValue!;
        });
        applyFilters(selectedOptions);
      },
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text(allOption),
        ),
        if (districts != null)
          for (var district in districts!)
            DropdownMenuItem<String>(
              value: district['code'].toString(),
              child: Text(district['name'] as String),
            ),
      ],
    );
  }

  Widget buildMedicalFacilityDropdown() {
    return DropdownButton<String>(
      value: selectedOptions.selectedClCd ?? '',
      onChanged: (String? newValue) {
        setState(() {
          selectedOptions.selectedClCd = newValue!;
        });
        applyFilters(selectedOptions);
      },
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text(allOption),
        ),
        ...(hospitalInfoData?['HospitalInfo'] as Map<String, dynamic>?)
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
    );
  }

  Widget buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  // 병원 목록 타일 위젯 구현
  Widget buildHospitalListTile(BuildContext context, int index) {
    if (index < _hospitalList.length) {
      var hospital = _hospitalList[index];
      var hospitalCode = hospital['code'] ?? ''; // 병원 코드

      // 병원 코드에 해당하는 아이콘과 색상 가져오기
      IconData hospitalIcon = getIconForCode(hospitalCode);
      Color hospitalColor = getColorForCode(hospitalCode);

      return GestureDetector(
        onTap: () {
          showHospitalDetail(hospital);
        },
        child: Card(
          // color: Colors.white, // 이 부분을 추가하거나 변경해주세요.
          surfaceTintColor: Colors.transparent,
          shadowColor: Color.fromARGB(255, 253, 253, 253)!,
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hospitalIcon,
                      color: getColorForCode(hospital['clCd']),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${hospital['clCdNm'] ?? ''} / ${hospital['sidoCdNm'] ?? ''} / ${hospital['clCd'] ?? ''}',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: getColorForCode(hospital['clCd']),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  hospital['yadmNm'] ?? '', // 병원명
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  hospital['addr'] ?? '', // 주소
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('검색결과가 없습니다.'),
      );
    }
  }

  // 필터 옵션 반환 로직
  FilterOptions getCurrentFilterOptions() {
    return FilterOptions(
      searchKeyword: selectedOptions.searchKeyword,
      selectedClCd: selectedOptions.selectedClCd,
      selectedSidoCode: selectedOptions.selectedSidoCode,
      selectedSgguCode: selectedOptions.selectedSgguCode,
    );
  }

  // 스크롤 이벤트 처리 함수
  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      // 현재 필터 옵션을 가져와서 전달
      final currentOptions = getCurrentFilterOptions();
      _fetchHospitalList(options: currentOptions);
    }
  }

  // 검색 어 변경 시 처리 함수
  void _onSearchChanged(String query) {
    final newOptions = FilterOptions(
        selectedClCd: '',
        selectedSidoCode: '',
        selectedSgguCode: '',
        searchKeyword: query);
    _fetchHospitalList(options: newOptions);
  }

  // 병원 검색 화면 표시 함수
  void _showHospitalSearch() {
    showSearch(
      context: context,
      delegate: HospitalSearchDelegate(_hospitalList, _onSearchChanged),
    );
  }

  // 필터 UI 표시/숨김 토글 함수
  void toggleFilterVisibility() {
    setState(() {
      isFilterVisible = !isFilterVisible;
    });
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

  // 필터 적용 메서드
  void applyFilters(FilterOptions options) {
    setState(() {
      // _isLoading = true;
      _hospitalList.clear();
      _currentPage = 1;
    });

    _fetchHospitalList(options: options);
  }

  // 병원 목록 가져오는 함수
  Future<void> _fetchHospitalList({required FilterOptions options}) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      try {
        var hospitals = await _apiService.fetchHospitalList(
          yadmNm: options.searchKeyword,
          page: _currentPage,
          clCd: options.selectedClCd,
          sidoCd: options.selectedSidoCode,
          sgguCd: options.selectedSgguCode,
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
      }
    }
  }

  // JSON 데이터 가져오는 함수
  Future<void> _fetchJsonData() async {
    hospitalInfoData = await _dataFetchService.fetchHospitalInfo();
    // print(hospitalInfoData);
    sidoData = await _dataFetchService.fetchRegionsData();
    setState(() {}); // 필요한 경우 상태 갱신
  }

  void _navigateToProfileOrLogin() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      Navigator.pushNamed(context, '/profile');
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}

class FilterOptions {
  String searchKeyword = ''; // 병원명 검색 키워드
  String selectedClCd = ''; // 선택된 의료 시설 분류 코드
  String selectedSidoCode = ''; // 선택된 시/도 코드
  String selectedSgguCode = ''; // 선택된 구/군 코드

  FilterOptions({
    this.searchKeyword = '',
    this.selectedClCd = '',
    this.selectedSidoCode = '',
    this.selectedSgguCode = '',
  });

  // 필터 키워드를 반환하는 함수
  String get filterKeyword {
    String keyword = '';
    if (selectedClCd.isNotEmpty) {
      keyword += selectedClCd;
    }
    if (selectedSidoCode.isNotEmpty) {
      keyword += selectedSidoCode;
    }
    if (selectedSgguCode.isNotEmpty) {
      keyword += selectedSgguCode;
    }
    return keyword;
  }
}
