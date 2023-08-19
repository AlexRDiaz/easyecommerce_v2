import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/connections/connections.dart';

import 'package:table_calendar/table_calendar.dart';

class CalendarModal extends StatefulWidget {
  final String id;
  const CalendarModal({super.key, required this.id});

  @override
  State<CalendarModal> createState() => _CalendarModalState();
}

class _CalendarModalState extends State<CalendarModal> {


 late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Container(),
          centerTitle: true,
          title: const Text(
            "Fecha confirmación",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          ),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(80.0),
          child: SingleChildScrollView(
            child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      TableCalendar(
                        
                        firstDay: DateTime(2017, 9, 7, 17, 30),
                        lastDay: DateTime(2037, 9, 7, 17, 30),
                        focusedDay: DateTime.now(),
                        selectedDayPredicate: (day) {
                          // Aquí puedes personalizar el aspecto del día seleccionado
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) async {
                          setState(() {
                            _selectedDay = selectedDay;
                          });
                          var fecha=selectedDay.day.toString()+"/"+selectedDay.month.toString()+"/"+selectedDay.year.toString();
                          print("fecha="+fecha);
                       

                          var m =
                          await Connections().updateOrderFechaEntrega(widget.id, fecha);   
                                Navigator.pop(context);
                
                        },
                        calendarStyle: CalendarStyle(
                            // Personaliza el aspecto del calendario según tus necesidades
                            ),
                        headerStyle: HeaderStyle(
                            // Personaliza el estilo del encabezado del calendario según tus necesidades
                            ),
                      ),
                    ],
                  ),
          ),
        )));
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                "$text: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: (value) {
                    setState(() {});
                  },
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: text,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusColor: Colors.black,
                    iconColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
