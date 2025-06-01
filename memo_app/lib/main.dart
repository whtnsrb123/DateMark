import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MemoApp()); // 앱 실행
}

// 앱의 루트 위젯
class MemoApp extends StatelessWidget {
  const MemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo App', // 앱 제목
      theme: ThemeData(primarySwatch: Colors.blue), // 테마 설정
      home: const MainScreen(), // 첫 화면으로 MainScreen 설정
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
    );
  }
}

// 메인 화면 위젯
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // 화면 크기 정보 가져오기
    final isWide = size.width > 600; // 가로 600 이상이면 넓은 화면으로 판단

    if (isWide) {
      // 넓은 화면 (예: 태블릿, 데스크탑)에서는 좌우 분할
      return Scaffold(
        appBar: AppBar(title: const Text('Memo App')), // 앱 상단 바
        body: Row(
          children: [
            // 왼쪽 2/3: 달력 영역
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.blue[50], // 배경색 연한 파랑
                child: const CalendarSection(), // 달력 위젯
              ),
            ),
            // 오른쪽 1/3: 메모 영역
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.yellow[50], // 배경색 연한 노랑
                child: const MemoSection(), // 메모 위젯
              ),
            ),
          ],
        ),
      );
    } else {
      // 좁은 화면 (예: 스마트폰)에서는 상하 분할
      return Scaffold(
        appBar: AppBar(title: const Text('Memo App')), // 앱 상단 바
        body: Column(
          children: [
            // 위 2/3: 달력 영역
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.blue[50],
                child: const CalendarSection(),
              ),
            ),
            // 아래 1/3: 메모 영역
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.yellow[50],
                child: const MemoSection(),
              ),
            ),
          ],
        ),
      );
    }
  }
}

// 달력 영역 위젯
class CalendarSection extends StatefulWidget {
  const CalendarSection({super.key});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  DateTime _focusedDay = DateTime.now(); // 현재 보고 있는 날짜
  DateTime? _selectedDay; // 선택된 날짜

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // 바깥 여백
      child: TableCalendar(
        firstDay: DateTime.utc(1900, 1, 1), // 달력의 시작 날짜
        lastDay: DateTime.utc(2500, 12, 31), // 달력의 끝 날짜
        focusedDay: _focusedDay, // 현재 보여주는 달
        selectedDayPredicate: (day) =>
            isSameDay(_selectedDay, day), // 선택된 날인지 확인
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay; // 선택된 날짜 갱신
            _focusedDay = focusedDay; // 포커스된 날짜 갱신
          });
        },
        calendarFormat: CalendarFormat.month, // 월별 보기
        headerStyle: const HeaderStyle(
          formatButtonVisible: false, // 포맷 변경 버튼 숨기기
          titleCentered: true, // 타이틀 가운데 정렬
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: const TextStyle(color: Colors.black), // 기본 날짜 텍스트
          selectedDecoration: BoxDecoration(
            color: Colors.blue[300], // 선택된 날짜 배경색
            shape: BoxShape.circle, // 원형 표시
          ),
          todayDecoration: BoxDecoration(
            color: Colors.blue[100], // 오늘 날짜 배경색
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          // 숫자 색상 요일별로 지정
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
          // 요일 헤더 스타일 커스터마이징
          dowBuilder: (context, day) {
            String text = '';
            switch (day.weekday) {
              case DateTime.sunday:
                text = 'Sun';
                return Center(
                  child: Text(text, style: const TextStyle(color: Colors.red)),
                );
              case DateTime.saturday:
                text = 'Sat';
                return Center(
                  child: Text(text, style: const TextStyle(color: Colors.blue)),
                );
              default:
                // 나머지 요일은 기본(검정)
                return null;
            }
          },
          // 추가적인 커스터마이징 필요시 여기에 작성
        ),
      ),
    );
  }
}

// 메모 영역 위젯 (현재는 임시 UI)
class MemoSection extends StatelessWidget {
  const MemoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('여기에 메모 UI가 들어갑니다', style: TextStyle(fontSize: 18)), // 중앙 텍스트
    );
  }
}
