import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class MoodScreen extends StatefulWidget {
  final String baseUrl;
  final String userId;

  const MoodScreen({
    super.key,
    required this.baseUrl,
    required this.userId,
  });

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String? _selectedMood;
  bool _saving = false;

  Map<String, int> _stats = {};

  final List<Map<String, dynamic>> moods = const [
    {
      'id': 'very_happy',
      'label': 'Керемет',
      'emoji': '😁',
      'color': Color(0xFFD0F2FF)
    },
    {
      'id': 'happy',
      'label': 'Жақсы',
      'emoji': '😊',
      'color': Color(0xFFC8FAD6)
    },
    {
      'id': 'neutral',
      'label': 'Қалыпты',
      'emoji': '😐',
      'color': Color(0xFFF4F1C5)
    },
    {
      'id': 'sad',
      'label': 'Мұңды',
      'emoji': '😢',
      'color': Color(0xFFFFE3E3)
    },
    {
      'id': 'angry',
      'label': 'Ашулы',
      'emoji': '😡',
      'color': Color(0xFFFFD0D0)
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDataForDay(_selectedDay);
  }

  Future<void> _loadDataForDay(DateTime day) async {
    await _loadStatsForMonth(day);
    await _loadMoodForSelectedDay(day);
  }

  Future<void> _loadMoodForSelectedDay(DateTime day) async {
    
    setState(() {
      _selectedMood = null;
    });

    final dateString = day.toIso8601String().split('T').first;
    final url = Uri.parse(
        '${widget.baseUrl}/mood/by-date?userId=${widget.userId}&date=$dateString');

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _selectedMood = data['mood'];
          });
        }
      }
    } catch (e) {
      // Қате болған жағдайда үнсіз өту(Көңіл-күй жүктелмегенде)
    }
  }

  Future<void> _save() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Алдымен көңіл-күйді таңда')),
      );
      return;
    }

    setState(() => _saving = true);

    final url = Uri.parse('${widget.baseUrl}/mood');
    final body = {
      'userId': widget.userId, 
      'date': _selectedDay.toIso8601String(),
      'mood': _selectedMood!,
      'note': '',
    };

    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        await _loadStatsForMonth(_selectedDay);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Көңіл-күй сақталды ✅')),
          );
        }
      } else {
        String errorMessage = 'Белгісіз қате';
        try {
          final errorData = jsonDecode(res.body);
          errorMessage = errorData['msg'] ?? 'Серверден қате келді';
        } catch (e) {
          errorMessage = 'Жауапты өңдеу мүмкін болмады: ${res.body}';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Қате: $errorMessage')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Желі қатесі: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadStatsForMonth(DateTime date) async {
    final month = date.month;
    final year = date.year;
    final url = Uri.parse(
        '${widget.baseUrl}/mood/stats?userId=${widget.userId}&month=$month&year=$year');

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final Map<String, int> parsed = {};
        for (var item in data) {
          parsed[item['_id']] = item['count'] as int;
        }
        if (mounted) {
          setState(() {
            _stats = parsed;
          });
        }
      }
    } catch (e) {
      // Қате болған жағдайда үнсіз өту(Көңіл-күй жүктелмегенде)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Көңіл-күй күнтізбесі'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Күнтізбе',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Күнді таңда, сосын көңіл-күйіңді белгіле.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  _buildCalendar(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Көңіл-күйді белгілеу',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _formatDate(_selectedDay),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: moods.map((m) {
                      final bool selected = _selectedMood == m['id'];
                      final Color color = m['color'];

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          setState(() => _selectedMood = m['id']);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? color
                                : color.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(14),
                            border: selected
                                ? Border.all(color: Colors.black12, width: 1)
                                : Border.all(color: Colors.transparent),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(m['emoji'],
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                m['label'],
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _saving ? 'Сақталуда...' : 'Сақтау',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Айлық статистика',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _buildStats(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime(2024),
      lastDay: DateTime(2030),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
        _loadDataForDay(selected);
      },
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
        leftChevronIcon: Icon(Icons.chevron_left, size: 22),
        rightChevronIcon: Icon(Icons.chevron_right, size: 22),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildStats() {
    if (_stats.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: const Text('Бұл айда жазба жоқ 😌'),
      );
    }
    return Column(
      children: moods.map((m) {
        final count = _stats[m['id']] ?? 0;
        final Color color = m['color'];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(m['emoji'], style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: count == 0
                        ? 0
                        : (count / _maxStatCount()).clamp(0.15, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(count.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }

  int _maxStatCount() {
    if (_stats.isEmpty) return 1;
    return _stats.values.reduce((a, b) => a > b ? a : b);
  }

  String _formatDate(DateTime d) {
    const months = [
      'қаң', 'ақп', 'нау', 'сәу', 'мам', 'мау',
      'шіл', 'там', 'қыр', 'қаз', 'қар', 'жел'
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}
