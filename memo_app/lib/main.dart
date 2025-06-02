import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // 컬러 피커 위젯용 패키지
import 'package:provider/provider.dart'; // 상태 관리를 위한 Provider 패키지
import 'package:table_calendar/table_calendar.dart'; // 달력 위젯 패키지
import 'package:uuid/uuid.dart'; // UUID 생성용 패키지
import 'package:intl/intl.dart'; // 날짜 포맷팅용 패키지

void main() {
  runApp(
    MultiProvider(
      // 여러 Provider를 동시에 등록
      providers: [
        ChangeNotifierProvider(create: (_) => MemoProvider()), // 메모 상태 관리
        ChangeNotifierProvider(create: (_) => CategoryProvider()), // 카테고리 상태 관리
      ],
      child: const MemoApp(),
    ),
  );
}

class MemoApp extends StatelessWidget {
  const MemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFFAF6FA), // 배경색 설정
      ),
      home: const MainScreen(), // 앱의 첫 화면
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
    );
  }
}

// 메모 데이터 모델
class Memo {
  final String id; // 고유 ID
  final String content; // 메모 내용
  final String categoryId; // 카테고리 ID 연결
  final DateTime date; // 메모 날짜
  bool isChecked; // 체크 상태 (완료 여부)
  final DateTime createdAt; // 생성일

  Memo({
    required this.id,
    required this.content,
    required this.categoryId,
    required this.date,
    this.isChecked = false,
    required this.createdAt,
  });
}

// 카테고리 데이터 모델
class Category {
  final String id; // 고유 ID
  final String name; // 카테고리 이름
  final Color color; // 카테고리 색상
  final DateTime createdAt; // 생성일

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });
}

// 메모 상태 관리 클래스
class MemoProvider extends ChangeNotifier {
  final Map<DateTime, List<Memo>> _memos = {}; // 날짜별 메모 목록 저장
  final Uuid _uuid = const Uuid(); // UUID 생성기

  // 특정 날짜의 메모 리스트 반환
  List<Memo> getMemosForDate(DateTime date) => _memos[date] ?? [];

  // 새로운 메모 추가
  void addMemo(DateTime date, String content, String categoryId) {
    final memo = Memo(
      id: _uuid.v4(),
      content: content,
      categoryId: categoryId,
      date: date,
      createdAt: DateTime.now(),
    );
    _memos[date] = [..._memos[date] ?? [], memo]; // 기존 메모에 추가
    notifyListeners(); // UI 갱신 알림
  }

  // 메모 체크 상태 토글 (완료/미완료)
  void toggleCheck(String memoId) {
    for (final entry in _memos.entries) {
      final index = entry.value.indexWhere((memo) => memo.id == memoId);
      if (index != -1) {
        entry.value[index].isChecked = !entry.value[index].isChecked;
        notifyListeners();
        break;
      }
    }
  }

  // 메모 삭제
  void deleteMemo(String memoId) {
    for (final entry in _memos.entries) {
      _memos[entry.key] = entry.value.where((memo) => memo.id != memoId).toList();
    }
    notifyListeners();
  }
}

// 카테고리 상태 관리 클래스
class CategoryProvider extends ChangeNotifier {
  final List<Category> _categories = []; // 카테고리 리스트
  final Uuid _uuid = const Uuid();

  List<Category> get categories => _categories;

  // 새 카테고리 추가
  void addCategory(String name, Color color) {
    _categories.add(Category(
      id: _uuid.v4(),
      name: name,
      color: color,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }
}

// 메인 화면 위젯
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _focusedDay = DateTime.now(); // 현재 포커스 된 날짜 (달력 표시 기준)
  DateTime? _selectedDay = DateTime.now(); // 선택된 날짜
  bool _showSettings = false; // 설정 패널 표시 여부

  // 미리 정의된 색상 목록 (카테고리 색상용)
  final List<Color> _presetColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
  ];

