import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';

class BuildInfoContainerSeller extends StatelessWidget {
  final String title;
  final String value;
  final Icon iconOfTitle;
  final bool isTitleOnTop;

  const BuildInfoContainerSeller(
      {super.key,
      required this.title,
      required this.value,
      required this.iconOfTitle,
      this.isTitleOnTop = true});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textSizeTitle = screenWidth > 600 ? 24 : 14;
    double textSizeText = screenWidth > 600 ? 12 : 11;

    return Container(
      // height: 75,
      padding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 40 : 5,vertical: screenWidth > 600 ? 10 : 5),
      // width: 250,
      decoration: BoxDecoration(
        // border: Border.all(color: const Color(0xFF1A2B3C)),
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
            Row(children: [
              Icon(
                iconOfTitle.icon,
                color: ColorsSystem().colorSelected,
              ),
              SizedBox(width: 5),
              Text(
                title,
                style: TextStylesSystem().ralewayStyle(
                    textSizeText, FontWeight.w600, ColorsSystem().colorLabels),
              ),
            ]),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: textSizeTitle,
                color: ColorsSystem().colorLabels,
              ),
              textAlign: TextAlign.center,
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
