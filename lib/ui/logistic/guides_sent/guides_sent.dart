import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/ui/logistic/guides_sent/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';

class GuidesSent extends StatefulWidget {
  const GuidesSent({super.key});

  @override
  State<GuidesSent> createState() => _GuidesSentState();
}

class _GuidesSentState extends State<GuidesSent> {
  GuidesSentControllers _controllers = GuidesSentControllers();
  List data = [];
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    var response = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    response = await Connections().getOrdersDateAll();

    data = response;

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "FECHAS REGISTRADAS:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Divider(),
              Expanded(
                  child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                            onTap: () {
                              Navigators().pushNamed(context,
                                  '/layout/logistic/logistic-date/table?date=${data[index]['attributes']['Fecha']}');
                            },
                            trailing: const Icon(
                              Icons.arrow_forward_ios_sharp,
                              size: 15,
                            ),
                            title: Text(
                              "${data[index]['attributes']['Fecha']}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ));
                      })),
            ],
          ),
        ),
      ),
    );
  }
}
