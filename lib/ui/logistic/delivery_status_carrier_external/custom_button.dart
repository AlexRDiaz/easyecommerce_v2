import 'package:flutter/material.dart';

class CustomButton extends FloatingActionButton {
  final Color color;
  final IconData icon;
  final String text;

  CustomButton({required this.color, required this.icon, required this.text})
      : super(
          onPressed: () {
            // Acción del botón
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          hoverColor: color,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
}
