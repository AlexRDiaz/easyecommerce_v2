import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateInput extends StatefulWidget {
  final bool isEdit;
  final String title;
  final DateTime dateTime;
  final TextEditingController controller;
  const DateInput({
    Key? key,
    required this.isEdit,
    required this.title,
    required this.dateTime,
    required this.controller,
  }) : super(key: key);

  @override
  State<DateInput> createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  late DateTime? dateTime;
  askDate() async {
    dateTime = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(
              titleMedium: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              )
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // header background color
              onPrimary: Colors.black, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                )
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(3000),
    );

    if (dateTime != null) {
      widget.controller.text = int.parse(dateTime!.day.toString()).toString() +
          '/' +
          int.parse(dateTime!.month.toString()).toString() +
          '/' +
          int.parse(dateTime!.year.toString()).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEdit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
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
              controller: widget.controller,
              onTap: () {
                askDate();
              },
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
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.controller.text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    }
    ;
  }
}
