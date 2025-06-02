import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
        scaffoldBackgroundColor: const Color(0xFFFAF6FA),
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
  DateTime? _selectedDay = DateTime.now();
  bool _showSettings = false;

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

  void _goToPrevMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  void _showCategoryAddDialog() {
    showDialog(
      context: context,
      builder: (context) => CategoryAddDialog(presetColors: _presetColors),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar 없이 직접 상단 Row로 커스텀 헤더
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 (월 이동 + 월 타이틀 + 설정 버튼)
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
            // 설정 패널 (설정 버튼 클릭 시)
            if (_showSettings)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: SettingsPanel(
                    onAddCategory: _showCategoryAddDialog,
                    onClose: () => setState(() => _showSettings = false),
                  ),
                ),
              ),
            // 달력
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                headerVisible: false, // 기본 헤더 숨김
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
                  dowBuilder: (context, day) {
                    if (day.weekday == DateTime.sunday) {
                      return const Center(child: Text('Sun', style: TextStyle(color: Colors.red)));
                    }
                    if (day.weekday == DateTime.saturday) {
                      return const Center(child: Text('Sat', style: TextStyle(color: Colors.red)));
                    }
                    return null;
                  },
                ),
              ),
            ),
            // 메모 UI
            Expanded(
              child: MemoSection(selectedDate: _selectedDay),
            ),
          ],
        ),
      ),
    );
  }
}

// 설정 패널
class SettingsPanel extends StatelessWidget {
  final VoidCallback onAddCategory;
  final VoidCallback onClose;

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

// 카테고리 추가 다이얼로그
class CategoryAddDialog extends StatefulWidget {
  final List<Color> presetColors;
  const CategoryAddDialog({super.key, required this.presetColors});

  @override
  State<CategoryAddDialog> createState() => _CategoryAddDialogState();
}

class _CategoryAddDialogState extends State<CategoryAddDialog> {
  final TextEditingController _nameController = TextEditingController();
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.presetColors.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('카테고리 추가'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
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

// 메모 영역 (카테고리별 메모 목록/입력)
class MemoSection extends StatelessWidget {
  final DateTime? selectedDate;

  const MemoSection({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    if (selectedDate == null) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 좌측 상단에 작은 날짜만 표시 (투명/달력 배경)
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
