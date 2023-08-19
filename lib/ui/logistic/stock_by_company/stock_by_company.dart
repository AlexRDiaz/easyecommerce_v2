import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/ui/logistic/stock_by_company/controllers/controllers.dart';

class StockByCompany extends StatefulWidget {
  const StockByCompany({super.key});

  @override
  State<StockByCompany> createState() => _StockByCompanyState();
}

class _StockByCompanyState extends State<StockByCompany> {
  StockByCompanyControllers _controllers = StockByCompanyControllers();
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
                  minWidth: 800,
                  columns: [
                    DataColumn2(
                      label: Text('Nombre Artículo'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: Text('Precio'),
                      size: ColumnSize.M,
                    ),
                    DataColumn2(
                        label: Text('Stock'),
                        size: ColumnSize.M,
                        numeric: true),
                    DataColumn2(
                      label: Text(''),
                      size: ColumnSize.M,
                    ),
                  ],
                  rows: List<DataRow>.generate(
                      10,
                      (index) => DataRow(cells: [
                            DataCell(Text('AURICULAR F9')),
                            DataCell(Text('\$12')),
                            DataCell(Text('Quedan 0 pz')),
                            DataCell(Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Icon(Icons.arrow_forward_ios_rounded),
                              ],
                            )),
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
