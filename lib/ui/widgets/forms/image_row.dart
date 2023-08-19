import 'package:flutter/material.dart';
import 'package:frontend/helpers/server.dart';

class RowImage extends StatelessWidget {
  final String title;
  final String value;
  const RowImage({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          value != "null" ? Image.network("$generalServer$value") : Container(),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
