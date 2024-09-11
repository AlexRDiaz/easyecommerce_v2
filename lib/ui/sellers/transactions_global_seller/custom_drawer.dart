import 'package:flutter/material.dart';

class CustomEndDrawer extends StatelessWidget {
  final Widget customContent;

  CustomEndDrawer({required this.customContent});
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        padding: EdgeInsets.zero, // No hay padding adicional
        margin: EdgeInsets.zero,
        child: customContent,
        // ListView(
        //   padding: EdgeInsets.zero,
        //   children: <Widget>[
        //     DrawerHeader(
        //       child: Text('Filtros'),
        //       decoration: BoxDecoration(
        //         color: Colors.blue,
        //       ),
        //     ),
        //     // Agrega tus elementos del drawer aquí
        //     ListTile(
        //       leading: Icon(Icons.home),
        //       title: Text('Home'),
        //       onTap: () {
        //         Navigator.pop(context); // Cierra el drawer
        //       },
        //     ),
        //     ListTile(
        //       leading: Icon(Icons.person),
        //       title: Text('Profile'),
        //       onTap: () {
        //         Navigator.pop(context); // Cierra el drawer
        //       },
        //     ),
        //     // Agrega más ListTile según sea necesario
        //   ],
        // ),
      ),
    );
  }
}
