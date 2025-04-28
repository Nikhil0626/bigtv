import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class NewsSwipeStackView extends StatefulWidget {
  const NewsSwipeStackView({super.key});

  @override
  State<NewsSwipeStackView> createState() => _NewsSwipeStackViewState();
}

class _NewsSwipeStackViewState extends State<NewsSwipeStackView> {
  int currentIndex = 0;
  final List<Map<String, dynamic>> posts = [
    {
      "id": 3969133,
      "postOrder": 832955,
      "author": 31,
      "title": "వైసీపీ అధ్వర్యంలో క్యాండిల్ ర్యాలీ",
      "content":
          "పల్నాడు: కాశ్మీర్లో జరిగిన ఉగ్ర దాడిని వైసీపీ నేతలు ఖండించారు. గురువారం రాత్రి వినుకొండలోని వైసీపీ కార్యాలయంలో ముందు ఉగ్రవాదుల దాడిలో చనిపోయిన వారికి సంతాపంగా మౌనం పాటించారు. అనంతరం ఉగ్ర దాడిని నిరసిస్తూ క్యాండిల్ ర్యాలీ చేపట్టారు. పర్యాటక ప్రాంతాల్లో భద్రతా ఏర్పాట్లను ప్రభుత్వం పెంచాలని వైసీపీ జిల్లా అధికార ప్రతినిధి ప్రసాద్ విజ్ఞప్తి చేశారు.",
      "created": "2025-04-25T02:13:33",
      "guid": "https://chotanews.azurewebsites.net/?p=3969133",
      "post_type": "post",
      "post_name": "వైసీపీ-అధ్వర్యంలో-క్యాండ",
      "post_mime_type": "",
      "totalLikes": 11,
      "totalViews": 1506,
      "totalComments": 0,
      "image_url": "https://chotanews.azureedge.net/media/2025/04/17-680aefa8e3180.jpg",
      "video_url": null,
      "downloadUrl": null,
      "gallery": null,
      "type": "Standard",
      "totalShares": 0,
      "isReporter": 0,
      "reportedBy": "",
      "categoryName": "నేషనల్",
      "postUrl": null,
      "subType": "",
      "isStickyPost": 0,
      "adPosition": null,
      "linkURLAndroid": "https://apps.signitivessoft.com/individualPage?postId=3969133",
      "linkURLIos": "https://apps.signitivessoft.com/individualPage?postId=3969133",
      "links": [],
      "categoryId": 2,
      "isBookmarked": 0
    },
    {
      "id": 3969115,
      "postOrder": 832949,
      "author": 24,
      "title": "భార‌త్‌- పాక్ మ‌ధ్య కాల్పులు",
      "content":
          "భార‌త్‌- పాక్ మ‌ధ్య ఉద్రిక్త ప‌రిస్థితులు నెల‌కొన్నాయి. నియంత్రణ రేఖ (LoC) వెంట పలు చోట్ల పాక్‌ ఆర్మీ దుశ్చర్యకు పాల్పడింది. పాకిస్థాన్‌ ఆర్మీ కాల్పులు జరపడంతో భారత భద్రతా బలగాలు ప్రతిదాడులు చేస్తున్నాయి. మరోవైపు జమ్మూకశ్మీర్‌లోని బందిపొరాలో ఉగ్రవాదులు, భద్రతా బలగాలకు మధ్య ఎదురు కాల్పులు జరుగుతున్నాయి. ఇక్కడ తొలుత భద్రతా బలగాలు కార్డన్‌ సెర్చ్‌ నిర్వహిస్తుండగా ఉగ్రవాదులు కాల్పులకు తెగబడ్డారు.",
      "created": "2025-04-25T02:09:08",
      "guid": "https://chotanews.azurewebsites.net/?p=3969115",
      "post_type": "post",
      "post_name": "భార‌త్‌-పాక్-మ‌ధ్య-కాల్ప",
      "post_mime_type": "",
      "totalLikes": 11,
      "totalViews": 2790,
      "totalComments": 0,
      "image_url": "https://chotanews.azureedge.net/media/2025/03/BREAKING-67e27fe14856f.jpeg",
      "video_url": "",
      "downloadUrl": null,
      "gallery": null,
      "type": "Standard",
      "totalShares": 0,
      "isReporter": 0,
      "reportedBy": "",
      "categoryName": "నేషనల్",
      "postUrl": "",
      "subType": "",
      "isStickyPost": 0,
      "adPosition": null,
      "linkURLAndroid": "https://apps.signitivessoft.com/individualPage?postId=3969115",
      "linkURLIos": "https://apps.signitivessoft.com/individualPage?postId=3969115",
      "links": [],
      "categoryId": 2,
      "isBookmarked": 0
    },
    {
      "id": 3969077,
      "postOrder": 832937,
      "author": 32,
      "title": "మైక్రోసాఫ్ట్‌ కీలక నిర్ణయం.. లీడర్‌షిప్ మార్పు",
      "content":
          "భారత్, దక్షిణాసియా కార్యకలాపాల కోసం కీలక నాయకత్వ పదవుల్లో మార్పులను మైక్రోసాఫ్ట్‌ ప్రకటించింది. కంపెనీ కృత్రిమ మేధ (ఏఐ) కార్యక్రమాలు, మొత్తం వ్యాపార వ్యూహాన్ని నడిపించేందుకు కొత్త పదవుల్లో నితిన్‌ మిత్తల్, హిమానీ అగర్వాల్, అపర్ణ కొండబోయినను నియమించింది. ఈ నియామకాలు తక్షణమే అమల్లోకి వస్తాయని తెలిపింది. భారత్, దక్షిణాసియా ఇండస్ట్రీ లీడర్, డిజిటల్‌ నేటివ్స్‌గా నితిన్‌ మిత్తల్‌ వ్యవహరించనున్నారు.",
      "created": "2025-04-25T02:02:00",
      "guid": "https://chotanews.azurewebsites.net/?p=3969077",
      "post_type": "post",
      "post_name": "మైక్రోసాఫ్ట్‌-కీలక-నిర్ణ",
      "post_mime_type": "",
      "totalLikes": 12,
      "totalViews": 8500,
      "totalComments": 0,
      "image_url": "https://chotanews.azureedge.net/media/2025/04/microsoft1.jpg",
      "video_url": "",
      "downloadUrl": null,
      "gallery": null,
      "type": "Standard",
      "totalShares": 0,
      "isReporter": 0,
      "reportedBy": "",
      "categoryName": "ఇంటర్నేషనల్,నేషనల్,బిజినెస్",
      "postUrl": "",
      "subType": "",
      "isStickyPost": 0,
      "adPosition": null,
      "linkURLAndroid": "https://apps.signitivessoft.com/individualPage?postId=3969077",
      "linkURLIos": "https://apps.signitivessoft.com/individualPage?postId=3969077",
      "links": [],
      "categoryId": 6,
      "isBookmarked": 0
    },
    {
      "id": 3969034,
      "postOrder": 832927,
      "author": 41,
      "title": "నీట్ పరీక్ష: వెబ్‌సైట్లో సెంటర్ వివరాలు",
      "content":
          "నీట్ పరీక్ష రాయబోయే విద్యార్ధులకు నేషనల్ టెస్టింగ్ ఏజెన్సీ ఒక అప్‌డేట్ ఇచ్చింది. పరీక్ష కేంద్రాల కేటాయింపునకు సంబంధించిన వివరాలను వెబ్‌సైట్లో పెట్టినట్లు తెలిపింది. మే-4న నీట్ ఎంట్రన్స్ పరీక్ష ఉంది. జాతీయ స్థాయిలో లక్షకుపైగా ఉన్న ఎంబీబీఎస్ సీట్లకోసం దేశవ్యాప్తంగా 23లక్షల మంది పోటీ పడుతున్నట్లు వెల్లడించింది. పూర్తి వివరాలకు <link1>ఇక్కడ క్లిక్ చేయండి</link1>.",
      "created": "2025-04-25T01:55:34",
      "guid": "https://chotanews.azurewebsites.net/?p=3969034",
      "post_type": "post",
      "post_name": "నీట్-పరీక్ష-వెబ్‌సైట్లో",
      "post_mime_type": "",
      "totalLikes": 6,
      "totalViews": 9814,
      "totalComments": 0,
      "image_url": "https://chotanews.azureedge.net/media/2025/04/A8-680aeb65426d4.jpg",
      "video_url": "",
      "downloadUrl": null,
      "gallery": null,
      "type": "Standard",
      "totalShares": 0,
      "isReporter": 0,
      "reportedBy": "",
      "categoryName": "నేషనల్",
      "postUrl": "",
      "subType": "StandardLink",
      "isStickyPost": 0,
      "adPosition": null,
      "linkURLAndroid": "https://apps.signitivessoft.com/individualPage?postId=3969034",
      "linkURLIos": "https://apps.signitivessoft.com/individualPage?postId=3969034",
      "links": [
        {"id": "link1", "value": "https://neet.nta.nic.in/"}
      ],
      "categoryId": 2,
      "isBookmarked": 0
    },

  ];

