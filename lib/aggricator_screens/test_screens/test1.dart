import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';

class ExampleCustom extends StatefulWidget {
  const ExampleCustom({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExampleCustomState();
}

class _ExampleCustomState extends State<ExampleCustom> {
  final List<Map<String, dynamic>> posts = [
    {
      "title": "వైసీపీ అధ్వర్యంలో క్యాండిల్ ర్యాలీ",
      "content": "పల్నాడు: కాశ్మీర్లో జరిగిన ఉగ్ర దాడిని వైసీపీ నేతలు ఖండించారు...",
      "image_url": "https://chotanews.azureedge.net/media/2025/04/17-680aefa8e3180.jpg",
    },
    {
      "title": "భార‌త్‌- పాక్ మ‌ధ్య కాల్పులు",
      "content": "భార‌త్‌- పాక్ మ‌ధ్య ఉద్రిక్త ప‌రిస్థితులు నెల‌కొన్నాయి...",
      "image_url": "https://chotanews.azureedge.net/media/2025/03/BREAKING-67e27fe14856f.jpeg",
    },
    {
      "title": "మైక్రోసాఫ్ట్‌ కీలక నిర్ణయం",
      "content": "భారత్, దక్షిణాసియా కార్యకలాపాల కోసం కీలక నాయకత్వ మార్పులు...",
      "image_url": "https://chotanews.azureedge.net/media/2025/04/microsoft1.jpg",
    },
  ];

  late SwiperController _controller;
  late CustomLayoutOption customLayoutOption;

  @override
  void initState() {
    super.initState();

    _controller = SwiperController();

    // Bottom-to-top stacking layout
    customLayoutOption = CustomLayoutOption(startIndex: -1, stateCount: 1)
      ..addRotate([0.0, 0.0, 0.0])
      ..addTranslate([
        const Offset(0.0, 20.0),  // Next card (bottom)
      ])
      ..addScale([
        0.9,  // Previous card
        1.0,  // Current card
        0.9,  // Next card
      ] ,Alignment.topCenter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Swiper(
          controller: _controller,
          itemCount: posts.length,
          itemWidth: 500.0,
          itemHeight: 600.0,
          layout: SwiperLayout.CUSTOM, // Use custom layout
          customLayoutOption: customLayoutOption,

          scrollDirection: Axis.vertical,
          autoplay: false,
          loop: true,
          autoplayDelay: 3000,
          autoplayDisableOnInteraction: false,
          index: 0,
          onIndexChanged: (index) {
            // Handle index change if needed
          },
          onTap: (index) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text("New page")),
                  body: Center(child: Text("Selected: ${posts[index]["title"]}")),
                ),
              ),
            );
          },
          indicatorLayout: PageIndicatorLayout.COLOR,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              elevation: 10,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post["image_url"] != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        post["image_url"],
                        height: 350,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post["title"] ?? '',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post["content"] ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
