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
    'https://thelogisticsworld.com/wp-content/uploads/2022/05/mujer-joven-que-recibe-una-caja-de-paquetes-del-repartidor.jpg',
    'https://scontent.fuio32-1.fna.fbcdn.net/v/t1.6435-9/60879326_661357877650420_1464807680156631040_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=8bfeb9&_nc_ohc=tyh23d4IQIsAX-nsoC9&_nc_ht=scontent.fuio32-1.fna&oh=00_AfAvYutY6pZVuejNbw-N6xgQ4oPzDfodIb_J0q1VWuFWTw&oe=6544FB89',
    'https://i0.wp.com/blog.soyrappi.com/wp-content/uploads/2020/08/0b68ed6c-797e-4721-be51-d3d1b4fee263.jpg?ssl=1',
    'https://assets.website-files.com/5ecfee3d3c78d12514ee78db/643fd29c00b2f0e442162aa0_hero-visual-2.webp',
    'https://images.unsplash.com/photo-1570829053985-56e661df1ca2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CarouselSlider.builder(
              carouselController: controller,
              itemCount: urlImages.length,
              itemBuilder: (context, index, realIndex) {
                final urlImage = urlImages[index];
                return buildImage(urlImage, index);
              },
              options: CarouselOptions(
                  height: 500,
                  autoPlay: true,
                  enableInfiniteScroll: false,
                  autoPlayAnimationDuration: Duration(seconds: 2),
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) =>
                      setState(() => activeIndex = index))),
          SizedBox(height: 12),
          buildIndicator()
        ],
      ),
    );
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
