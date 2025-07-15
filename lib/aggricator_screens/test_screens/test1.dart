// import 'package:flutter/material.dart';
// import 'package:flutter_swiper_view/flutter_swiper_view.dart';
//
// class ExampleCustom extends StatefulWidget {
//   const ExampleCustom({Key? key}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() => _ExampleCustomState();
// }
//
// class _ExampleCustomState extends State<ExampleCustom> {
//   final List<Map<String, dynamic>> posts = [
//     {
//       "title": "వైసీపీ అధ్వర్యంలో క్యాండిల్ ర్యాలీ",
//       "content": "పల్నాడు: కాశ్మీర్లో జరిగిన ఉగ్ర దాడిని వైసీపీ నేతలు ఖండించారు...",
//       "image_url": "https://chotanews.azureedge.net/media/2025/04/17-680aefa8e3180.jpg",
//     },
//     {
//       "title": "భార‌త్‌- పాక్ మ‌ధ్య కాల్పులు",
//       "content": "భార‌త్‌- పాక్ మ‌ధ్య ఉద్రిక్త ప‌రిస్థితులు నెల‌కొన్నాయి...",
//       "image_url": "https://chotanews.azureedge.net/media/2025/03/BREAKING-67e27fe14856f.jpeg",
//     },
//     {
//       "title": "మైక్రోసాఫ్ట్‌ కీలక నిర్ణయం",
//       "content": "భారత్, దక్షిణాసియా కార్యకలాపాల కోసం కీలక నాయకత్వ మార్పులు...",
//       "image_url": "https://chotanews.azureedge.net/media/2025/04/microsoft1.jpg",
//     },
//   ];
//
//   late SwiperController _controller;
//   late CustomLayoutOption customLayoutOption;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = SwiperController();
//
//     // Bottom-to-top stacking layout
//     customLayoutOption = CustomLayoutOption(startIndex: -1, stateCount: 1)
//       ..addRotate([0.0, 0.0, 0.0])
//       ..addTranslate([
//         const Offset(0.0, 20.0),  // Next card (bottom)
//       ])
//       ..addScale([
//         0.9,  // Previous card
//         1.0,  // Current card
//         0.9,  // Next card
//       ] ,Alignment.topCenter);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black87,
//       body: Padding(
//         padding: const EdgeInsets.only(top: 20.0),
//         child: Swiper(
//           controller: _controller,
//           itemCount: posts.length,
//           itemWidth: 500.0,
//           itemHeight: 600.0,
//           layout: SwiperLayout.CUSTOM, // Use custom layout
//           customLayoutOption: customLayoutOption,
//
//           scrollDirection: Axis.vertical,
//           autoplay: false,
//           loop: true,
//           autoplayDelay: 3000,
//           autoplayDisableOnInteraction: false,
//           index: 0,
//           onIndexChanged: (index) {
//             // Handle index change if needed
//           },
//           onTap: (index) {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (_) => Scaffold(
//                   appBar: AppBar(title: const Text("New page")),
//                   body: Center(child: Text("Selected: ${posts[index]["title"]}")),
//                 ),
//               ),
//             );
//           },
//           indicatorLayout: PageIndicatorLayout.COLOR,
//           itemBuilder: (context, index) {
//             final post = posts[index];
//             return Card(
//               elevation: 10,
//               color: Colors.white,
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (post["image_url"] != null)
//                     ClipRRect(
//                       borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                       child: Image.network(
//                         post["image_url"],
//                         height: 350,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           post["title"] ?? '',
//                           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           post["content"] ?? '',
//                           style: Theme.of(context).textTheme.bodyMedium,
//                           maxLines: 5,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';



