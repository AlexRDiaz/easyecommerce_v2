import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/ui/sellers/my_cart_sellers/controllers/controllers.dart';

class MyCartSellers extends StatefulWidget {
  const MyCartSellers({super.key});

  @override
  State<MyCartSellers> createState() => _MyCartSellersState();
}

class _MyCartSellersState extends State<MyCartSellers> {
  MyCartSellersControllers _controllers = MyCartSellersControllers();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colors.colorGreen,
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: _modelTextField(
                  text: "Busqueda", controller: _controllers.searchController),
            ),
            Expanded(
              child: DataTable2(
                  headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 500,
                  columns: [
                    DataColumn2(
                      label: Text('Proveedor'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: Text('No. Guía'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                      label: Text('Estado Compra'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                        label: Text('Total'),
                        size: ColumnSize.M,
                        numeric: true),
                  ],
                  rows: List<DataRow>.generate(
                      10,
                      (index) => DataRow(cells: [
                            DataCell(Text('Bodega Guayaquil')),
                            DataCell(Text('')),
                            DataCell(Text('Pendiente')),
                            DataCell(Text('\$98')),
                          ]))),
            ),
          ],
        ),
      ),
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          setState(() {});
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controllers.searchController.clear();
                    });
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }
}
