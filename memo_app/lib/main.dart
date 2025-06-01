import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MemoApp());
}

class MemoApp extends StatelessWidget {
  const MemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 화면 크기 정보 가져오기
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600; // 600보다 넓으면 맥북/아이패드 레이아웃

    if (isWide) {
      // 맥북/아이패드: 좌우 분할
      return Scaffold(
        appBar: AppBar(title: const Text('Memo App')),
        body: Row(
          children: [
            // 왼쪽 2/3: 달력
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.blue[50],
                child: const CalendarSection(),
              ),
            ),
            // 오른쪽 1/3: 메모
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
    } else {
      // 아이폰: 상하 분할
      return Scaffold(
        appBar: AppBar(title: const Text('Memo App')),
        body: Column(
          children: [
            // 위 2/3: 달력
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.blue[50],
                child: const CalendarSection(),
              ),
            ),
            // 아래 1/3: 메모
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

// 달력 영역
class CalendarSection extends StatefulWidget {
  const CalendarSection({super.key});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarFormat: CalendarFormat.month,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }
}

// 메모 영역(임시)
class MemoSection extends StatelessWidget {
  const MemoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '여기에 메모 UI가 들어갑니다',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
