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
        blurEffectIntensity: 0,
        progressIndicator: const SpinKitFadingCircle(
          color: Color(0xFF031749),
          size: 60.0,
        ),
        dismissible: false,
        opacity: 0.4,
        color: Color.fromRGBO(211, 187, 255, 0.1),
        child: widget.content);
  }
}
