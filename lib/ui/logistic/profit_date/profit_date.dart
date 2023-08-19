import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';

class ProfitDate extends StatefulWidget {
  const ProfitDate({super.key});

  @override
  State<ProfitDate> createState() => _ProfitDateState();
}

class _ProfitDateState extends State<ProfitDate> {
  bool loading = true;
  String monto = "";
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    setState(() {
      loading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = await Connections().getMyBalanceContable();
    setState(() {
      loading = false;
      monto = response['monto'].toString();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading == true
            ? Container()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Saldo Contable: ",
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    child: Card(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            "\$${double.parse(monto.toString()).toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
