import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DynamicStackedColumnChart extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;

  DynamicStackedColumnChart({required this.dataList});

  @override
  State<DynamicStackedColumnChart> createState() =>
      _DynamicStackedColumnChartState();
}

class _DynamicStackedColumnChartState extends State<DynamicStackedColumnChart> {
  @override
  Widget build(BuildContext context) {
    final seriesList =
        List<StackedColumnSeries<Map<String, dynamic>, String>>.generate(
      7, // Number of series to generate
      (index) {
        final yKey = 'y${index + 1}';
        final color = widget.dataList.isEmpty
            ? Colors.black
            : widget.dataList[0][yKey]['color'] as Color;
        final name =
            widget.dataList.isEmpty ? '' : widget.dataList[0][yKey]['title'];
        return StackedColumnSeries<Map<String, dynamic>, String>(
          dataSource: widget.dataList,
          xValueMapper: (Map<String, dynamic> data, _) => data['title'],
          yValueMapper: (Map<String, dynamic> data, _) => data[yKey]['value'],
          color: color, // Assign the color to the series

          name: name,
        );
      },
    );

    return Column(
      children: [
        Expanded(
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            series: seriesList,
            legend: Legend(
              isVisible: true,
              orientation: LegendItemOrientation.vertical,
            ),
            // annotations: <CartesianChartAnnotation>[
            //   CartesianChartAnnotation(
            //       widget: Container(child: const Text('Low')),
            //       coordinateUnit: CoordinateUnit.point,
            //       x: 15,
            //       y: 50),
            //   CartesianChartAnnotation(
            //       widget: Container(child: const Text('High')),
            //       coordinateUnit: CoordinateUnit.point,
            //       x: 35,
            //       y: 130,
            //       yAxisName: 'YAxis' // Refers to the additional axis
            //       )
            // ],
          ),
        ),
      ],
    );
  }
}
