import 'package:flutter/material.dart';

import '../options_modal.dart';

class ModalRow extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final List<String> options;
  const ModalRow({
    Key? key,
    required this.controller,
    required this.title,
    required this.options,
  }) : super(key: key);

  @override
  State<ModalRow> createState() => _ModalRowState();
}

class _ModalRowState extends State<ModalRow> {
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
              suffixIcon: InkWell(
                onTap: () async {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return OptionsModal(
                            height: 400,
                            options: widget.options,
                            onCancel: () {
                              Navigator.of(context).pop();
                            },
                            onConfirm: (String selected) {
                              setState(() {
                                widget.controller.text = selected;
                              });
                              Navigator.of(context).pop();
                            });
                      });
                },
                child: Icon(
                  Icons.add,
                  color: Colors.black,
                ),
              ),
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
