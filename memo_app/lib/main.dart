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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 데이터 모델 -----------------------------------------------------------------
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

// 상태 관리 -----------------------------------------------------------------
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

// 메인 화면 -----------------------------------------------------------------
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Memo App')),
      body: isWide ? _buildWideLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildWideLayout() => Row(
    children: [
      Expanded(flex: 2, child: _buildCalendarSection()),
      Expanded(flex: 1, child: _buildMemoSection()),
    ],
  );

  Widget _buildMobileLayout() => Column(
    children: [
      Expanded(flex: 2, child: _buildCalendarSection()),
      Expanded(flex: 1, child: _buildMemoSection()),
    ],
  );

  Widget _buildCalendarSection() => const CalendarSection();
  Widget _buildMemoSection() => const Placeholder(); // 실제 구현 필요
}

// 달력 부분 -----------------------------------------------------------------
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
        onDaySelected: _onDaySelected,
        calendarStyle: _buildCalendarStyle(),
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        calendarBuilders: _buildCalendarCustom(),
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _showMemoDialog(context, selectedDay);
  }

  CalendarStyle _buildCalendarStyle() => CalendarStyle(
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
  );

  CalendarBuilders _buildCalendarCustom() => CalendarBuilders(
    dowBuilder: (context, day) {
      if (day.weekday == DateTime.sunday) {
        return const Center(child: Text('Sun', style: TextStyle(color: Colors.red)));
      }
      return null;
    },
  );
}

// 메모 다이얼로그 ------------------------------------------------------------
void _showMemoDialog(BuildContext context, DateTime date) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: MemoDialog(date: date),
      ),
    ),
  );
}

class MemoDialog extends StatefulWidget {
  final DateTime date;
  const MemoDialog({super.key, required this.date});

  @override
  State<MemoDialog> createState() => _MemoDialogState();
}

class _MemoDialogState extends State<MemoDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final memos = context.watch<MemoProvider>().getMemosForDate(widget.date);
    final categories = context.watch<CategoryProvider>().categories;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        _buildCategorySection(categories),
        _buildMemoList(memos),
        _buildInputSection(categories),
      ],
    );
  }

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(DateFormat('yyyy/MM/dd').format(widget.date)),
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );

  Widget _buildCategorySection(List<Category> categories) => Column(
    children: [
      Row(
        children: [
          const Text('카테고리:'),
          ...categories.map((category) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(category.name),
              selected: _selectedCategoryId == category.id,
              onSelected: (_) => setState(() => _selectedCategoryId = category.id),
              backgroundColor: category.color.withOpacity(0.2),
              selectedColor: category.color,
              labelStyle: TextStyle(
                color: _selectedCategoryId == category.id ? Colors.white : Colors.black,
              ),
            ),
          )).toList(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
      const Divider(),
    ],
  );

  Widget _buildMemoList(List<Memo> memos) => Expanded(
    child: ListView.builder(
      itemCount: memos.length,
      itemBuilder: (context, index) => ListTile(
        leading: Checkbox(
          value: memos[index].isChecked,
          onChanged: (_) => context.read<MemoProvider>().toggleCheck(memos[index].id),
        ),
        title: Text(memos[index].content),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => context.read<MemoProvider>().deleteMemo(memos[index].id),
        ),
        tileColor: _getCategoryColor(memos[index].categoryId).withOpacity(0.1),
      ),
    ),
  );

  Widget _buildInputSection(List<Category> categories) => Row(
    children: [
      Expanded(
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: '새 메모 입력'),
          onSubmitted: (_) => _addMemo(),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: _addMemo,
      ),
    ],
  );

  Color _getCategoryColor(String categoryId) => 
      context.read<CategoryProvider>().categories
          .firstWhere((cat) => cat.id == categoryId).color;

  void _addMemo() {
    if (_controller.text.isNotEmpty && _selectedCategoryId != null) {
      context.read<MemoProvider>().addMemo(
        widget.date, 
        _controller.text, 
        _selectedCategoryId!
      );
      _controller.clear();
    }
  }

  void _showAddCategoryDialog() {
    Color selectedColor = Colors.blue;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 카테고리 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '카테고리 이름'),
            ),
            const SizedBox(height: 20),
            ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) => selectedColor = color,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<CategoryProvider>().addCategory(
                  nameController.text, 
                  selectedColor
                );
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}
