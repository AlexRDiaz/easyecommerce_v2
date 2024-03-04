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
  const InfoCarrierExternal({super.key});

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

  List data = [];

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
        setState(() {
          provinciasToSelect.add('${provinciasList[i]}');
        });
      }

      var response = await Connections()
          .getCoverageByProvincia((selectedProvincia.toString().split("-")[0]));

      data = response['data'];
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
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: screenWith * 0.3,
                          child: TextFieldWithIcon(
                            controller: nameController,
                            labelText: 'Nombre Transportadora',
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: screenWith * 0.3,
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
                          width: screenWith * 0.3,
                          child: TextFieldWithIcon(
                            controller: mailController,
                            labelText: 'Correo',
                            icon: Icons.mail,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: screenWith * 0.3,
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
                  children: [
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
                    TextButton(
                      onPressed: () async {
                        //
                      },
                      child: const Text(
                        "Agregar Nueva Cobertura",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: screenHeight * 0.30,
                  width: screenWith * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: DataTableModelPrincipal(
                    columnWidth: 200,
                    columns: getColumns(),
                    rows: buildDataRows(data),
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
        label: Text('Provincia'),
        size: ColumnSize.M,
        fixedWidth: 250,
      ),
      DataColumn2(
        label: Text("Ciudad"),
        size: ColumnSize.S,
        fixedWidth: 250,
      ),
      DataColumn2(
        label: Text('Tipo'),
        size: ColumnSize.S,
        fixedWidth: 150,
      ),
      DataColumn2(
        label: Text(''),
        size: ColumnSize.S,
      ),
    ];
  }

  List<DataRow> buildDataRows(List dataL) {
    dataL = dataL;

    List<DataRow> rows = [];
    for (int index = 0; index < dataL.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            Text(
              dataL[index]['dpa_provincia']['provincia'].toString(),
            ),
          ),
          DataCell(
            InkWell(
              child: Text(
                dataL[index]['ciudad'].toString(),
              ),
            ),
          ),
          DataCell(
            Text(
              dataL[index]['cobertura_gintra'].toString(),
            ),
          ),
          DataCell(
            Text(""
                // dataL[index]['marca_tiempo_envio'].toString(),
                ),
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
  }
}
