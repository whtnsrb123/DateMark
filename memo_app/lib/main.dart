import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemoProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
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
        scaffoldBackgroundColor: const Color(0xFFFAF6FA), // 달력과 메모 영역 동일한 배경색
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 데이터 모델
class Memo {
  final String id;
  final String content;
  final String categoryId;
  final DateTime date;
  bool isChecked;
  final DateTime createdAt;

  Memo({
    required this.id,
    required this.content,
    required this.categoryId,
    required this.date,
    this.isChecked = false,
    required this.createdAt,
  });
}

class Category {
  final String id;
  final String name;
  final Color color;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });
}

// 상태 관리
class MemoProvider extends ChangeNotifier {
  final Map<DateTime, List<Memo>> _memos = {};
  final Uuid _uuid = const Uuid();

  List<Memo> getMemosForDate(DateTime date) => _memos[date] ?? [];

  void addMemo(DateTime date, String content, String categoryId) {
    final memo = Memo(
      id: _uuid.v4(),
      content: content,
      categoryId: categoryId,
      date: date,
      createdAt: DateTime.now(),
    );
    _memos[date] = [..._memos[date] ?? [], memo];
    notifyListeners();
  }

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

  void deleteMemo(String memoId) {
    for (final entry in _memos.entries) {
      _memos[entry.key] = entry.value.where((memo) => memo.id != memoId).toList();
    }
    notifyListeners();
  }
}

class CategoryProvider extends ChangeNotifier {
  final List<Category> _categories = [];
  final Uuid _uuid = const Uuid();

  List<Category> get categories => _categories;

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

// 메인 화면
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now(); // 앱 실행 시 오늘 날짜 자동 선택
  bool _showCategoryAdd = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memo App')),
      body: Column(
        children: [
          Stack(
            children: [
              CalendarSection(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
              ),
              Positioned(
                top: 12,
                right: 24,
                child: IconButton(
                  icon: const Icon(Icons.add, size: 28),
                  onPressed: () => setState(() => _showCategoryAdd = !_showCategoryAdd),
                ),
              ),
              if (_showCategoryAdd)
                Positioned(
                  top: 56,
                  right: 24,
                  child: CategoryAddPanel(
                    presetColors: _presetColors,
                    onAdd: () => setState(() => _showCategoryAdd = false),
                    onCancel: () => setState(() => _showCategoryAdd = false),
                  ),
                ),
            ],
          ),
          Expanded(
            child: MemoSection(selectedDate: _selectedDay),
          ),
        ],
      ),
    );
  }
}

// 달력 위젯
class CalendarSection extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime, DateTime) onDaySelected;

  const CalendarSection({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
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
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            if (day.weekday == DateTime.sunday) {
              return const Center(child: Text('Sun', style: TextStyle(color: Colors.red)));
            }
            return null;
          },
        ),
      ),
    );
  }
}

// 카테고리 추가 패널
class CategoryAddPanel extends StatefulWidget {
  final List<Color> presetColors;
  final VoidCallback onAdd;
  final VoidCallback onCancel;

  const CategoryAddPanel({super.key, required this.presetColors, required this.onAdd, required this.onCancel});

  @override
  State<CategoryAddPanel> createState() => _CategoryAddPanelState();
}

class _CategoryAddPanelState extends State<CategoryAddPanel> {
  final TextEditingController _nameController = TextEditingController();
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.presetColors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('카테고리 추가', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '카테고리 이름'),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.trim().isNotEmpty) {
                      context.read<CategoryProvider>().addCategory(
                        _nameController.text.trim(),
                        _selectedColor,
                      );
                      widget.onAdd();
                    }
                  },
                  child: const Text('추가'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 메모 영역
class MemoSection extends StatelessWidget {
  final DateTime? selectedDate;

  const MemoSection({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 좌측 상단에 작은 날짜 표시
          if (selectedDate != null)
            Text(
              DateFormat('yyyy/MM/dd').format(selectedDate!),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 16),
          // 메모 목록
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: categories.map((category) => _buildCategorySection(context, category, selectedDate!)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, Category category, DateTime date) {
    final memos = context.watch<MemoProvider>().getMemosForDate(date)
        .where((memo) => memo.categoryId == category.id)
        .toList();
    final TextEditingController _controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
        ...memos.map((memo) => ListTile(
          leading: Checkbox(
            value: memo.isChecked,
            onChanged: (_) => context.read<MemoProvider>().toggleCheck(memo.id),
          ),
          title: Text(memo.content),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => context.read<MemoProvider>().deleteMemo(memo.id),
          ),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: '${category.name}에 메모 추가',
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      context.read<MemoProvider>().addMemo(date, value, category.id);
                      _controller.clear();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    context.read<MemoProvider>().addMemo(date, _controller.text, category.id);
                    _controller.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
