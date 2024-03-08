import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/add_product.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';

class InfoCarrierExternal extends StatefulWidget {
  final Map data;

  const InfoCarrierExternal({super.key, required this.data});

  @override
  State<InfoCarrierExternal> createState() => _InfoCarrierExternalState();
}

class _InfoCarrierExternalState extends State<InfoCarrierExternal> {
  bool isLoading = false;
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController mailController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");

  List<String> provinciasToSelect = [];
  String? selectedProvincia;
  List<String> parroquiasToSelect = [];
  String? selectedParroquia;

  List coveragesList = [];
  var data = [];

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
        provinciasToSelect = [];
        parroquiasToSelect = [];
      });
      //
      var provinciasList = [];

      provinciasList = await Connections().getProvincias();
      for (var i = 0; i < provinciasList.length; i++) {
        provinciasToSelect.add('${provinciasList[i]}');
      }

      // data = widget.data;
      print("${widget.data['id']}");
      var response =
          await Connections().getCarrierExternalById(widget.data['id']);
      // print(response);
      data = response['data'];
      setState(() {
        nameController.text = data[0]['name'].toString();
        mailController.text = data[0]['phone'].toString();
        phoneController.text = data[0]['email'].toString();
        addressController.text = data[0]['address'].toString();
        coveragesList = data[0]['carrier_coverages'];
      });

      // print(coveragesList);
      //
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
          context, "Ha ocurrido un error al cargar las Subrutas");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWith > 600 ? screenWith * 0.7 : screenWith,
      height: screenHeight * 0.9,
      color: Colors.white,
      child: CustomProgressModal(
        isLoading: isLoading,
        content: ListView(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Información",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: screenWith > 600
                              ? screenWith * 0.3
                              : screenWith * 0.7,
                          child: TextFieldWithIcon(
                            controller: nameController,
                            labelText: 'Nombre Transportadora',
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: screenWith > 600
                              ? screenWith * 0.3
                              : screenWith * 0.7,
                          child: TextFieldWithIcon(
                            controller: phoneController,
                            labelText: 'Número de Teléfono',
                            icon: Icons.phone_in_talk,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9+]')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: screenWith > 600
                              ? screenWith * 0.3
                              : screenWith * 0.7,
                          child: TextFieldWithIcon(
                            controller: mailController,
                            labelText: 'Correo',
                            icon: Icons.mail,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: screenWith > 600
                              ? screenWith * 0.3
                              : screenWith * 0.7,
                          child: TextFieldWithIcon(
                            controller: addressController,
                            labelText: 'Direccion',
                            icon: Icons.location_on,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Cobertura:",
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Total: ${coveragesList.length.toString()}"),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: screenWith * 0.3,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Provincia',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.bold),
                          ),
                          items: provinciasToSelect
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item.split('-')[1],
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ))
                              .toList(),
                          value: selectedProvincia,
                          onChanged: (value) async {
                            setState(() {
                              selectedProvincia = value as String;

                              loadData();
                            });
                          },

                          //This to clear the search value when you close the menu
                          onMenuStateChange: (isOpen) {
                            if (!isOpen) {}
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // TextButton(
                    //   onPressed: () async {
                    //     //
                    //   },
                    //   child: const Text(
                    //     "Agregar Nueva Cobertura",
                    //     style: TextStyle(fontWeight: FontWeight.bold),
                    //   ),
                    // ),
                  ],
                ),
                Container(
                  height: screenHeight * 0.40,
                  width: screenWith * 0.55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  // child: DataTableModelPrincipal(
                  //   columnWidth: 200,
                  //   columns: getColumns(),
                  //   rows: buildDataRows(coveragesList),
                  // ),
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
                    headingTextStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    dataTextStyle: const TextStyle(color: Colors.black),
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 800,
                    columns: getColumns(),
                    rows: buildDataRows(coveragesList),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  List<DataColumn2> getColumns() {
    return [
      DataColumn2(
        label: Text('ID'),
        size: ColumnSize.S,
        fixedWidth: 80,
      ),
      DataColumn2(
        label: Text('Provincia'),
        size: ColumnSize.M,
        fixedWidth: 180,
      ),
      DataColumn2(
        label: Text('ID'),
        size: ColumnSize.S,
        fixedWidth: 80,
      ),
      DataColumn2(
        label: Text("Ciudad"),
        size: ColumnSize.S,
        fixedWidth: 180,
      ),
      DataColumn2(
        label: Text('Tipo'),
        size: ColumnSize.S,
        fixedWidth: 150,
      ),
    ];
  }

  List<DataRow> buildDataRows(List dataL) {
    dataL;

    List<DataRow> rows = [];
    for (int index = 0; index < dataL.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            Text(
              coveragesList != [] ? dataL[index]['id_prov_ref'].toString() : "",
            ),
          ),
          DataCell(
            Text(
              coveragesList != []
                  ? dataL[index]['coverage_external']['dpa_provincia']
                          ['provincia']
                      .toString()
                  : "",
            ),
          ),
          DataCell(
            Text(
              coveragesList != []
                  ? dataL[index]['id_ciudad_ref'].toString()
                  : "",
            ),
          ),
          DataCell(
            Text(
              coveragesList != []
                  ? dataL[index]['coverage_external']['ciudad'].toString()
                  : "",
            ),
          ),
          DataCell(
            Text(
              coveragesList != [] ? dataL[index]['type'].toString() : "",
            ),
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
  }
}