  Offset _dragOffset = Offset.zero;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    // threshold to consider as swipe
    if (_dragOffset.dy < -300 || _dragOffset.dy > 300) {
      setState(() {
        // move the first card to end of list
        final swipedPost = posts.removeAt(0);
        posts.add(swipedPost);
        _dragOffset = Offset.zero;
      });
    } else {
      // reset position if not swiped enough
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.65;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: posts
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final post = entry.value;

                // Step position & scale
                final verticalOffset = index * 12.0;
                final scaleFactor = 1 - index * 0.02;
                final opacity = (1 - index * 0.08).clamp(0.5, 1.0);

                // Only top card gets swipe interaction
                final isTopCard = index == 0;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  top: isTopCard ? _dragOffset.dy : verticalOffset,
                  left: 0,
                  right: 0,
                  child: Transform.scale(
                    scale: scaleFactor.clamp(1, 2),
                    child: Opacity(
                      opacity: opacity,
                      child: GestureDetector(
                        onVerticalDragUpdate: isTopCard ? _onVerticalDragUpdate : null,
                        onVerticalDragEnd: isTopCard ? _onVerticalDragEnd : null,
                        child: Card(
                          elevation: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            height: cardHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (post["image_url"] != null && post["image_url"].toString().isNotEmpty)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    child: Image.network(
                                      post["image_url"],
                                      height: 200,
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
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              })
              .toList()
              .reversed
              .toList(),
        ),
      ),
    );
  }
}