class Test1 extends StatelessWidget {
  const Test1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: NewsFeedPage(articles: [
        {
          "article_id" : 68272,
          "original_article_id" : null,
          "title" : "ధాన్యం కొనుగోలు కేంద్రంలో విషాదం.. వడదెబ్బతో రైతు మృతి",
          "summary" : "వడదెబ్బతో ధాన్యం కొనుగోలు కేంద్రంలో రైతు మృతి చెందిన ఘటన పెద్ద వంగర మండలం పోచంపల్లి గ్రామంలో చోటు చేసుకుంది.",
          "full_text" : "వడదెబ్బతో ధాన్యం కొనుగోలు కేంద్రంలో రైతు మృతి చెందిన ఘటన పెద్ద వంగర మండలం పోచంపల్లి గ్రామంలో చోటు చేసుకుంది. అక్కడే ఉన్న రైతులు తెలిపిన వివరాల ప్రకారం గంట్లకుంట రామోజీ తండాకు చెందిన గుగులోతు కిషన్ (51) ధాన్యం కొనుగోలు కేంద్రంలో వడ్లు పడుతుండగా ఎండవేడిమి తట్టుకోలేక వడదెబ్బతో ఒక్కసారిగా కుప్పకూలి మృతి చెందాడని, మృతుడికి భార్య, కుమారుడు, నలుగురు కుమార్తెలు ఉన్నట్లు తెలిపారు.",
          "url" : "https://www.dishadaily.com/crime/tragedy-at-grain-purchasing-center-farmer-dies-of-heatstroke-438619",
          "image_url" : "https://www.dishadaily.com/images/logo.png",
          "video_url" : "https://www.dishadaily.com/h-upload/2025/05/12/449327-web-image.webp",
          "publish_date" : "2025-05-12 09:31:55",
          "author" : "Sumithra",
          "language_id" : 11,
          "category_id" : 9,
          "source_id" : null,
          "state_id" : null,
          "district_id" : null,
          "sentiment" : null,
          "collection_method" : "source",
          "created_at" : "2025-05-12 09:40:49",
          "updated_at" : "2025-05-12 10:19:13",
          "data_source" : "RSS",
          "language_name" : "Telugu",
          "category_name" : "General",
          "source_name" : "Disha",
          "state_name" : null,
          "generated_title" : null,
          "generated_body" : null,
          "title_word_count" : null,
          "body_word_count" : null,
          "model_type" : null,
          "response_time" : null,
          "master_source_id" : null,
          "is_new_source" : 0,
          "is_generated" : 1
        },
        {
          "article_id" : 68273,
          "original_article_id" : null,
          "title" : "7వ విడతలో సైబరాబాద్ పరిధిలో 310 సెల్ ఫోన్ల రికవరీ",
          "summary" : "తెలంగాణ రాష్ట్ర పోలీసులు దేశంలోనే నెంబర్ 1 అని, ఎక్కడ క్రైమ్ జరిగినా నిందితుల అంతు చూసేందుకు తెలంగాణ పోలీసులు సిద్ధంగా ఉంటారని, అలాగే తక్కువకు వస్తున్నాయని సెల్ ఫోన్లను కొన వద్దని, దొంగతనం అయిన ఫోన్లను కొన్నా.. కలిగి ఉన్నా నేరమే అని సైబరాబాద్ క్రైమ్స్ డీసీపీ ఎల్ సీ నాయక్ అన్నారు.",
          "full_text" : "తెలంగాణ రాష్ట్ర పోలీసులు దేశంలోనే నెంబర్ 1 అని, ఎక్కడ క్రైమ్ జరిగినా నిందితుల అంతు చూసేందుకు తెలంగాణ పోలీసులు సిద్ధంగా ఉంటారని, అలాగే తక్కువకు వస్తున్నాయని సెల్ ఫోన్లను కొన వద్దని, దొంగతనం అయిన ఫోన్లను కొన్నా.. కలిగి ఉన్నా నేరమే అని సైబరాబాద్ క్రైమ్స్ డీసీపీ ఎల్ సీ నాయక్ అన్నారు. సైబరాబాద్ కమిషనరేట్ లో ఆయా పోలీసు స్టేషన్ల పరిధిలో దొంగతనం అయిన సుమారు రూ.95 లక్షల విలువైన 310 సెల్ ఫోన్లను సైబరాబాద్ క్రైమ్స్ డీసీపీ ఎల్ సీ నాయక్ సోమవారం బాధితులకు అప్పగించారు. వీటిలో ఐ ఫోన్లతో పాటు పలువిలువైన మొబైల్ ఫోన్లు ఉన్నాయి. కొందరి ఫోన్లు సంవత్సరం తర్వాత దొరకగా, ఇంకొన్ని 15 రోజుల్లోనే రికవరీ కావడం విశేషం. పోగొట్టుకున్న ఫోన్లు తిరిగి పొందిన బాధితులు ఆనందం వ్యక్తం చేశారు. ఈ సందర్భంగా సైబరాబాద్ క్రైమ్స్ డీసీపీ ఎల్ సీ నాయక్ మాట్లాడుతూ గతంలో చైన్ స్నాచింగ్ లు, ఇళ్లలో దొంగతనాలు జరిగేవి కానీ ఈ మధ్య కాలంలో సెల్ ఫోన్ల దొంగతనాలు, సైబర్ క్రైమ్స్ ఎక్కువగా జరుగుతున్నాయని గుర్తు చేశారు. కొన్నిసార్లు అనుకోకుండా, మరికొన్ని సార్లు దొంగలు మొబైల్ ఫోన్స్ చోరీ చేస్తున్నారని అలా రోజుకు చాలా ఫోన్లు చోరీలకు గురవుతున్నాయని అన్నారు.  సైబరాబాద్ పరిధిలోని 5 సీసీ ఎస్ పోలీసులు నిర్విరామంగా పని చేసి, వ్యయప్రయాసలకు ఓర్చి ఫోన్లను రికవరీ చేశారని, సైబరాబాద్ పరిధిలో చోరీకి గురై దేశంలో ఎక్కడెక్కడో ఉన్న ఫోన్లను తిరిగి తెప్పించామని అన్నారు. పోలీసులు ఎప్పుడూ మన రక్షకులేనన్న ఆయన పోలీసుల మీద నెగిటివ్ ఫీలింగ్ తీసేయాలని ప్రజలకు సూచించారు. పోలీసు వ్యవస్థ సమాజంలో సత్ప్రవర్తన కల్పించేందుకు కృషి చేస్తుందని, సమాజంలో జరుగుతున్న అకృత్యాలను పోలీసుల దృష్టికి తీసుకురావాలని కోరారు. ఫ్రెండ్లీ పోలీసింగ్ అనేది సమాజంలో ఉన్న మంచి వారికేనని, అసాంఘిక శక్తుల పట్ల కఠినంగా ఉంటామని క్రైమ్స్ డీసీపీ ఎల్ సీ నాయక్ స్పష్టం చేశారు. నగరంలో దొంగతనం అయిన ఫోన్లు అసాంఘిక శక్తుల చేతులకు వెళ్తున్నాయని, సాధ్యమైనంత వరకు ఫోన్లు పోగొట్టుకోకుండా జాగ్రత్తగా వ్యవహరించాలని, సెకండ్ హ్యాండ్ ఫోన్లను అసలే కొనవద్దని సైబరాబాద్ క్రైమ్స్ డీసీపీ ఎల్ సీ నాయక్ సూచించారు. దొంగ సొమ్ములను ఎవరూ కొనవద్దని అవి కొన్నా, మీ దగ్గర ఉన్నానేరమే అని అన్నారు. యూపీఐ పేమెంట్ చేసేటప్పుడు కూడా జాగ్రత్తగా వ్యవహరించాలని, చుట్టుపక్కల సీసీ కెమెరాలు ఉన్నాయా, లేదా ఎవరైనా గమణిస్తున్నారా అన్నది పరిశీలించాలని అన్నారు. అలాగే యాప్స్ తో జాగ్రత్తగా ఉండాలని, సైబర్ నేరాలు జరిగితే 1930 డయల్ చేయాలని డీసీపీ కోరారు. ప్రజలు పోగొట్టుకున్న ఫోన్ల రికవరీలో కీలకంగా వ్యవహరించిన సీఐ, ఎస్సై, కానిస్టేబుళ్లను డీసీపీ ఎల్ సీ నాయక్ అభినందించారు. గత 7 విడతల్లో సైబరాబాద్ పరిధిలో చోరీకి గురైన సుమారు 9 వేల ఫోన్లను రికవరీ చేశారు. 7వ విడతలో మొత్తంగా మాదాపూర్,  బాలానగర్, మేడ్చల్, రాజేంద్రనగర్ జోన్, శంషాబాద్ జోన్, ఐటీ సెల్, మేడ్చల్ లా అండ్ ఆర్డర్ పోలీసు స్టేషన్ల పరిధిలో 310 సెల్ ఫోన్లను రికవరీ చేశారు. పోగొట్టుకున్న ఫోన్లను తిరిగి పొందిన బాధితులు ఆనందం వ్యక్తం చేశారు.",
          "url" : "https://www.dishadaily.com/telangana/hyderabad/310-cell-phones-recovered-in-cyberabad-area-in-7th-phase-438618",
          "image_url" : "https://www.dishadaily.com/images/logo.png",
          "video_url" : "https://www.dishadaily.com/h-upload/2025/05/12/449326-web-image.webp",
          "publish_date" : "2025-05-12 09:28:31",
          "author" : "Sumithra",
          "language_id" : 11,
          "category_id" : 9,
          "source_id" : null,
          "state_id" : null,
          "district_id" : null,
          "sentiment" : null,
          "collection_method" : "source",
          "created_at" : "2025-05-12 09:40:49",
          "updated_at" : "2025-05-12 10:19:15",
          "data_source" : "RSS",
          "language_name" : "Telugu",
          "category_name" : "General",
          "source_name" : "Disha",
          "state_name" : null,
          "generated_title" : null,
          "generated_body" : null,
          "title_word_count" : null,
          "body_word_count" : null,
          "model_type" : null,
          "response_time" : null,
          "master_source_id" : null,
          "is_new_source" : 0,
          "is_generated" : 1
        },
        {
          "article_id" : 68274,
          "original_article_id" : null,
          "title" : "పాక్ దాడిలో పూంచ్ ప్రాంతం ఎక్కువగా ప్రభావితమైంది: సీఎం ఒమర్ అబ్దుల్లా",
          "summary" : "కశ్మీర్ లోని పహల్గామ్ లో పాకిస్తాన్ ఉగ్రవాదులు పర్యాటకులపై దాడి చేసి.. 26 మందిని దారుణంగా కాల్చి చంపారు.",
          "full_text" : "కశ్మీర్ లోని పహల్గామ్ లో పాకిస్తాన్ ఉగ్రవాదులు పర్యాటకులపై దాడి చేసి.. 26 మందిని దారుణంగా కాల్చి చంపారు. ఈ ఘటనతో భారత్, పాకిస్తాన్ మధ్య యుద్ధ వాతావరణం (War atmosphere) నెలకొంది. భారత పర్యాటకులపై దాడికి ప్రతిస్పందనగా భారత్ ఆర్మీ పీఓకే, పాక్ లోని 9 ఉగ్రవాద శిబిరాలపై దాడి చేసి.. 100 మంది ఉగ్రవాదులను హతమార్చింది. ఈ దాడికి ప్రతీకారంగా పాకిస్తాన్ సరిహద్దు ప్రాంతాలపై దాడులకు పాల్పడింది. దీంతో ఇరు దేశాల ఉద్రిక్తతలు తీవ్రమైన విషయం తెలిసిందే. కాగా పాక్ సైన్యం ముఖ్యంగా జమ్మూ, కశ్మీర్ రాష్ట్రంలోని పలు ప్రాంతాలను లక్ష్యంగా చేసుకొని కాల్పులు జరిపారు. అలాగే డ్రోన్లు, మిస్సైల్స్ తో దాడులు చేశారు. ఈ దాడుల్లో స్థానికులు మృతి చెందారు. కాగా పాక్ దాడిలో మృతి చెందిన వారి కుటుంబ సభ్యులను సీఎం ఒమర్ అబ్దుల్లా (CM Omar Abdullah) కలిశారు.  అనంతరం ఆయన మీడియాతో మాట్లాడుతూ కీలక వ్యాఖ్యలు చేశారు. \" 3-4 రోజులు జమ్మూ కశ్మీర్‌లో యుద్ధం లాంటి వాతావరణం ఉంది. పాకిస్థాన్ కాల్పుల వల్ల పూంచ్ ప్రాంతం ఎక్కువగా ప్రభావితమైంది. పాక్ కాల్పుల్లో 13 మంది ప్రజలు తమ ప్రాణాలు కోల్పోయారు. నేను ఇక్కడికి వచ్చి బాధితుల ఇళ్లను సందర్శించాను. ఈ క్లిష్ట పరిస్థితిలో కూడా సోదరభావాన్ని కాపాడుకునేందుకు పూంచ్ ప్రజలకు ధన్యవాదాలు. భవిష్యత్తులో ఇలాంటి సంఘటన జరిగితే.. ఇలాంటి భారీ నష్టాలను నివారించడానికి పౌర సమాజం నుండి మాకు సూచనలు వచ్చాయి\" స్థానిక ప్రజల సూచనలను దృష్టిలో పెట్టుకొని ముందుకు వెళ్తాము అని\" సీఎం ఒమర్ అబ్దుల్లా చెప్పుకొచ్చారు.",
          "url" : "https://www.dishadaily.com/OperationSindoor/poonch-area-worst-affected-by-pak-attack-cm-omar-abdullah-438617",
          "image_url" : "https://www.dishadaily.com/images/logo.png",
          "video_url" : "https://www.dishadaily.com/h-upload/2025/05/12/449325-cm-omer-abdulla.webp",
          "publish_date" : "2025-05-12 09:26:28",
          "author" : "Mahesh",
          "language_id" : 11,
          "category_id" : 1,
          "source_id" : null,
          "state_id" : null,
          "district_id" : null,
          "sentiment" : null,
          "collection_method" : "source",
          "created_at" : "2025-05-12 09:40:49",
          "updated_at" : "2025-05-12 10:19:16",
          "data_source" : "RSS",
          "language_name" : "Telugu",
          "category_name" : "Politics",
          "source_name" : "Disha",
          "state_name" : null,
          "generated_title" : null,
          "generated_body" : null,
          "title_word_count" : null,
          "body_word_count" : null,
          "model_type" : null,
          "response_time" : null,
          "master_source_id" : null,
          "is_new_source" : 0,
          "is_generated" : 1
        }
      ],),
    );
  }
}

