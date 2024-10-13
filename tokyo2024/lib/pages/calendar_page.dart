import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class Event {
  String title;
  String memo;
  DateTime start;
  DateTime end;

  Event({
    required this.title,
    required this.memo,
    required this.start,
    required this.end,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'カレンダーアプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // イベントを日付ごとに管理するマップ
  final Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _addEvent(DateTime day, Event event) {
    final date = DateTime(day.year, day.month, day.day);
    if (_events[date] != null) {
      _events[date]!.add(event);
    } else {
      _events[date] = [event];
    }
    _selectedEvents.value = _getEventsForDay(_selectedDay!);
  }

  void _showAddEventDialog(DateTime day) {
    final _titleController = TextEditingController();
    final _memoController = TextEditingController();
    DateTime? _startTime;
    DateTime? _endTime;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 500,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'イベントを追加',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'タイトル'),
                  ),
                  TextField(
                    controller: _memoController,
                    decoration: const InputDecoration(labelText: 'メモ'),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_startTime == null
                            ? '開始時間: 未選択'
                            : '開始時間: ${DateFormat('yyyy/MM/dd HH:mm').format(_startTime!)}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: day,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                _startTime = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    time.hour,
                                    time.minute);
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_endTime == null
                            ? '終了時間: 未選択'
                            : '終了時間: ${DateFormat('yyyy/MM/dd HH:mm').format(_endTime!)}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: day,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                _endTime = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    time.hour,
                                    time.minute);
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('キャンセル'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        child: const Text('保存'),
                        onPressed: () {
                          if (_titleController.text.isEmpty ||
                              _startTime == null ||
                              _endTime == null) {
                            // 簡単なバリデーション
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('必要な情報を全て入力してください')),
                            );
                            return;
                          }

                          final newEvent = Event(
                            title: _titleController.text,
                            memo: _memoController.text,
                            start: _startTime!,
                            end: _endTime!,
                          );

                          setState(() {
                            _addEvent(day, newEvent);
                          });

                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEventsBottomSheet(DateTime day) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<List<Event>>(
          valueListenable: _selectedEvents,
          builder: (context, events, _) {
            return SizedBox(
              height: 400,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      DateFormat('yyyy年MM月dd日').format(day),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showAddEventDialog(day);
                      },
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: events.isEmpty
                        ? const Center(child: Text('イベントはありません'))
                        : ListView.builder(
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return ListTile(
                                title: Text(event.title),
                                subtitle: Text(
                                    '${DateFormat('HH:mm').format(event.start)} - ${DateFormat('HH:mm').format(event.end)}\n${event.memo}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDayCell(DateTime date, bool isToday, bool isSelected) {
    final events = _getEventsForDay(date);
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isToday
            ? Colors.blueAccent
            : isSelected
                ? Colors.orange
                : null,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4.0),
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 16.0,
              color: isToday || isSelected ? Colors.white : Colors.black,
            ),
          ),
          if (events.isNotEmpty)
            ...events.map((event) => Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 10,
                    color: isToday || isSelected ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カレンダー'),
      ),
      body: TableCalendar<Event>(
        firstDay: DateTime(2000),
        lastDay: DateTime(2100),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _selectedEvents.value = _getEventsForDay(selectedDay);
          });
          _showEventsBottomSheet(selectedDay);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
        ),
        shouldFillViewport: true, // 画面全体を埋める
        calendarBuilders: CalendarBuilders<Event>(
          defaultBuilder: (context, date, _) {
            return _buildDayCell(date, false, false);
          },
          todayBuilder: (context, date, _) {
            return _buildDayCell(date, true, false);
          },
          selectedBuilder: (context, date, _) {
            return _buildDayCell(date, false, true);
          },
        ),
      ),
    );
  }
}