/*class SwipeStackView extends StatefulWidget {
  @override
  _SwipeStackViewState createState() => _SwipeStackViewState();
}

class _SwipeStackViewState extends State<SwipeStackView>
    with TickerProviderStateMixin {
  List<Color> cardColors = [
    Colors.orange,
    Colors.blue,
    Colors.black,
    Colors.green,
    Colors.purple,
  ];

  List<Color> removedCards = [];

  Offset slideOffset = Offset.zero;
  bool isAnimating = false;

  void animateRemoveTopCard() async {
    if (cardColors.isEmpty || isAnimating) return;
    setState(() {
      isAnimating = true;
      slideOffset = Offset(0, -1); // Slide up
    });
    await Future.delayed(Duration(milliseconds: 800));
    setState(() {
      removedCards.add(cardColors.removeLast());
      slideOffset = Offset.zero;
      isAnimating = false;
    });
  }

  void animateUndoCard() async {
    if (removedCards.isEmpty || isAnimating) return;
    setState(() {
      isAnimating = true;
      slideOffset = Offset(0, 1); // Start from bottom
      cardColors.add(removedCards.removeLast());
    });

    await Future.delayed(Duration(milliseconds: 50));
    setState(() {
      slideOffset = Offset.zero;
    });

    await Future.delayed(Duration(milliseconds: 800));
    setState(() {
      isAnimating = false;
    });
  }

  void animateRedoCard() => animateRemoveTopCard();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Swipe Stack"),
        actions: [
          IconButton(icon: Icon(Icons.undo), onPressed: animateUndoCard),
          IconButton(icon: Icon(Icons.redo), onPressed: animateRedoCard),
        ],
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond.dy;

          if (velocity < -500) {
            animateRemoveTopCard();
          } else if (velocity > 500) {
            animateUndoCard();
          }
        },
        child: Center(
          child: cardColors.isEmpty
              ? Text(
            "No more cards!",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          )
              : Stack(
            alignment: Alignment.center,
            children: List.generate(cardColors.length, (index) {
              final isTopCard = index == cardColors.length - 1;
              double padding = (cardColors.length - index - 1) * 4.sp;

              return Positioned(
                top: padding,
                bottom: padding,
                left: padding,
                right: padding,
                child: AnimatedSlide(
                  offset: isTopCard ? slideOffset : Offset.zero,
                  duration: Duration(seconds: 2),
                  curve: Curves.easeInOutCubic,
                  child: AnimatedOpacity(
                    opacity:
                    isTopCard && slideOffset.dy != 0 ? 0.0 : 1.0,
                    duration: Duration(seconds: 2),
                    curve: Curves.easeInOutCubic,
                    child: Card(
                      color: cardColors[index],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: Text(
                          "Card ${index + 1}",
                          style: TextStyle(
                              fontSize: 20.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}*/
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
//
// import '../../aggricator_screens/home_screen/home_provider.dart';
// import '../../aggricator_screens/home_screen/image_view.dart';
// import '../../aggricator_screens/home_screen/standard_post_view.dart';
// import '../../utils/app_colors.dart';
// import '../home_screen/home_screens/in_app_web_view.dart';
// import '../videos_main/video_views/gallery_screen.dart';
//
// class SwipeStackView extends StatefulWidget {
//   @override
//   _SwipeStackViewState createState() => _SwipeStackViewState();
// }
//
// class _SwipeStackViewState extends State<SwipeStackView>
//     with TickerProviderStateMixin {
//   List<Map<String, dynamic>> displayedCards = [];
//   List<Map<String, dynamic>> removedCards = [];
//   Offset slideOffset = Offset.zero;
//   bool isAnimating = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await context.read<HomeProvider>().getAllPost();
//       final posts = context.read<HomeProvider>().getAllPostList;
//       setState(() {
//         displayedCards = List<Map<String, dynamic>>.from(posts);
//       });
//     });
//   }
//
//   void animateRemoveTopCard() async {
//     if (displayedCards.isEmpty || isAnimating) return;
//     setState(() {
//       isAnimating = true;
//       slideOffset = Offset(0, -1);
//     });
//     await Future.delayed(Duration(milliseconds: 800));
//     setState(() {
//       removedCards.add(displayedCards.removeLast());
//       slideOffset = Offset.zero;
//       isAnimating = false;
//     });
//   }
//
//   void animateUndoCard() async {
//     if (removedCards.isEmpty || isAnimating) return;
//     setState(() {
//       isAnimating = true;
//       slideOffset = Offset(0, 1);
//       displayedCards.add(removedCards.removeLast());
//     });
//
//     await Future.delayed(Duration(milliseconds: 50));
//     setState(() {
//       slideOffset = Offset.zero;
//     });
//
//     await Future.delayed(Duration(milliseconds: 800));
//     setState(() {
//       isAnimating = false;
//     });
//   }
//
//   Widget buildCard(Map<String, dynamic> post, int index) {
//     final homeProvider = context.read<HomeProvider>();
//     final type = post['type'].toString();
//
//     if (type == "WebUrl") {
//       return InkWell(
//         onTap: () {
//           Navigator.push(context, MaterialPageRoute(
//             builder: (context) => InAppWebViewScreen(
//               webUrl: homeProvider.webUrl.toString(),
//               title: "IPL Update",
//             ),
//           ));
//         },
//         child: ClipRRect(
//           borderRadius: BorderRadius.all(Radius.circular(10.r)),
//           child: Image.asset(
//             "assets/svg/ipl.png",
//             fit: BoxFit.cover,
//           ),
//         ),
//       );
//     } else if (type == "Image") {
//       return ImageView(index: index, getAllPostList: post);
//     } else if (type == "Gallery") {
//       return Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.all(Radius.circular(12)),
//             child: FullPageCarousel(
//               isHome: false,
//               imageUrls: post['gallery'] ?? [],
//               postDetails: post,
//             ),
//           ),
//           Positioned(
//             top: 18,
//             right: 22,
//             child: Consumer<HomeProvider>(builder: (_, homeProvider, __) {
//               return GestureDetector(
//                 onTap: () {
//                   homeProvider.isBookMarkPost(post, context);
//                 },
//                 child: Container(
//                   padding: EdgeInsets.all(7),
//                   decoration: BoxDecoration(
//                     color: (homeProvider.isBookMark.contains(post['id'].toString()) ||
//                         post['isBookmarked'] == 1)
//                         ? AppColors.appButtonColor
//                         : Colors.black54,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     (homeProvider.isBookMark.contains(post['id'].toString()) ||
//                         post['isBookmarked'] == 1)
//                         ? Icons.bookmark
//                         : Icons.bookmark_outline,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ],
//       );
//     } else {
//       return StandardCard(getAllPostList: post, index: index);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context, designSize: Size(360, 690));
//
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         title: Text("Swipe Stack"),
//         actions: [
//           IconButton(icon: Icon(Icons.undo), onPressed: animateUndoCard),
//           IconButton(icon: Icon(Icons.redo), onPressed: animateRemoveTopCard),
//         ],
//       ),
//       body: GestureDetector(
//         onVerticalDragEnd: (details) {
//           final velocity = details.velocity.pixelsPerSecond.dy;
//           if (velocity < -500) {
//             animateRemoveTopCard();
//           } else if (velocity > 500) {
//             animateUndoCard();
//           }
//         },
//         child: Center(
//           child: displayedCards.isEmpty
//               ? Text(
//             "No more cards!",
//             style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
//           )
//               : Stack(
//             alignment: Alignment.center,
//             children: List.generate(displayedCards.length, (index) {
//               final isTopCard = index == displayedCards.length - 1;
//               double height = 530 - (displayedCards.length - 1 - index).toDouble() * 20;
//
//               return AnimatedSlide(
//                 offset: isTopCard ? slideOffset : Offset.zero,
//                 duration: Duration(milliseconds: 800),
//                 curve: Curves.easeInOutCubic,
//                 child: AnimatedOpacity(
//                   opacity: isTopCard && slideOffset.dy != 0 ? 0.0 : 1.0,
//                   duration: Duration(milliseconds: 800),
//                   curve: Curves.easeInOutCubic,
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16.r),
//                     ),
//                     child: SizedBox(
//                       height: height,
//                       width: double.infinity,
//                       child: buildCard(displayedCards[index], index),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
//
// class MyStackedPageView extends StatelessWidget {
//   final List<Color> colors = [
//     Colors.red,
//     Colors.green,
//     Colors.blue,
//     Colors.orange,
//     Colors.purple,
//     Colors.cyan,
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return PageView.builder(
//       itemCount: colors.length,
//       scrollDirection: Axis.vertical,
//       itemBuilder: (context, index) {
//         return Padding(
//           padding: const EdgeInsets.all(5.0),
//           child: Card(
//             color: colors[index],
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Center(
//               child: Text(
//                 'Card ${index + 1}',
//                 style: TextStyle(fontSize: 24, color: Colors.white),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
