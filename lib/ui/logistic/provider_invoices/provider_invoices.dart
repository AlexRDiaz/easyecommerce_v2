import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/ui/logistic/vendor_invoices/controllers/controllers.dart';

class ProviderInvoices extends StatefulWidget {
  const ProviderInvoices({super.key});

  @override
  State<ProviderInvoices> createState() => _ProviderInvoicesState();
}

class _ProviderInvoicesState extends State<ProviderInvoices> {
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
