import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/ui/logistic/vendor_invoices/controllers/controllers.dart';

class SalesInvoices extends StatefulWidget {
  const SalesInvoices({super.key});

  @override
  State<SalesInvoices> createState() => _SalesInvoicesState();
}

class _SalesInvoicesState extends State<SalesInvoices> {
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
