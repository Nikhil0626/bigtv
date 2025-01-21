import 'package:chotanews/screens/testing_screen/test_bloc.dart';
import 'package:chotanews/screens/testing_screen/test_event.dart';
import 'package:chotanews/screens/testing_screen/test_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {


  final PageController _pageController = PageController();
@override
  void initState() {
  context.read<TestBloc>().add(TestEventOne());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<TestBloc, TestState>(
        builder: (context, state) {
          if (state is InitialState) {
            return Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is Success) {
            return PageView.builder(
              scrollDirection: Axis.vertical, // Enable vertical swiping
              controller: _pageController,
              itemCount: state.newPosts.length,
              itemBuilder: (context, index) {
                return AnimatedNewsPage(
                  title: state.newPosts[index].title?? "No Title",
                  description: state.newPosts[index].content ?? "No Description",
                  imageUrl: state.newPosts[index].imageUrl?.url.toString(),
                  index: index,
                  controller: _pageController,
                );
              },
            );
          } else {
            // Error or other unexpected state
            return Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: Text(
                  "Something went wrong. Please try again.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Utility method for padding
  Widget addPadding({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: child,
    );
  }


}

class AnimatedNewsPage extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final int index;
  final PageController controller;

  AnimatedNewsPage({
    required this.title,
    required this.description,
    this.imageUrl,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double value = 1.0;
        if (controller.position.haveDimensions) {
          value = controller.page! - index;
          value = (1 - value.abs()).clamp(0.0, 1.0);
        }

        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageUrl != null
                      ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height/2,
                      )
                      : SizedBox.shrink(),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
