import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/helpers/server.dart';

class ShowImages extends StatefulWidget {
  List<String> urlsImgsList;

  ShowImages({required this.urlsImgsList});
  // ShowImages({required this.urlsImgsList, Key? key}) : super(key: key);

  @override
  State<ShowImages> createState() => _ShowImagesState();
}

class _ShowImagesState extends State<ShowImages> {
  String selectedImage = "";

  @override
  void initState() {
    super.initState();
    // Set the initial selected image to the first image in the list
    selectedImage =
        (widget.urlsImgsList.isNotEmpty ? widget.urlsImgsList[0] : null)!;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Row(
      children: [
        Column(
          children: [
            for (String imageUrl in widget.urlsImgsList)
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedImage = imageUrl;
                  });
                },
                child: Container(
                  width: screenWidth * 0.09,
                  height: screenHeight * 0.15,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorsSystem().colorSection2,
                      width: 1.0, // Grosor del borde
                    ),
                    borderRadius:
                        BorderRadius.circular(10.0), // Bordes redondeados
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(10.0), // Aplicar el mismo radio
                    child: Image.network(
                      "$generalServer$imageUrl",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: screenWidth * 0.35,
          height: screenHeight * 0.8,
          child: selectedImage != null
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorsSystem().colorSection2,
                      width: 1.0, // Grosor del borde
                    ),
                    borderRadius:
                        BorderRadius.circular(10.0), // Bordes redondeados
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      "$generalServer$selectedImage",
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              : Container(),
        ),
      ],
    );
  }
}
