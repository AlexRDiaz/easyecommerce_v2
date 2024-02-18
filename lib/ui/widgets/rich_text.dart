import 'package:flutter/material.dart';

class RichTextTitleContent extends StatelessWidget {
  final String title;
  final String content;
  // final double sizeT;
  // final double sizeC;

  const RichTextTitleContent({
    super.key,
    required this.title,
    required this.content,
    // required this.sizeT,
    // required this.sizeC,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$title: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          TextSpan(
            text: content,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