class NewsFeedPage extends StatefulWidget {
  final List<Map<String, dynamic>> articles;

  NewsFeedPage({required this.articles});

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  PageController pageController = PageController();

  void goToFirstPage() {
    pageController.animateToPage(0,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Scaffold(
        backgroundColor: Color(0xFFF7F8F9),
        body: PageView.builder(
          controller: pageController,
          itemCount: widget.articles.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            final article = widget.articles[index];
            return NewsArticlePage(
              article: article,
              onReload: goToFirstPage,
            );
          },
        ),
      ),
    );
  }
}




class NewsArticlePage extends StatefulWidget {
  final Map<String, dynamic> article;
  final VoidCallback onReload;

  NewsArticlePage({required this.article, required this.onReload});

  @override
  State<NewsArticlePage> createState() => _NewsArticlePageState();
}

class _NewsArticlePageState extends State<NewsArticlePage> {
  bool liked = false;
  bool isLoading = false;

  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> _shareScreenshot() async {
    try {
      final image = await screenshotController.capture(
        pixelRatio: 2,
      );
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/${DateTime.now()}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);

        Share.shareXFiles([XFile(imageFile.path)], text: widget.article['url']);
      }
    } catch (e) {
      // CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final imageUrl = article['image_url'] ?? '';
    final url = article['url'] ?? '';
    final mainUrl = article['video_url'] ?? '';
    final title = article['title'] ?? '';
    final content = article['full_text'] ?? article['full_text'] ?? '';
    final sourceName = article['source_name'] ?? '';
    final publishTime = DateTime.tryParse(article['publish_date'] ?? '');
    final relativeTime = publishTime != null ? timeago.format(publishTime) : '';

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Screenshot(
        controller: screenshotController,
        child: Stack(
          children: [
            SizedBox(
              height:  MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height*.4,
                    child: Container(
                      color:Color(0xFFF7F8F9),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        child: CachedNetworkImage(
                          imageUrl: mainUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) =>
                              Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top:  MediaQuery.of(context).size.height*.4-20,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*.6,
                      width: MediaQuery.of(context).size.width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        child: Container(
                          color: Color(0xFFF7F8F9),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style:  GoogleFonts.notoSansTelugu(
                                      textStyle: TextStyle(
                                          fontSize: 20 ,
                                          height: 1.4,
                                          fontWeight: FontWeight.bold,
                                          wordSpacing: 2,color: Colors.black))),
                              height(height: 12),

                              Text(
                                content.length > 430 ? content.substring(0, 430) + '…' : content,
                                style: GoogleFonts.notoSansTelugu(
                                  textStyle: const TextStyle(
                                    fontSize: 17,
                                    height: 1.4,
                                    wordSpacing: 2,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              height(height: 12),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _launchURL(url);
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        border: Border.all(color: Colors.grey, width: 1),
                                        image: DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),

                                  width(width: 10),
                                  Text("$sourceName | ",
                                      style: TextStyle(fontSize: 14)),
                                  Text(relativeTime,
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              Spacer(),
                              Container(
                                color:Color(0xFFF7F8F9),
                                padding: const EdgeInsets.symmetric( horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    isLoading
                                        ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 1,color: Colors.blueAccent,))
                                        : IconButton(
                                      icon: Icon(Icons.refresh, size: 24,),
                                      onPressed: () async {
                                        setState(() => isLoading = true);
                                        await Future.delayed(Duration(seconds: 2));
                                        setState(() => isLoading = false);
                                        widget.onReload();
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        liked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                        color: liked ? Colors.green : null,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        setState(() => liked = !liked);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.comment_outlined, size: 24),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                          ),
                                          builder: (BuildContext context) {
                                            return CommentBottomSheet();
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.share_outlined, size: 24,),
                                      onPressed: _shareScreenshot,
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
                  // Bottom Bar - Actions

                ],
              ),
            ),
            Positioned(
              left: 30,
              top:  MediaQuery.of(context).size.height * .4-40,
              child: Container(
                height: 25,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Chota ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "News",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff00A8FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _launchURL(sourceUrl) async {
    Uri uri =Uri.parse("https://www.dishadaily.com/crime/tragedy-at-grain-purchasing-center-farmer-dies-of-heatstroke-438619");

    final Uri url = Uri.parse(sourceUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // throw 'Could not launch $url';
    }
  }
}

class Comment {
  final String text;
  final DateTime time;

  Comment(this.text, this.time);
}

class CommentBottomSheet extends StatefulWidget {
  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<Comment> _comments = [
    Comment('Great post!', DateTime.now().subtract(Duration(minutes: 3))),
    Comment('Nice article!', DateTime.now().subtract(Duration(minutes: 2))),
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _addComment() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _comments.insert(0, Comment(_controller.text.trim(), DateTime.now()));
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          height(height: 10),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(comment.text[0])),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment.text),
                      height(height: 4),
                      Text(
                        timeago.format(comment.time),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(),
          Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a comment';
                      }
                      return null;
                    },
                  ),
                ),
                width(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  child: Text('Send'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

