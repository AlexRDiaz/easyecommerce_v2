import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final bool isEdit;
  final String title;
  final TextEditingController controller;
  final bool isNumber;
  const TextInput({
    Key? key,
    required this.isEdit,
    required this.controller,
    required this.title,
    this.isNumber = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isEdit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                10.0,
              ),
              color: const Color.fromARGB(
                255,
                245,
                244,
                244,
              ),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color.fromRGBO(237, 241, 245, 1.0),
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 1,
                    color: Color.fromRGBO(
                      237,
                      241,
                      245,
                      1.0,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusColor: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    } else {
      return SizedBox(
        width: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              controller.text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    }
  }
}
