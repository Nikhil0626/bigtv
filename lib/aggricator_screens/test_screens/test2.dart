import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/material.dart';

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State<Example> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<Example> {
  final CardSwiperController controller = CardSwiperController();

  final List<Map<String, dynamic>>  post = [
    {
      "title": "aaaaaaaaaaaaaaaaaaaaaaa",
      "content": "పల్నాడు: కాశ్మీర్లో జరిగిన ఉగ్ర దాడిని వైసీపీ నేతలు ఖండించారు...",
      "image_url": "https://chotanews.azureedge.net/media/2025/04/17-680aefa8e3180.jpg",
    },
    {
      "title": "bbbbbbbbbbbbbbbbbbbbbbbbbb",
      "content": "భార‌త్‌- పాక్ మ‌ధ్య ఉద్రిక్త ప‌రిస్థితులు నెల‌కొన్నాయి...",
      "image_url": "https://chotanews.azureedge.net/media/2025/03/BREAKING-67e27fe14856f.jpeg",
    },
    {
      "title": "ccccccccccccccccccccccccccccc",
      "content": "భారత్, దక్షిణాసియా కార్యకలాపాల కోసం కీలక నాయకత్వ మార్పులు...",
      "image_url": "https://chotanews.azureedge.net/media/2025/04/microsoft1.jpg",
    },
    {
      "title": "ddddddddddddddddddddddddddddddddd",
      "content": "పల్నాడు: కాశ్మీర్లో జరిగిన ఉగ్ర దాడిని వైసీపీ నేతలు ఖండించారు...",
      "image_url": "https://chotanews.azureedge.net/media/2025/04/17-680aefa8e3180.jpg",
    },
    {
      "title": "ffffffffffffdffffffffffffffffff",
      "content": "భార‌త్‌- పాక్ మ‌ధ్య ఉద్రిక్త ప‌రిస్థితులు నెల‌కొన్నాయి...",
      "image_url": "https://chotanews.azureedge.net/media/2025/03/BREAKING-67e27fe14856f.jpeg",
    },
    {
      "title": "ggggggggggggggggggggggggggggggg",
      "content": "భారత్, దక్షిణాసియా కార్యకలాపాల కోసం కీలక నాయకత్వ మార్పులు...",
      "image_url": "https://chotanews.azureedge.net/media/2025/04/microsoft1.jpg",
    },
    {
      "title": "hhhhhhhhhhhhhnhhhghhhhhhhh",
      "content": "పల్నాడు: కాశ్మీర్లో జరిగిన ఉగ్ర దాడిని వైసీపీ నేతలు ఖండించారు...",
      "image_url": "https://chotanews.azureedge.net/media/2025/04/17-680aefa8e3180.jpg",
    },
    {
      "title": "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii",
      "content": "భార‌త్‌- పాక్ మ‌ధ్య ఉద్రిక్త ప‌రిస్థితులు నెల‌కొన్నాయి...",
      "image_url": "https://chotanews.azureedge.net/media/2025/03/BREAKING-67e27fe14856f.jpeg",
    },
    {
      "title": "jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj",
      "content": "భారత్, దక్షిణాసియా కార్యకలాపాల కోసం కీలక నాయకత్వ మార్పులు...",
      "image_url": "https://chotanews.azureedge.net/media/2025/04/microsoft1.jpg",
    },
    {
      "title": "kkkk,kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk",
      "content": "పల్నాడు: కాశ్మీర్లో జరిగిన ఉగ్ర దాడిని వైసీపీ నేతలు ఖండించారు...",
      "image_url": "https://chotanews.azureedge.net/media/2025/04/17-680aefa8e3180.jpg",
    },
    {
      "title": "llllllllllllllllllllllllllll",
      "content": "భార‌త్‌- పాక్ మ‌ధ్య ఉద్రిక్త ప‌రిస్థితులు నెల‌కొన్నాయి...",
      "image_url": "https://chotanews.azureedge.net/media/2025/03/BREAKING-67e27fe14856f.jpeg",
    },
    {
      "title": "mmmmmmmmmkmmmmmmmmmmmmmmmmmmmmmmmm",
      "content": "భారత్, దక్షిణాసియా కార్యకలాపాల కోసం కీలక నాయకత్వ మార్పులు...",
      "image_url": "https://chotanews.azureedge.net/media/2025/04/microsoft1.jpg",
    },
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

  int currentIndex = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Card Swiper Example"),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: CardSwiper(
                controller: controller,
                cardsCount: post.length,
                onSwipe: _onSwipe,
                onUndo: _onUndo,
                // allowedSwipeDirection: AllowedSwipeDirection.only(up:true),
                numberOfCardsDisplayed: 3,
                duration: const Duration(milliseconds: 0),
                backCardOffset: const Offset(0, 40),
                padding: const EdgeInsets.all(40.0),
                // alignment: Alignment.topCenter,
                cardBuilder: (
                    context,
                    index,
                    horizontalThresholdPercentage,
                    verticalThresholdPercentage,
                    ) {

                  return Card(
                    elevation: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      height: 600,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post[index]["image_url"] != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Image.network(
                                post[index]["image_url"],
                                height: 400,
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
                                  post[index]["title"] ?? '',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                 height(height: 8),
                                Text(
                                  post[index]["content"] ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _onSwipe(
      int previousIndex,
      int? newIndex,
      CardSwiperDirection direction,
      ) {
    if (direction == CardSwiperDirection.bottom) {
      _undo();
      debugPrint(
          'Swipe down detected. Showing previous card: ${post[currentIndex]['text']}');
      return false;
    }

    if (newIndex != null) {
      currentIndex = newIndex;
    }
    debugPrint(
      'The card $previousIndex was swiped to the ${direction.name}. Now the card $newIndex is on top',
    );
    return true;
  }

  bool _onUndo(
      int? previousIndex,
      int currentIndex,
      CardSwiperDirection direction,
      ) {
    debugPrint(
      'The card $currentIndex was undone from the ${direction.name}',
    );
    return true;
  }

  void _undo() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      controller.undo();
    }
  }
}