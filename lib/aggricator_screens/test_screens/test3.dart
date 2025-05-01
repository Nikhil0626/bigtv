import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_colors.dart';

class AnimatedNewsStackedPageView extends StatefulWidget {
  @override
  State<AnimatedNewsStackedPageView> createState() => _AnimatedNewsStackedPageViewState();
}

class _AnimatedNewsStackedPageViewState extends State<AnimatedNewsStackedPageView> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final CardSwiperController controller = CardSwiperController();
  int currentIndex = 0;

  final List<Map<String, dynamic>> post = [
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

  void undoCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      controller.moveTo(currentIndex);
    }
  }

  void forwardCard() {
    if (currentIndex < post.length - 1) {
      setState(() {
        currentIndex++;
      });
      controller.moveTo(currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          GestureDetector(
            // onVerticalDragStart: (details) {
            //   dragStartPosition = details.localPosition.dy;  // Store the starting position of the drag
            // },
        /*    onVerticalDragEnd: (details) {
              // Check the vertical drag distance
              double dragDistance = details.primaryVelocity ?? 0.0;

              if (dragDistance < -150) {
                // Dragged up by more than 150 pixels
                print("siva");

                // if (currentIndex > 0) {
                //   setState(() {
                //     currentIndex--;
                //   });
                // }
              } else if (dragDistance > 150) {
                // Dragged down by more than 150 pixels
                print("kumar");
                // controller.undo();

                // controller.moveTo(index)

                // if (currentIndex < post.length - 1) {
                //   setState(() {
                //     currentIndex++;
                //   });
                //   controller.moveTo(currentIndex);
                // }
              }
            },*/
            child: CardSwiper(
              allowedSwipeDirection: AllowedSwipeDirection.symmetric(vertical: true),
              controller: controller,
              cardsCount: post.length,

              onSwipe: (previousIndex, currentIndex1, direction) {
                print("Swiped from $previousIndex to $currentIndex direction $direction");

                // Swipe up (forward swipe) = remove current card
                if (direction == CardSwiperDirection.top) {
                  if (currentIndex < post.length - 1) {
                    setState(() {
                      currentIndex++;  // Increment the current index to move to the next card
                    });
                    controller.moveTo(currentIndex);  // Move to the next card
                  }
                }

                // Swipe down (undo swipe) = restore previous card
                else if (direction == CardSwiperDirection.bottom) {
                  controller.undo();
                }

                return true;  // Returning true to continue with the swipe behavior
              },


              isLoop: false,
              numberOfCardsDisplayed: 4,
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
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
                              const SizedBox(height: 8),
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
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: undoCard,
              child: Icon(Icons.undo),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: forwardCard,
              child: Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }
}
