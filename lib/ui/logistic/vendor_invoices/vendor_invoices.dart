import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/vendor_invoices/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/amount_row.dart';

import '../../../helpers/navigators.dart';
import '../../widgets/loading.dart';

class VendorInvoices extends StatefulWidget {
  const VendorInvoices({super.key});

  @override
  State<VendorInvoices> createState() => _VendorInvoicesState();
}

class _VendorInvoicesState extends State<VendorInvoices> {
  List data = [];
  bool loading = true;
  List valueWallet = [];
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    var response = await Connections()
        .getSellersFromSellers(_controllers.searchController.text);
    setState(() {
      data = response;
    });
    for (var i = 0; i < response.length; i++) {
      var responseWalletValue = await Connections().getWalletValueByIdVF(
          response.isNotEmpty ? response[i]['attributes']['Id_Master'] : "");
      setState(() {
        data[i]['amount'] = responseWalletValue.toString();
      });
    }

    // print(data);
    setState(() {
      loading = false;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
  }

  // loadData() async {
  //   var response = [];
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     getLoadingModal(context, false);
  //   });

  //   /*response = await Connections().getOrdersForPrintGuidesInSendGuides(
  //       _controllers.searchController.text, Get.parameters['date'].toString());

  //   data = response;*/

  //   data = [
  //     {
  //       'name': 'El rinconcito Ecuatoriano',
  //       'amount': '442,23',
  //       'id': 0,
  //     },
  //     {
  //       'name': 'Sangatoy Store',
  //       'amount': '442,23',
  //       'id': 1,
  //     },
  //     {
  //       'name': 'Marialex',
  //       'amount': '442,23',
  //       'id': 2,
  //     },
  //     {
  //       'name': 'ANTOOJItos',
  //       'amount': '442,23',
  //       'id': 3,
  //     },
  //   ];

  //   Future.delayed(const Duration(milliseconds: 500), () {
  //     Navigator.pop(context);
  //   });
  //   setState(() {});
  // }

  final VendorInvoicesControllers _controllers = VendorInvoicesControllers();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: loading == false
                  ? ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _invoiceTile(
                          name: data[index]["attributes"]['Nombre_Comercial']
                              .toString(),
                          amount:
                              (double.parse(data[index]["amount"].toString()) *
                                      1.0)
                                  .toStringAsFixed(2),
                          id: data[index]["attributes"]['Id_Master'].toString(),
                        );
                      },
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  _invoiceTile({
    required String name,
    required String amount,
    required String id,
  }) {
    return ListTile(
      onTap: () {
        Navigators().pushNamed(
          context,
          '/layout/logistic/vendor-invoices-by-vendor?id=$id',
        );
      },
      trailing: const Icon(
        Icons.arrow_forward_ios_sharp,
        size: 15,
      ),
      title: Row(
        children: [
          Text(
            "$name:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          AmountRow(amount: amount),
        ],
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
