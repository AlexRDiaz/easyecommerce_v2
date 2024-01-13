import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/helpers/server.dart';

class ProductCarousel extends StatefulWidget {
  final List<String> urlImages;
  final double imgHeight;

  const ProductCarousel(
      {Key? key, required this.urlImages, required this.imgHeight})
      : super(key: key);

  @override
  State<ProductCarousel> createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  int activeIndex = 0;
  var controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: CarouselSlider.builder(
              itemCount: widget.urlImages?.length ?? 0,
              carouselController: controller,
              options: CarouselOptions(
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                autoPlay: true,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(seconds: 3),
                onPageChanged: (index, reason) {
                  setState(() {
                    activeIndex = index;
                  });
                },
              ),
              itemBuilder: (context, index, realIndex) {
                final urlImage = widget.urlImages?[index] ?? '';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    "$generalServer$urlImage",
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
        Visibility(
          visible: widget.urlImages.length > 1,
          child: Positioned(
            left: 5,
            top: (widget.imgHeight / 2) - 20,
            child: GestureDetector(
              onTap: () {
                if (activeIndex > 0) {
                  setState(() {
                    activeIndex--;
                  });
                  controller.previousPage();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.5),
                ),
                // padding: const EdgeInsets.all(5),
                child: const Icon(
                  Icons.arrow_left,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: widget.urlImages.length > 1,
          child: Positioned(
            right: 5,
            top: (widget.imgHeight / 2) - 20,
            child: GestureDetector(
              onTap: () {
                if (activeIndex < (widget.urlImages?.length ?? 0) - 1) {
                  setState(() {
                    activeIndex++;
                  });
                  controller.nextPage();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.5),
                ),
                // padding: const EdgeInsets.all(5),
                child: const Icon(
                  Icons.arrow_right,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
