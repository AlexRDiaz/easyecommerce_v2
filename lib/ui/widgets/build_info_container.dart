import 'package:flutter/material.dart';

class BuildInfoContainer extends StatelessWidget {
  final String title;
  final String value;
  final bool isTitleOnTop;

  const BuildInfoContainer(
      {super.key,
      required this.title,
      required this.value,
      this.isTitleOnTop = false});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textSizeTitle = screenWidth > 600 ? 22 : 14;
    double textSizeText = screenWidth > 600 ? 16 : 11;

    return Container(
      // height: 75,
      padding: EdgeInsets.all(screenWidth > 600 ? 10 : 5),
      // width: 250,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1A2B3C)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTitleOnTop)
            Align(
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: textSizeText,
                ),
              ),
            ),
          Align(
            alignment: Alignment.center,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: textSizeTitle,
                color: Color.fromARGB(255, 22, 138, 232),
              ),
            ),
          ),
          const SizedBox(height: 3),
          if (!isTitleOnTop)
            Align(
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: textSizeText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
