import 'package:flutter/material.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key});

  List<Map<String, dynamic>> get articles => [
        {
          'title': 'Мектептегі буллинг үшін жауапкершілік күшейтілді',
          'subtitle':
              'Орта білім беру ұйымдарында оқушыларды психологиялық қысымнан қорғау нормалары енгізілді.',
          'description':
              'Енді мектеп әкімшілігі буллинг фактісін жасырса, ата-аналарға да, білім мекемесіне де ескерту және айыппұл салынуы мүмкін.',
          'image':
              'assets/images/anti-bullying.jpg', // <-- ӨЗГЕРІС
          'source': 'Оқу-ағарту министрлігі',
          'date': '2025-11-02',
          'category': 'Заң',
          'content':
              'Қазақстанда балаларды буллингтен және кибербуллингтен қорғау бойынша жаңа нормалар күшіне енді. Бұл нормаларға сәйкес әрбір білім беру ұйымы буллингтің алдын алу жоспарын жасап, ата-аналармен және оқушылармен түсіндіру жұмыстарын өткізуге міндетті. \n\nСонымен қатар, мектептерде сенім жәшіктері мен онлайн шағым беру арнасы болуы керек. Буллинг туралы хабарлама жасырылса немесе дер кезінде тіркелмесе, мектеп әкімшілігіне тәртіптік жаза қолданылуы мүмкін. \n\nБұл өзгерістер балалардың қауіпсіз ортада білім алуына жағдай жасауға бағытталған.',
        },
        {
          'title': 'Кибербуллингтен қалай қорғануға болады?',
          'subtitle':
              'Әлеуметтік желідегі қысым да психологиялық жарақат қалдырады.',
          'description':
              'Маманның айтуынша, бірінші қадам — агрессормен диалогқа бармау және дәлел жинау.',
          'image':
              'assets/images/cyber-article.jpg', // <-- ӨЗГЕРІС
          'source': 'Balalyq Online',
          'date': '2025-11-01',
          'category': 'Психология',
          'content':
              'Кибербуллинг — бұл әлеуметтік желілерде, мессенджерлерде немесе ойын платформаларында басқа адамға жүйелі түрде зиян келтіру, қорқыту немесе масқаралау. \n\nЕгер сіз немесе балаңыз кибербуллингке ұшыраса:\n1) Қарсы жауап жазбаңыз — бұл агрессорға күш береді;\n2) Скриншоттар мен сілтемелерді сақтаңыз — қажет болғанда дәлел ретінде көрсетесіз;\n3) Платформа әкімшілігіне немесе модераторға шағымданыңыз;\n4) Егер қорқытулар өмірге қауіп төндірсе — дереу құқық қорғау органдарына жүгініңіз;\n5) Психологпен сөйлесіп, өзіңізді кінәламаңыз.',
        },
        {
          'title': 'Психолог: “Баланы ұялту емес, тыңдау керек”',
          'subtitle': 'Буллинг құрбандары көбіне үнсіз қалады.',
          'description':
              'Мектепте қорланған бала көп жағдайда “дәрменсіз” рөлінде қалып қояды. Оған сенетін ересек адам керек.',
          'image':
              'assets/images/mom-and-daughter.jpg', // <-- ӨЗГЕРІС
          'source': 'Psiholog.kz',
          'date': '2025-10-30',
          'category': 'Психология',
          'content':
              'Баладан “неге жауап бермедің?”, “неге айтпадың?” деп сұраудың орнына “сенің басыңнан не өтті?” деп сұрау дұрыс. Баланың эмоциясын жоққа шығармай, оны тыңдаған маңызды. \n\nПсихологтың айтуынша, буллинг көрген балаларда өзіне сенім төмендейді, ұйқы және тәбет бұзылады, оқуға қызығушылық жоғалады. Сондықтан ата-ана да, мұғалім де баланың мінез-құлқындағы өзгерісті ерте байқауы керек.',
        },
        // ... (қалған мақалалар осында)
        {
          'title': 'Ата-аналарға арналған 5 кеңес',
          'subtitle': 'Балаңыз буллингке ұшырауы мүмкін белгілер.',
          'description':
              'Балаңыз сабақты себепсіз жіберіп алса немесе телефонын жасырса — назар аударыңыз.',
          'image':
              'assets/images/family.jpeg', // <-- ӨЗГЕРІС
          'source': 'Otбасы және мектеп',
          'date': '2025-10-25',
          'category': 'Ата-ана',
          'content':
              '1. Баланың көңіл-күйі күрт өзгерсе;\n2. Мектепке барғысы келмесе;\n3. Киімі, заттары жоғалып жүрсе;\n4. Телефон/желі туралы айтқысы келмесе;\n5. Ұйқысы бұзылса — бұл мектептегі қысымның белгісі болуы мүмкін. \n\nМұндайда баланы ұрыспай, “бірге шешеміз” деген форматта сөйлесу қажет.',
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Мақалалар',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return _ArticleCard(
            article: article,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticleDetailScreen(article: article),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;
  final VoidCallback onTap;
  const _ArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final img = article['image'] as String?;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (img != null && img.isNotEmpty)
              Image.asset(
                // <-- ӨЗГЕРІС: Image.network орнына
                img,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _newsImagePlaceholder();
                },
              )
            else
              _newsImagePlaceholder(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article['category'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        article['category'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    article['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF202533),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (article['description'] != null)
                    Text(
                      article['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    '${article['source']} • ${article['date']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newsImagePlaceholder() {
    return Container(
      height: 180,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white70,
          size: 40,
        ),
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final img = article['image'] as String?;
    return Scaffold(
      appBar: AppBar(
        title: Text(article['category'] ?? 'Мақала'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${article['source']} • ${article['date']}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (img != null && img.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  // <-- ӨЗГЕРІС: Image.network орнына
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 40),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Text(
              article['content'],
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}