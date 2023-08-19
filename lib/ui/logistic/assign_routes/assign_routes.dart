import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/ui/logistic/assign_routes/controllers/controllers.dart';

class AssignRoutes extends StatefulWidget {
  const AssignRoutes({super.key});

  @override
  State<AssignRoutes> createState() => _AssignRoutesState();
}

class _AssignRoutesState extends State<AssignRoutes> {
  AssignRoutesControllers _controllers = AssignRoutesControllers();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: ScrollConfiguration(
                behavior: const ScrollBehavior()
                    .copyWith(physics: const ClampingScrollPhysics()),
                child: DataTable2(
                    scrollController: ScrollController(),
                    headingTextStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                    dataTextStyle:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 2000,
                    columns: [
                      DataColumn2(
                        label: Text('Fecha'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Código'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Ciudad'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Transportadora'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Ruta Asignada'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Nombre Cliente'),
                        size: ColumnSize.L,
                        numeric: true,
                      ),
                      DataColumn2(
                        label: Text('Dirección'),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text('Teléfono Cliente'),
                        numeric: true,
                      ),
                      DataColumn2(
                        label: Text('Teléfono'),
                        numeric: true,
                      ),
                      DataColumn2(
                        label: Text('Cantidad'),
                        numeric: true,
                      ),
                      DataColumn2(
                        label: Text('Producto'),
                      ),
                      DataColumn2(
                        label: Text('Producto Extra'),
                      ),
                      DataColumn2(
                        label: Text('Precio Total'),
                        numeric: true,
                      ),
                      DataColumn2(
                        label: Text('Status'),
                      ),
                      DataColumn2(
                        label: Text('Confirmado'),
                      ),
                      DataColumn2(
                        label: Text('Cos. Transportadora'),
                        numeric: true,
                      ),
                      DataColumn2(
                        label: Text('Logistica/ADM'),
                      ),
                      DataColumn2(
                        label: Text('Estado Devolución'),
                      ),
                      DataColumn2(
                        label: Text('Costo Devolución'),
                        numeric: true,
                      ),
                      DataColumn2(
                        label: Text('Marca Tiempo Envio'),
                      ),
                      DataColumn2(
                        label: Text('Estado Pago'),
                      ),
                    ],
                    rows: List<DataRow>.generate(
                        10,
                        (index) => DataRow(cells: [
                              DataCell(Text('9/28/2022')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                              DataCell(Text('\$398.00')),
                            ]))),
              ),
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
