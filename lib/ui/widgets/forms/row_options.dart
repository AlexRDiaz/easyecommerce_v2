import 'package:flutter/material.dart';

class RowOptions extends StatefulWidget {
  final String title;
  final List<String> options;
  final Function(String) onSelect;
  const RowOptions({
    Key? key,
    required this.title,
    required this.options,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<RowOptions> createState() => _RowOptionsState();
}

class _RowOptionsState extends State<RowOptions> {
  String _selected = "";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Column(
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
            child: Row(
              children: widget.options
                  .map(
                    (value) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                _selected == value ? Colors.blue : const Color.fromRGBO(
                                  237,
                                  241,
                                  245,
                                  1.0,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selected = value;
                                });
                                widget.onSelect(_selected);
                              },
                              child: Text(value,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),),
                            )
                        ),
                      )
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
