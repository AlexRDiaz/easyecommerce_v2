import 'package:flutter/material.dart';

class InputRow extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  const InputRow({
    Key? key,
    required this.controller,
    required this.title,
  }) : super(key: key);

  @override
  State<InputRow> createState() => _InputRowState();
}

class _InputRowState extends State<InputRow> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title),
        const SizedBox(
          height: 20,
        ),
        Container(
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: const Color.fromARGB(255, 245, 244, 244),
          ),
          child: TextField(
            controller: widget.controller,
            onChanged: (value) {
              setState(() {});
            },
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                borderRadius: BorderRadius.circular(10.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
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
  }
}
