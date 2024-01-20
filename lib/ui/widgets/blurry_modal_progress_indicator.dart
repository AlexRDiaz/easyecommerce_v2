import 'package:flutter/material.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomProgressModal extends StatefulWidget {
  final Widget content;
  final bool isLoading;
  const CustomProgressModal(
      {Key? key, required this.content, required this.isLoading})
      : super(key: key);

  @override
  _CustomProgressModalState createState() => _CustomProgressModalState();
}

class _CustomProgressModalState extends State<CustomProgressModal> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
        inAsyncCall: widget.isLoading,
        blurEffectIntensity: 4,
        progressIndicator: SpinKitFadingCircle(
          color: Colors.purple,
          size: 90.0,
        ),
        dismissible: false,
        opacity: 0.4,
        color: Colors.black87,
        child: widget.content);
  }
}
