import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/ui/logistic/vendor_invoices/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/amount_row.dart';

import '../../../helpers/navigators.dart';
import '../../widgets/loading.dart';

class CCTransportInvoices extends StatefulWidget {
  const CCTransportInvoices({super.key});

  @override
  State<CCTransportInvoices> createState() => _TransportInvoicesState();
}

class _TransportInvoicesState extends State<CCTransportInvoices> {
  List data = [];

  loadData() async {
    var response = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    /*response = await Connections().getOrdersForPrintGuidesInSendGuides(
        _controllers.searchController.text, Get.parameters['date'].toString());

    data = response;*/

    data = [
      {'date': '28/09/2023', 'amount': '442,23', 'id': 0,},
      {'date': '28/09/2023', 'amount': '442,23', 'id': 1,},
      {'date': '28/09/2023', 'amount': '442,23', 'id': 2,},
      {'date': '28/09/2023', 'amount': '442,23', 'id': 3,},
    ];

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

  final VendorInvoicesControllers _controllers = VendorInvoicesControllers();
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
                  text: "Busqueda", controller: _controllers.searchController),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return _invoiceTile(
                    date: data[index]["date"],
                    amount: data[index]["amount"],
                    status: "entregado",
                    id: data[index]['id'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _invoiceTile({
    required String date,
    required String amount,
    required int id,
    String status = "",
  }) {
    return ListTile(
      onTap: () {
        Navigators().pushNamed(
          context,
          '/layout/logistic/cc-transport-invoices-by-date?id=$id',
        );
      },
      trailing: const Icon(
        Icons.arrow_forward_ios_sharp,
        size: 15,
      ),
      title: Row(
        children: [
          Text(
            "$date:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
