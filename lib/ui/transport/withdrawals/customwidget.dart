import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'package:intl/intl.dart';
// import 'package:frontend/ui/transport/withdrawals/table_orders_guides_sent.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final String idWarehouse;

  const CalendarWidget(
      {Key? key, required this.onDateSelected, required this.idWarehouse})
      : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  bool _isLoading = false;
  late int _selectedYear;
  late String _selectedMonth;
  String _selectedDay =
      '1'; // Asignar un valor predeterminado válido para _selectedDay
  List<int> _years = [];
  List<String> _months = [];
  List<String> _days = [];

  List<Map<String, dynamic>> respValues = [];

  @override
  void initState() {
    super.initState();
    // Inicializa los años y los meses.
    _years = List.generate(11, (index) => DateTime.now().year - index);
    _months = List.generate(
        12, (index) => DateFormat('MMMM', 'es').format(DateTime(0, index + 1)));

    _selectedYear = _years.first;
    _selectedMonth = DateFormat('MMMM', 'es').format(DateTime.now());

    // Obtén el número del mes a partir del nombre del mes seleccionado.
    int monthNumber = _months.indexOf(_selectedMonth) + 1;
    _updateDays(_selectedYear, monthNumber);

    // Llama a loadData con el número del mes y el año.
  }

  loadData(String monthYear) async {
    setState(() {
      _isLoading = true; // Inicia la carga
    });

    var respvlaues =
        await Connections().getValuesDropdownOp(monthYear, widget.idWarehouse);
    // print(respvlaues);

    if (mounted) {
      setState(() {
        respValues = respvlaues;
        _updateDays(_selectedYear, _months.indexOf(_selectedMonth) + 1);
        _isLoading = false; // Finaliza la carga
      });
    }
  }

  void _updateDays(int year, int month) {
    int dayCount = DateUtils.getDaysInMonth(year, month);
    _days = List<String>.generate(dayCount, (index) {
      int dayNumber = dayCount - index;
      String fecha = "$dayNumber/$month/$year";

      // Buscar la cantidad correspondiente en respValues
      var foundItem = respValues.firstWhere(
        (item) => item['fecha'] == fecha,
        orElse: () => {'cantidad': 0},
      );

      return '$dayNumber (${foundItem['cantidad']})';
    });

    // Establece el último día del mes como día seleccionado.
    _selectedDay = _days.first.split(' ')[0];

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // ... tu UI anterior ...
          Text("Año", style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<int>(
            value: _selectedYear,
            items: _years.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedYear = newValue;
                  _updateDays(
                      _selectedYear, _months.indexOf(_selectedMonth) + 1);
                });
              }
            },
          ),
          Text("Mes", style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _selectedMonth,
            items: _months.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedMonth = newValue;
                });

                // Obtén el número del mes a partir del nombre del mes seleccionado y actualiza los días.
                int monthNumber = _months.indexOf(newValue) + 1;
                String formattedMonthYear = "$monthNumber/${_selectedYear}";

                // Llama a loadData con el nuevo mes y año.
                loadData(formattedMonthYear);
              }
            },
          ),
          Text("Día", style: TextStyle(fontWeight: FontWeight.bold)),
          _isLoading
              ? Text('Cargando...')
              : DropdownButton<String>(
                  value: _selectedDay,
                  items: _days.map<DropdownMenuItem<String>>((String value) {
                    String dayNumber = value.split(' ')[0];
                    String count = value.split(' ')[1];

                    return DropdownMenuItem<String>(
                      value: dayNumber,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.black,
                          ), // Estilo predeterminado
                          children: <TextSpan>[
                            TextSpan(text: "$dayNumber "), // Texto normal
                            TextSpan(
                              text: count, // Texto entre paréntesis
                              style: TextStyle(
                                  color: ColorsSystem()
                                      .colorSelectMenu), // Estilo azul para el conteo
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedDay = newValue;
                      });
                      int day = int.parse(newValue);
                      int month = _months.indexOf(_selectedMonth) + 1;
                      widget
                          .onDateSelected(DateTime(_selectedYear, month, day));
                    }
                  },
                ),

          // ... más de tu UI si es necesario ...
        ],
      ),
    );
  }
}
