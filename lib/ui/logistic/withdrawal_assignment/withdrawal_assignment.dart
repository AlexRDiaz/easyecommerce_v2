import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/ui/logistic/vendor_invoices/controllers/controllers.dart';

class WithdrawalAssignment extends StatefulWidget {
  const WithdrawalAssignment({super.key});

  @override
  State<WithdrawalAssignment> createState() => _WithdrawalAssignmentState();
}

class _WithdrawalAssignmentState extends State<WithdrawalAssignment> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text("No items"),
        ),
      ),
    );
  }

}