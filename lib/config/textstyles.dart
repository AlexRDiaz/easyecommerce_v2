import 'package:flutter/material.dart';

class TextStylesSystem {
  
  TextStyle ralewayStyle(fontSizeP, fontWeightP, colorP) {
    return TextStyle(
        fontFamily: 'Raleway',
        fontSize: fontSizeP,
        fontWeight: fontWeightP,
        color: colorP);
  }

  TextStyle workSansStyle(fontSizeP, fontWeightP, colorP) {
    return TextStyle(
        fontFamily: 'WorkSans',
        fontSize: fontSizeP,
        fontWeight: fontWeightP,
        color: colorP);
  }

}
