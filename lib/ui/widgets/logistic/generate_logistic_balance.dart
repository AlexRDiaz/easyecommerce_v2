import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';

class GenerateLogisticBalance extends StatefulWidget {
  const GenerateLogisticBalance({super.key});

  @override
  State<GenerateLogisticBalance> createState() =>
      _GenerateLogisticBalanceState();
}

class _GenerateLogisticBalanceState extends State<GenerateLogisticBalance> {
  String date = "";
  List<DateTime?> _dates = [];
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
                "A fin de evitar cualquier posible error, se recomienda realizar la selección de los días de manera secuencial.",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    color: Colors.redAccent)),
            SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: () async {
                  setState(() {});
                  var results = await showCalendarDatePicker2Dialog(
                    context: context,
                    config: CalendarDatePicker2WithActionButtonsConfig(
                      dayTextStyle: TextStyle(fontWeight: FontWeight.bold),
                      yearTextStyle: TextStyle(fontWeight: FontWeight.bold),
                      selectedYearTextStyle:
                          TextStyle(fontWeight: FontWeight.bold),
                      weekdayLabelTextStyle:
                          TextStyle(fontWeight: FontWeight.bold),
                    ),
                    dialogSize: const Size(325, 400),
                    value: _dates,
                    borderRadius: BorderRadius.circular(15),
                  );
                  setState(() {
                    if (results != null) {
                      String fechaOriginal = results![0]
                          .toString()
                          .split(" ")[0]
                          .split('-')
                          .reversed
                          .join('-')
                          .replaceAll("-", "/");
                      List<String> componentes = fechaOriginal.split('/');

                      String dia = int.parse(componentes[0]).toString();
                      String mes = int.parse(componentes[1]).toString();
                      String anio = componentes[2];

                      String nuevaFecha = "$dia/$mes/$anio";
                      setState(() {
                        date = nuevaFecha;
                      });
                    }
                  });
                },
                child: Text(
                  "SELECCIONAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            SizedBox(
              height: 10,
            ),
            Text(
              "FECHA: $date",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "CANCELAR",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: date.isEmpty
                        ? null
                        : () async {
                            getLoadingModal(context, false);
                            await Connections().generateLogisticBalance(date);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                    child: Text(
                      "GENERAR",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
