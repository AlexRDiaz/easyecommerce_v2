import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MyCarousel extends StatelessWidget {
  final List<String> images = [
    'assets/images/logo.png',
    'assets/images/logo.png',
    'assets/images/logo.png',
    // Agrega aquí la ruta de tus imágenes
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrusel Automático'),
      ),
      body: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio:
              16 / 9, // Ajusta la relación de aspecto según tus imágenes
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
        ),
        items: images.map((image) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
