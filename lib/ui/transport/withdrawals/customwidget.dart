import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/ui/transport/withdrawals/table_orders_guides_sent.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final String warehouseName;

  const CalendarWidget({Key? key, required this.warehouseName})
      : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _selectedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Historial Retiros ${widget.warehouseName}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Cierra el diálogo al presionar el botón de cerrar
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    56, // Altura del AppBar
              ),
              child: TableCalendar(
                locale: 'es',
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: DateTime.now(),
                calendarFormat: _calendarFormat,
                rangeSelectionMode: _rangeSelectionMode,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                ),
                onDaySelected: (date, focusedDay) {
                  // Formatear la fecha a "d/M/yyyy"
                  String formattedDate = DateFormat('d/M/yyyy').format(date);

                  print('Fecha seleccionada: $formattedDate');
                  setState(() {
                    _selectedDate = date;
                  });
                  _mostrarVentanaEmergenteGuiasEnviadas(context,formattedDate);
                },
                onPageChanged: (focusedDay) {
                  // Handle page change
                },
                calendarBuilders: CalendarBuilders(
                  selectedBuilder: (context, date, focusedDay) {
                    return buildCell(date, focusedDay, Colors.blue);
                  },
                  todayBuilder: (context, date, focusedDay) {
                    return buildCell(
                        date, focusedDay, ColorsSystem().colorSelectMenu);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCell(DateTime date, DateTime focusedDay, Color color) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _mostrarVentanaEmergenteGuiasEnviadas(BuildContext context,String dateSend) {
    double width =
        MediaQuery.of(context).size.width * 0.8; // 80% del ancho de la pantalla
    double height =
        MediaQuery.of(context).size.height * 0.8; // 60% del alto de la pantalla

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: width,
            height: height,
            child: TableOrdersGuidesSentTransport(dateSend: dateSend),
          ),
        );
      },
    );
  }
}
