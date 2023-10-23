import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/dashboard/dashboard.dart';
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
  String currentValueWallet = "";
  bool isLoading = false;
  List listSellers = [];
  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    List valueWalletTemp = [];

    // var response = await Connections()
    //     .getSellersFromSellers(_controllers.searchController.text);

    var response = await Connections().getVendedores();
    List<dynamic> vendedoresList = response['vendedores'];
    for (var vendedor in vendedoresList) {
      listSellers.add(vendedor);
    }

    setState(() {
      data = vendedoresList;
      //  valueWallet = valueWalletTemp;
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

  getValue(id) async {
    setState(() {
      isLoading = true;
    });
    var responseWalletValue = await Connections().getWalletValueById(id);
    setState(() {
      currentValueWallet = (double.parse(
                  responseWalletValue.toString() != "null"
                      ? responseWalletValue.toString()
                      : "0.0") *
              1.0)
          .toStringAsFixed(2);
    });

    setState(() {
      isLoading = false;
    });
  }

  int selectedItemIndex = -1; // Índice del elemento seleccionado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(data[index]),
                  onTap: () {
                    var m = data[index].toString().split("-")[1];
                    getValue(data[index].toString().split("-")[1]);
                    setState(() {
                      selectedItemIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: selectedItemIndex != -1
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        data[selectedItemIndex].toString().split("-")[0] ?? "",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      // TextButton(
                      //     onPressed: () async {
                      //       var _url = Uri(
                      //           scheme: 'tel',
                      //           path:
                      //               '+593${data[selectedItemIndex]['attributes']['Telefono1'].toString()}');

                      //       if (!await launchUrl(_url)) {
                      //         throw Exception('Could not launch $_url');
                      //       }
                      //     },
                      //     child: Icon(Icons.phone)),
                      !isLoading
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black),
                                  color: Color.fromARGB(255, 251, 240, 34)),
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "\$$currentValueWallet",
                                style: const TextStyle(
                                    fontSize: 30,
                                    color: Color.fromARGB(255, 63, 173, 225)),
                              ))
                          : const CustomCircularProgressIndicator(),
                    ],
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
