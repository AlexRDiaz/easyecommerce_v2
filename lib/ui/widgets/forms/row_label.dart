import 'package:flutter/material.dart';

class RowLabel extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Widget? trail;
  const RowLabel({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    this.trail,
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
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                  ),
                ),
              ),
              Spacer(),
              trail != null ? trail! : Offstage()
            ],
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
