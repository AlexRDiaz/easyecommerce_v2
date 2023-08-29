import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:flutter_animated_icons/lottiefiles.dart';
import 'package:flutter_animated_icons/useanimations.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

class CustomSuccessModal extends StatefulWidget {
  final String text;
  final String animatedIcon;

  const CustomSuccessModal(
      {super.key, required this.text, required this.animatedIcon});
  @override
  State<CustomSuccessModal> createState() => _CustomSuccessModalState();
}

class _CustomSuccessModalState extends State<CustomSuccessModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  late AnimationController _settingController;
  @override
  void initState() {
    super.initState();

    _settingController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    _animation = new Tween<double>(begin: 0, end: 1).animate(
        new CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOutCirc));
  }

  @override
  Widget build(BuildContext context) {
    _settingController.reset();
    _settingController.forward();
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(widget.animatedIcon, controller: _settingController),
          SizedBox(height: 10),
          Text(widget.text),
        ],
      ),
    );
  }
}

showSuccessModal(BuildContext context, text, icon) {
  showDialog(
    context: context,
    builder: (context) => CustomSuccessModal(text: text, animatedIcon: icon),
  );
}
