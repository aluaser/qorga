import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'mood_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'article_screen.dart';
import 'help_screen.dart';
import 'about_us_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String? _userId;
  String? _email;
  String? _name;
  bool _isLoading = true;

  final String _baseUrl = "http://localhost:5000";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userId = prefs.getString('userId');
      _email = prefs.getString('email');
      _name = prefs.getString('name');
      _isLoading = false;
    });
  }


  void _onTabTapped(int index) async {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    } else if (index == 1) {
      if (_userId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoodScreen(
              baseUrl: _baseUrl,
              userId: _userId!,
            ),
          ),
        );
      } else {
        final bool? loginSuccess = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );

        if (loginSuccess == true) {
          await _loadUserData();

          if (_userId != null && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MoodScreen(
                  baseUrl: _baseUrl,
                  userId: _userId!,
                ),
              ),
            );
          }
        }
      }
    } else {
      setState(() {
        _tab = index;
      });
    }
  }

  List<Widget> _buildTabScreens() {
    return [
      _buildHomePageBody(),
      Container(),
      Container(),
      const ArticleScreen(),
    ];
  }

  Widget _buildHomePageBody() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.asset(
                  'assets/images/students-photo-header.jpg',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  height: 200,
                  color: Colors.black.withOpacity(0.4),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Қош келдіңіз!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Біздің қосымшамыз студенттерге көмектеседі',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _QuoteGeneratorWidget(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                leading: const CircleAvatar(
                    radius: 22, child: Icon(Icons.account_circle, size: 30)),
                title: Text(
                  _name ?? 'Пайдаланушы',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                subtitle: Text(_userId == null ? 'Кіру' : (_email ?? 'Профиль')),
                onTap: () async {
                  Navigator.pop(context);
                  if (_userId == null) {
                    _onTabTapped(1);
                  } else {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()),
                    );
                    await _loadUserData();
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.call),
                title: const Text('Көмек'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Біз туралы'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutUsScreen()),
                  );
                },
              ),
              const Spacer(),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'QORGA',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTabScreens()[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Басты'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Көңіл-күй'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Чат'),
          BottomNavigationBarItem(
              icon: Icon(Icons.newspaper), label: 'Мақалалар'),
        ],
      ),
    );
  }
}

class _QuoteGeneratorWidget extends StatefulWidget {
  const _QuoteGeneratorWidget();

  @override
  State<_QuoteGeneratorWidget> createState() => _QuoteGeneratorWidgetState();
}

class _QuoteGeneratorWidgetState extends State<_QuoteGeneratorWidget> {
  final List<Map<String, String>> _quotes = [
    {
      "quote": "Ең үлкен жеңіс - өзіңді жеңу.",
      "author": "Платон"
    },
    {
      "quote": "Білімді болу жеткіліксіз, оны қолдана білу керек.",
      "author": "Иоганн Гёте"
    },
    {
      "quote": "Сен не ойласаң, сен солсың.",
      "author": "Будда"
    },
    {
      "quote": "Жақсылық жасаудан ешқашан жалықпа.",
      "author": "Марк Твен"
    },
    {
      "quote": "Ертеңгі күннің кедергісі - бүгінгі күмән.",
      "author": "Франклин Рузвельт"
    },
    {
      "quote": "Өзгерістің құпиясы - ескімен күресуге емес, жаңаны құруға назар аудару.",
      "author": "Сократ"
    },
    {
      "quote": "Жетістікке жетудің жалғыз жолы - жасап жатқан ісіңді жақсы көру.",
      "author": "Стив Джобс"
    }
  ];

  late Map<String, String> _currentQuote;

  @override
  void initState() {
    super.initState();
    _generateNewQuote();
  }

  void _generateNewQuote() {
    setState(() {
      _currentQuote = _quotes[Random().nextInt(_quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _generateNewQuote,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Күннің дәйексөзі',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.format_quote_rounded,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                _currentQuote['quote']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "— ${_currentQuote['author']!}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}