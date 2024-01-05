import 'package:flutter/material.dart';
import 'package:frontend/models/provider_model.dart';

class ApproveProducts extends StatefulWidget {
  final ProviderModel provider;

  const ApproveProducts({super.key, required this.provider});

  @override
  State<ApproveProducts> createState() => _ApproveProductsState();
}

class _ApproveProductsState extends State<ApproveProducts> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
