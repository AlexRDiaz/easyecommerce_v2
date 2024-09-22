import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

getThemeApp() {
  const Color cabeceraColor = Color(0xFF1A2B3C);
  const Color fondoColor = Color(0xFFEFEFEF);
  const Color textoPrincipalColor = Colors.white;
  const Color textoSecundarioColor = Color(0xFFEFEFEF);
  const Color enlacesColor = Color(0xFFF39237);
  return ThemeData(
      textTheme: GoogleFonts.robotoTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor:
              Color.fromARGB(255, 71, 71, 71), // Color del texto del botón
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0), // Bordes redondeados
          ),
          padding: EdgeInsets.symmetric(
              horizontal: 20.0, vertical: 10.0), // Espaciado interno
        ),
      ),
      scaffoldBackgroundColor: Color(0xFFEFEFEF),
      dataTableTheme: DataTableThemeData(
        dataRowColor: MaterialStateColor.resolveWith((states) => fondoColor),
        dataTextStyle: TextStyle(color: textoPrincipalColor),
        headingTextStyle:
            TextStyle(color: textoPrincipalColor, fontWeight: FontWeight.bold),
        headingRowHeight: 40.0, // Ajusta esta altura según tus necesidades
        dataRowHeight: 56.0, // Ajusta esta altura según tus necesidades
        dividerThickness: 1.0,
        horizontalMargin: 12.0,
        columnSpacing: 10.0,
        checkboxHorizontalMargin: 0.0,
      ),
      appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0.5,
          // backgroundColor: Color(0xFF1A2B3C),
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.white),
          centerTitle: true,
          toolbarTextStyle: TextStyle(color: Colors.black)));
}