  // 이전 달로 이동
  void _goToPrevMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  // 다음 달로 이동
  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  // 카테고리 추가 다이얼로그 표시
  void _showCategoryAddDialog() {
    showDialog(
      context: context,
      builder: (context) => CategoryAddDialog(presetColors: _presetColors),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 화면 구성: 달력과 메모 영역
            Column(
              children: [
                // 상단 헤더: 이전/다음 달 버튼, 월 타이틀, 설정 버튼
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 28),
                        onPressed: _goToPrevMonth,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            DateFormat('MMMM yyyy').format(_focusedDay),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 28),
                        onPressed: _goToNextMonth,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.settings, size: 28),
                        tooltip: '설정',
                        onPressed: () => setState(() => _showSettings = !_showSettings),
                      ),
                    ],
                  ),
                ),
                // 달력 위젯
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1), // 달력 시작 날짜
                    lastDay: DateTime.utc(2100, 12, 31), // 달력 끝 날짜
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay; // 날짜 선택 시 상태 변경
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarFormat: CalendarFormat.month,
                    headerVisible: false, // 기본 헤더 숨김 (커스텀 헤더 사용)
                    calendarStyle: CalendarStyle(
                      weekendTextStyle: const TextStyle(color: Colors.red),
                      defaultTextStyle: const TextStyle(color: Colors.black),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue[300],
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      // 요일 표시 커스텀 (일요일 빨강, 토요일 파랑)
                      dowBuilder: (context, day) {
                        if (day.weekday == DateTime.sunday) {
                          return const Center(child: Text('Sun', style: TextStyle(color: Colors.red)));
                        }
                        if (day.weekday == DateTime.saturday) {
                          return const Center(child: Text('Sat', style: TextStyle(color: Colors.blue)));
                        }
                        return null;
                      },
                      // 날짜 텍스트 색상 설정
                      defaultBuilder: (context, day, focusedDay) {
                        Color textColor;
                        if (day.weekday == DateTime.sunday) {
                          textColor = Colors.red;
                        } else if (day.weekday == DateTime.saturday) {
                          textColor = Colors.blue;
                        } else {
                          textColor = Colors.black;
                        }
                        return Center(
                          child: Text('${day.day}', style: TextStyle(color: textColor)),
                        );
                      },
                    ),
                  ),
                ),
                // 메모 영역
                Expanded(
                  child: MemoSection(selectedDate: _selectedDay),
                ),
              ],
            ),
            // 설정 패널이 보일 때, 달력 위에 overlay 형태로 표시
            if (_showSettings)
              Positioned(
                top: 80, // 설정 버튼 아래 위치 조절
                right: 16,
                child: SettingsPanel(
                  onAddCategory: _showCategoryAddDialog,
                  onClose: () => setState(() => _showSettings = false),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 설정 패널 위젯 (카테고리 추가 버튼 포함)
class SettingsPanel extends StatelessWidget {
  final VoidCallback onAddCategory; // 카테고리 추가 콜백
  final VoidCallback onClose; // 닫기 콜백

  const SettingsPanel({super.key, required this.onAddCategory, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 타이틀과 닫기 버튼
            Row(
              children: [
                const Text('설정', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(),
            // 카테고리 추가 리스트 아이템
            ListTile(
              leading: const Icon(Icons.add, color: Colors.blue),
              title: const Text('카테고리 추가'),
              onTap: () {
                onAddCategory();
                onClose();
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
}

// 카테고리 추가 다이얼로그 위젯
class CategoryAddDialog extends StatefulWidget {
  final List<Color> presetColors; // 선택 가능한 기본 색상 목록
  const CategoryAddDialog({super.key, required this.presetColors});

  @override
  State<CategoryAddDialog> createState() => _CategoryAddDialogState();
}

class _CategoryAddDialogState extends State<CategoryAddDialog> {
  final TextEditingController _nameController = TextEditingController(); // 카테고리 이름 입력 컨트롤러
  late Color _selectedColor; // 선택된 색상

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.presetColors.first; // 기본 선택 색상 설정
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('카테고리 추가'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 카테고리 이름 입력란
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '카테고리 이름'),
          ),
          const SizedBox(height: 12),
          // 색상 선택 위젯 (원형 버튼 나열)
          Wrap(
            spacing: 8,
            children: widget.presetColors.map((color) {
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 16,
                  child: _selectedColor == color
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        // 취소 버튼
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        // 추가 버튼
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              // 카테고리 추가 후 다이얼로그 닫기
              context.read<CategoryProvider>().addCategory(
                _nameController.text.trim(),
                _selectedColor,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('추가'),
        ),
      ],
    );
  }
}

// 메모 영역 (날짜별 카테고리별 메모 목록 및 입력 UI)
class MemoSection extends StatelessWidget {
  final DateTime? selectedDate; // 선택된 날짜

  const MemoSection({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories; // 카테고리 목록 구독

    if (selectedDate == null) {
      return const SizedBox(); // 날짜가 선택 안되었으면 빈 화면 반환
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 좌측 상단에 선택된 날짜를 yyyy/MM/dd 형식으로 표시
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4, bottom: 8),
            child: Text(
              DateFormat('yyyy/MM/dd').format(selectedDate!),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // 메모 목록을 스크롤 가능하게 표시
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                // 각 카테고리별 메모 섹션 생성
                children: categories.map((category) => _buildCategorySection(context, category, selectedDate!)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리별 메모 UI 빌드 함수
  Widget _buildCategorySection(BuildContext context, Category category, DateTime date) {
    // 해당 날짜와 카테고리에 해당하는 메모만 필터링
    final memos = context.watch<MemoProvider>().getMemosForDate(date)
        .where((memo) => memo.categoryId == category.id)
        .toList();

    final TextEditingController _controller = TextEditingController(); // 메모 입력 컨트롤러

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 이름과 색상 표시 (밑줄 스타일)
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: category.color)),
          ),
          child: Row(
            children: [
              Icon(Icons.circle, color: category.color, size: 16),
              const SizedBox(width: 8),
              Text(
                category.name,
                style: TextStyle(
                  color: category.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        // 메모 리스트 표시 (체크박스, 내용, 삭제 아이콘 포함)
        ListView.builder(
          itemCount: memos.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final memo = memos[index];
            return ListTile(
              leading: Checkbox(
                value: memo.isChecked,
                onChanged: (_) {
                  context.read<MemoProvider>().toggleCheck(memo.id);
                },
              ),
              title: Text(
                memo.content,
                style: TextStyle(
                  decoration: memo.isChecked ? TextDecoration.lineThrough : null,
                  color: memo.isChecked ? Colors.grey : Colors.black,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  context.read<MemoProvider>().deleteMemo(memo.id);
                },
              ),
            );
          },
        ),
        // 새 메모 입력란 및 추가 버튼
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: '새 메모 입력',
                  contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final content = _controller.text.trim();
                if (content.isNotEmpty) {
                  context.read<MemoProvider>().addMemo(date, content, category.id);
                  _controller.clear();
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ],
    );
  }
}
