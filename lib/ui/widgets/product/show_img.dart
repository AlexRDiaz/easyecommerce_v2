import 'package:flutter/material.dart';
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
                  width: screenWidth * 0.08,
                  height: screenHeight * 0.15,
                  margin: const EdgeInsets.all(5),
                  child: Image.network(
                    "$generalServer$imageUrl",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: screenWidth * 0.4,
          height: screenHeight * 0.8,
          child: selectedImage != null
              ? Image.network(
                  "$generalServer$selectedImage",
                  fit: BoxFit.fill,
                )
              : Container(),
          // child: FadeInImage(
          //   placeholder: NetworkImage("$generalServer$selectedImage"),
          //   image: NetworkImage("$generalServer$selectedImage"),
          //   fit: BoxFit.cover,
          //   fadeInDuration: Duration(milliseconds: 1500),
          //   fadeOutDuration: Duration(milliseconds: 1500),
          // ),
        ),
      ],
    );
  }
}
