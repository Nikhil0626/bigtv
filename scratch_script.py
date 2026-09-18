import re

with open('lib/features/events/presentation/screens/folk_night_event_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace StatelessWidget with StatefulWidget
content = content.replace('class FolkNightEventScreen extends StatelessWidget {', '''import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class FolkNightEventScreen extends StatefulWidget {
  const FolkNightEventScreen({super.key});

  @override
  State<FolkNightEventScreen> createState() => _FolkNightEventScreenState();
}

class _FolkNightEventScreenState extends State<FolkNightEventScreen> {
  bool isLoading = true;
  String name = "Folk Night";
  String description = "Experience the rich cultural heritage of Telangana and Andhra Pradesh with captivating folk music, dance and live performances by renowned artists.\\n\\nA celebration of our roots, our people and timeless traditions.";
  String dateStr = "Sat, 24 Oct • 6:00 PM";
  String location = "Hyderabad • Open Air Auditorium";
  List<String> images = [
    'https://images.unsplash.com/photo-1543857778-c4a1a3e0b2eb?auto=format&fit=crop&q=80&w=800&h=600'
  ];
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchEventData();
  }

  Future<void> fetchEventData() async {
    try {
      final response = await Dio().get('https://api.pravasamedia.com/api/v1/events?city=Hyderabad&type=Concert&status=UPCOMING&page=1&limit=10');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        if (data.isNotEmpty) {
          final event = data.first;
          setState(() {
            name = event['name'] ?? name;
            description = event['description'] ?? description;
            
            if (event['images'] != null && event['images'].isNotEmpty) {
              images = List<String>.from(event['images']);
            }

            String dStr = "";
            if (event['date'] != null) {
              try {
                DateTime dt = DateTime.parse(event['date']);
                dStr = DateFormat('EEE, d MMM').format(dt);
              } catch (e) {
                // ignore
              }
            }
            if (event['time'] != null) {
              dStr += " • " + event['time'].toString();
            }
            if (dStr.isNotEmpty) {
              dateStr = dStr;
            }

            String locStr = "";
            if (event['location'] != null) {
              locStr = event['location'];
            }
            if (locStr.isNotEmpty) {
              location = locStr;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching events: ");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
''')
content = content.replace('  const FolkNightEventScreen({super.key});', '')

content = content.replace('      body: Column(', '      body: isLoading ? const Center(child: CircularProgressIndicator()) : Column(')

# Replace Hero Image
hero_image_old = '''                  Stack(
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1543857778-c4a1a3e0b2eb?auto=format&fit=crop&q=80&w=800&h=600',
                        width: double.infinity,
                        height: 250.h,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: double.infinity,
                          height: 250.h,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColorTokens.primaryRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, color: Colors.white, size: 8),
                              const SizedBox(width: 6),
                              Text(
                                "LIVE EVENT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDot(true),
                            _buildDot(false),
                            _buildDot(false),
                            _buildDot(false),
                          ],
                        ),
                      ),
                    ],
                  ),'''
hero_image_new = '''                  Stack(
                    children: [
                      SizedBox(
                        height: 250.h,
                        child: PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index],
                              width: double.infinity,
                              height: 250.h,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: double.infinity,
                                height: 250.h,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image, size: 50, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColorTokens.primaryRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, color: Colors.white, size: 8),
                              const SizedBox(width: 6),
                              Text(
                                "LIVE EVENT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (index) => _buildDot(index == currentImageIndex),
                          ),
                        ),
                      ),
                    ],
                  ),'''
content = content.replace(hero_image_old, hero_image_new)

content = content.replace('"Folk Night",\\n                          style: TextStyle(', 'name,\\n                          style: TextStyle(')

# Replace date
content = re.sub(r'"Sat, 24 Oct [^"]*"', 'dateStr', content)
# Replace location
content = re.sub(r'"Hyderabad [^"]*"', 'location', content)

# Replace description
desc_regex = r'"Experience the rich cultural heritage of Telangana and Andhra Pradesh with captivating folk music, dance and live performances by renowned artists.\\\\n\\\\nA celebration of our roots, our people and timeless traditions."'
content = re.sub(desc_regex, 'description', content)


with open('lib/features/events/presentation/screens/folk_night_event_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
