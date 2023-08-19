import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/income_and_expenses/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountStatus extends StatefulWidget {
  const AccountStatus({super.key});

  @override
  State<AccountStatus> createState() => _AccountStatusState();
}

class _AccountStatusState extends State<AccountStatus> {
  /// todo: implementar formulario
  final IncomeAndExpensesControllers _controllers =
      IncomeAndExpensesControllers();
  List optionsCheckBox = [];
  int counterChecks = 0;
  List data = [];
  List valueWallet = [];
  bool sort = false;

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    List valueWalletTemp = [];

    var response = await Connections()
        .getSellersFromSellers(_controllers.searchController.text);
    for (var i = 0; i < response.length; i++) {
      var responseWalletValue = await Connections().getWalletValueById(
          response.isNotEmpty ? response[i]['attributes']['Id_Master'] : "");
      valueWalletTemp.add((double.parse(responseWalletValue.toString()!="null"?responseWalletValue.toString() :"0.0") * 1.0)
          .toStringAsFixed(2));
    }

    setState(() {
      data = response;
      valueWallet = valueWalletTemp;
    });

    // print(data);
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _modelTextField(
                  text: "Búsqueda", controller: _controllers.searchController),
            ),
            Expanded(
              child: DataTable2(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                dataTextStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                columnSpacing: 12,
                horizontalMargin: 6,
                minWidth: 1000,
                showCheckboxColumn: false,
                columns: [
                  DataColumn2(
                    label: Text('Nombre Comercial'),
                    size: ColumnSize.S,
                    fixedWidth: 200,
                  ),
                  DataColumn2(
                    label: Text(''),
                    size: ColumnSize.S,
                    fixedWidth: 60,
                  ),
                  DataColumn2(
                    label: Text('Saldo'),
                    size: ColumnSize.S,
                    fixedWidth: 90,
                  ),
                  DataColumn2(
                    label: Text('Tu Saldo'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text(''),
                    size: ColumnSize.S,
                    fixedWidth: 30,
                  ),
                ],
                rows: List<DataRow>.generate(
                  data.length,
                  (index) => DataRow(
                    cells: [
                      DataCell(
                          Text(data[index]['attributes']['Nombre_Comercial']
                              .toString()), onTap: () {
                        Navigators().pushNamed(context,
                            '/layout/logistic/status-account/details?idComercial=${data[index]['attributes']['Id_Master']}');
                      }),
                      DataCell(Icon(Icons.phone), onTap: () async {
                        var _url = Uri(
                            scheme: 'tel',
                            path:
                                '+593${data[index]['attributes']['Telefono1'].toString()}');

                        if (!await launchUrl(_url)) {
                          throw Exception('Could not launch $_url');
                        }
                      }),
                      DataCell(
                        Text('\$${valueWallet[index].toString()}'),
                      ),
                      DataCell(
                        Text(
                            'Tu saldo actual es de \$${valueWallet[index].toString()}'),
                      ),
                      DataCell(
                        const Icon(
                          Icons.arrow_forward_ios_sharp,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ),
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
        color: const Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) async {
          await loadData();
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controllers.searchController.clear();
                    });
                  },
                  child: const Icon(Icons.close),
                )
              : null,
          hintText: text,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color.fromRGBO(237, 241, 245, 1.0),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color.fromRGBO(237, 241, 245, 1.0),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  sortFunc(name) {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes'][name]
          .toString()
          .compareTo(a['attributes'][name].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes'][name]
          .toString()
          .compareTo(b['attributes'][name].toString()));
    }
  }
}
