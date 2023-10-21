import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';

class ChartDynamicCron extends StatefulWidget {
  final List<dynamic> sections;
  ChartDynamicCron({Key? key, required this.sections}) : super(key: key);

  @override
  State<ChartDynamicCron> createState() => _ChartDynamicCronState();
}

class _ChartDynamicCronState extends State<ChartDynamicCron> {
  int touchedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.sections == null || widget.sections.isEmpty) {
      // return Container(child: Text("No hay data para mostrar."));
    }
    return Expanded(
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
              sections: generateChartData(),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16.0),
                Text(
                  "Efectividad",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: ColorsSystem().colorBlack,
                        fontWeight: FontWeight.w600,
                        height: 0.5,
                      ),
                ),
                Text("De Entregas"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> generateChartData() {
    // for (var point in lista) {
    //   total += int.parse(point["value"]);
    // }

    int startDegree = -90;
    List<PieChartSectionData> chartData = [];

    // if (widget.sections[]['counter'] == 0) {
    //   chartData.add(
    //     PieChartSectionData(
    //       color: Colors.amber,
    //       showTitle: false,
    //       value: 1.0,
    //       radius: 30,
    //     ),
    //   );
    // }
    // else {
    for (var sec in widget.sections) {
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      double percentage =
          (sec['counter'] != 0) ? sec['value'] / sec['counter'] : 0;

      // print(percentage*100);
      PieChartSectionData section = PieChartSectionData(
        color: sec['color'],
        value: sec['value'],
        title: '${(percentage * 100).toStringAsFixed(1)}%',
        radius: 30,
        showTitle: true,
        titleStyle: percentage * 100 < 5
            ? const TextStyle(
                fontSize: 10, color: Color.fromARGB(255, 12, 2, 2))
            : const TextStyle(
                fontSize: 20, color: Color.fromARGB(255, 253, 252, 252)),
        // titlePositionPercentageOffset: porcentajeOff(percentage * 100),
      );
      chartData.add(section);
    }
    // }
    return chartData;
  }
}

// porcentajeOff(double percentaje) {
//   double val = 0.5;
//   if (percentaje < 1) {
//     val = 2.0;
//   }
//   if (percentaje >= 1 && percentaje < 2) {
//     val = 1.8;
//   }
//   if (percentaje >= 2 && percentaje < 3) {
//     val = 1.6;
//   }
//   if (percentaje >= 3 && percentaje < 5) {
//     val = 1.4;
//   }
//   return val;
// }
