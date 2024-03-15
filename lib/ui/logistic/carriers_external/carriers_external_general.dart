import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';

class CarriersExternalGeneral extends StatefulWidget {
  const CarriersExternalGeneral({super.key});

  @override
  State<CarriersExternalGeneral> createState() =>
      _CarriersExternalGeneralState();
}

class _CarriersExternalGeneralState extends State<CarriersExternalGeneral> {
  bool isLoading = false;
  TextEditingController searchController = TextEditingController(text: "");
  List data = [];
  int pageSize = 800;
  int currentPage = 1;
  List arrayFiltersOr = [
    "type",
    "carriers_external_simple.name",
    "coverage_external.ciudad",
    "coverage_external.dpa_provincia.provincia"
  ];
  List arrayFiltersAnd = [
    // {"/carriers_external_simple.id": "1"},
    // {"/coverage_external.dpa_provincia.id": "10"}
  ];

  List filterOr = ["name", "phone", "email", "address"];

  String defaultSort = "id:ASC";

  List<String> carriersToSelect = ["TODO"];
  TextEditingController carrierController = TextEditingController(text: "TODO");
  List<String> provinciasToSelect = ["TODO"];
  TextEditingController provinciaController =
      TextEditingController(text: "TODO");

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });

      //

      if (provinciasToSelect.length == 1) {
        var provinciasList = await Connections().getProvincias();
        for (var provincia in provinciasList) {
          provinciasToSelect.add(provincia);
        }
      }

      if (carriersToSelect.length == 1) {
        var responseCarriers =
            await Connections().getCarriersExternal(filterOr, "");
        for (var item in responseCarriers) {
          carriersToSelect.add("${item['name']}-${item['id']}");
        }
      }

      // print(carriersToSelect);
      var resposeAll = await Connections().getCoverageAll(pageSize, currentPage,
          arrayFiltersOr, arrayFiltersAnd, defaultSort, searchController.text);
      // print(data);
      data = resposeAll['data'];
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // print("error!!!:  $e");

      // ignore: use_build_context_synchronously
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  void resetFilters() {
    carrierController.text = 'TODO';
    provinciaController.text = 'TODO';

    arrayFiltersAnd = [];
    searchController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        body: Container(
          width: double.infinity,
          padding: EdgeInsets.all(15),
          child: ListView(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_circle_left,
                          size: 35,
                          color: Colors.indigo[900],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () async {
                          resetFilters();
                          loadData();
                        },
                        icon: Icon(
                          Icons.autorenew_rounded,
                          size: 35,
                          color: Colors.indigo[900],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: _modelTextField(
                        text: "Buscar", controller: searchController),
                  ),
                  const SizedBox(width: 20),
                  Text("Registros: ${data.length.toString()}"),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: screenHeight * 0.78,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: DataTable2(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  dataRowColor: MaterialStateColor.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.blue.withOpacity(0.5);
                    } else if (states.contains(MaterialState.hovered)) {
                      return const Color.fromARGB(255, 234, 241, 251);
                    }
                    return const Color.fromARGB(0, 173, 233, 231);
                  }),
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle: const TextStyle(color: Colors.black),
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  headingRowHeight: 80,
                  minWidth: 800,
                  columns: getColumns(),
                  rows: buildDataRows(data),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DataColumn2> getColumns() {
    return [
      const DataColumn2(
        label: Text('ID Provincia'),
        size: ColumnSize.S,
      ),
      // const DataColumn2(
      //   label: Text("Provincia"),
      //   size: ColumnSize.S,
      // ),
      DataColumn2(
        label: SelectFilter('Provincia', '/coverage_external.dpa_provincia.id',
            provinciaController, provinciasToSelect),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('ID Ciudad'),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Ciudad'),
        size: ColumnSize.S,
      ),
      // const DataColumn2(
      //   label: Text('ID Transporte'),
      //   size: ColumnSize.S,
      // ),
      DataColumn2(
        label: SelectFilter('Transportadora', '/carriers_external_simple.id',
            carrierController, carriersToSelect),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Tipo'),
        size: ColumnSize.S,
      ),
    ];
  }

  List<DataRow> buildDataRows(List data) {
    data = data;

    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            Text(
              // "provincia"
              data[index]['id_prov_ref'].toString(),
            ),
          ),
          DataCell(
            Text(
              // "provincia"
              data[index]['coverage_external']['dpa_provincia']['provincia']
                  .toString(),
            ),
          ),
          DataCell(
            Text(
              data[index]['id_ciudad_ref'].toString(),
            ),
          ),
          DataCell(
            Text(
              // "ciudad"
              data[index]['coverage_external']['ciudad'].toString(),
            ),
          ),
          DataCell(
            Text(
              // "transporte"
              data[index]['carriers_external_simple']['name'].toString(),
            ),
          ),
          DataCell(
            Text(
              // "tipo"
              data[index]['type'].toString(),
            ),
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: searchController,
        onSubmitted: (value) {
          loadData();
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    // Navigator.pop(context);
                    searchController.clear();
                    loadData();
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  Column SelectFilter(String title, filter, TextEditingController controller,
      List<String> listOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 4.5, top: 4.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Colors.black),
            ),
            height: 50,
            child: DropdownButtonFormField<String>(
              padding: EdgeInsets.all(5),
              isExpanded: true,
              value: controller.text,
              onChanged: (String? newValue) {
                setState(() {
                  controller.text = newValue ?? "";
                  arrayFiltersAnd
                      .removeWhere((element) => element.containsKey(filter));
                  // print(newValue);
                  // print(newValue.toString().split('-')[1]);

                  if (newValue != 'TODO') {
                    if (filter is String) {
                      arrayFiltersAnd.add({filter: newValue?.split('-')[1]});
                    } else {
                      reemplazarValor(filter, newValue!);
                      print(filter);

                      arrayFiltersAnd.add(filter);
                    }
                  } else {}

                  loadData();
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: listOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child:
                      Text(value.split("-")[0], style: TextStyle(fontSize: 15)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void reemplazarValor(Map<dynamic, dynamic> mapa, String nuevoValor) {
    mapa.forEach((key, value) {
      if (value is Map) {
        reemplazarValor(value, nuevoValor);
      } else if (key is String && value == 'valor') {
        mapa[key] = nuevoValor;
      }
    });
  }
}
