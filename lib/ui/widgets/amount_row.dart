import 'package:flutter/material.dart';

class AmountRow extends StatelessWidget {
  final String amount;
  const AmountRow({
    Key? key,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.3),
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          "\$$amount",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ));
  }
}
