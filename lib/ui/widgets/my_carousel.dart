import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:carousel_slider/carousel_controller.dart';

class MyCarousel extends StatefulWidget {
  const MyCarousel({Key? key}) : super(key: key);

  @override
  State<MyCarousel> createState() => _MyCarousel();
}

class _MyCarousel extends State<MyCarousel> {
  int activeIndex = 0;
  final controller = CarouselController();
  final urlImages = [
    'https://assets.website-files.com/5ecfee3d3c78d12514ee78db/643fd29c00b2f0e442162aa0_hero-visual-2.webp',
    'https://images.unsplash.com/photo-1570829053985-56e661df1ca2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: 0.8,
        child: Container(
          width: 800,
          height: 400,
          child: Stack(
            children: [
              CarouselSlider.builder(
                itemCount: urlImages.length,
                itemBuilder: (context, index, realIndex) {
                  final urlImage = urlImages[index];
                  return Container(
                    width: double.infinity,
                    height: 400,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image.network(
                        urlImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  autoPlay: true,
                  enableInfiniteScroll: false,
                  autoPlayAnimationDuration: Duration(seconds: 2),
                  enlargeCenterPage: true,
                ),
              ),
              Positioned(
                left: 10,
                top: 180,
                child: GestureDetector(
                  onTap: () {
                    // Lógica para ir a la imagen anterior
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_left,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 180,
                child: GestureDetector(
                  onTap: () {
                    // Lógica para ir a la siguiente imagen
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
        onDotClicked: animateToSlide,
        effect: ExpandingDotsEffect(dotWidth: 15, activeDotColor: Colors.blue),
        activeIndex: activeIndex,
        count: urlImages.length,
      );

  void animateToSlide(int index) => controller.animateToPage(index);
}

Widget buildImage(String urlImage, int index) =>
    Container(child: Image.network(urlImage, fit: BoxFit.cover));
