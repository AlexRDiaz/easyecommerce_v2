import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Chart extends StatefulWidget {
  final List sections;
  final int total;
  const Chart({Key? key, required this.sections, required this.total})
      : super(key: key);

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          PieChart(
            PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                startDegreeOffset: -90,
                sections: generateChartData(),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                )),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16.0),
                Text(
                  "Total",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: const Color.fromARGB(255, 10, 10, 10),
                        fontWeight: FontWeight.w600,
                        height: 0.5,
                      ),
                ),
                Text("${widget.total} registros")
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

    if (widget.total == 0) {
      chartData.add(
        PieChartSectionData(
          color: Colors.amber,
          showTitle: false,
          value: 1.0,
          radius: 30,
        ),
      );
    } else {
      for (var sec in widget.sections) {
        const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

        double percentage = sec['value'] / widget.total;

        PieChartSectionData section = PieChartSectionData(
          color: sec['color'],
          value: sec['value'],
          title: '${(percentage * 100).toStringAsFixed(1)}%',
          radius: 30,
          showTitle: true,
          titleStyle: percentage * 100 < 5
              ? TextStyle(
                  fontSize: 10, color: const Color.fromARGB(255, 12, 2, 2))
              : TextStyle(
                  fontSize: 10,
                  color: const Color.fromARGB(255, 253, 252, 252)),
          titlePositionPercentageOffset: porcentajeOff(percentage * 100),
        );
        chartData.add(section);
      }
    }
    return chartData;
  }
}

porcentajeOff(double percentaje) {
  double val = 0.5;
  if (percentaje < 1) {
    val = 2.0;
  }
  if (percentaje >= 1 && percentaje < 2) {
    val = 1.8;
  }
  if (percentaje >= 2 && percentaje < 3) {
    val = 1.6;
  }
  if (percentaje >= 3 && percentaje < 5) {
    val = 1.4;
  }
  return val;
}
