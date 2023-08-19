import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:frontend/ui/sellers/dashboard/filter_details.dart';

class _ChartData {
  _ChartData(this.category, this.value);

  final String category;
  double value;
}

class DynamicPieChart extends StatefulWidget {
  final List<FilterCheckModel> filters;

  const DynamicPieChart({required this.filters});

  @override
  _DynamicPieChartState createState() => _DynamicPieChartState();
}

class _DynamicPieChartState extends State<DynamicPieChart> {
  double totalValue = 0;
  List valuesDeleted = [];
  @override
  void initState() {
    super.initState();
    updateVisibleData();
    setState(() {});
  }

  void updateVisibleData() {
    double totalTemp = 0;
    for (var filter in widget.filters) {
      if (filter.numOfFiles != null) {
        totalTemp += int.parse(filter.numOfFiles!.toString());
      }
    }
    totalValue = totalTemp;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SfCircularChart(
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                widget: Container(
                  child: Text('Total : ' + _calculateTotal().toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
                ),
              )
            ],
            series: <CircularSeries>[
              PieSeries<FilterCheckModel, String>(
                dataSource: widget.filters,
                dataLabelMapper: (FilterCheckModel datum, _) {
                  double percentage =
                      (datum.numOfFiles!.toDouble() / _calculateTotal()) * 100;
                  String res = percentage > 0
                      ? percentage.toStringAsFixed(1) + "%"
                      : ' ';

                  return res;
                },
                xValueMapper: (FilterCheckModel datum, _) => datum.title,
                yValueMapper: (FilterCheckModel datum, _) => datum.numOfFiles,
                pointColorMapper: (FilterCheckModel data, _) => data.color,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.inside,
                ),
              ),
            ],
          ),
        ),
        _buildLegend(),
      ],
    );
  }

  _calculatePercentage(double numeroReg) {
    double porcentaje = (numeroReg / _calculateTotal()) * 100;
    return porcentaje;
  }

  _calculateTotal() {
    int total = 0;
    for (var filter in widget.filters) {
      total += filter.numOfFiles!.toInt();
    }
    return total;
  }

  Widget _buildLegend() {
    return Wrap(
      children: widget.filters.map((
        filter,
      ) {
        return InkWell(
          onTap: () {
            int index = widget.filters.indexOf(filter);
            Map valormap = valuesDeleted.firstWhere(
              (map) => map["index"] == index,
              orElse: () => {},
            );
            int valor = valormap.isNotEmpty ? valormap['valor'] : 0;
            setState(() {
              filter.numOfFiles = filter.numOfFiles == 0
                  ? valor
                  : saveValue(index, filter.numOfFiles);
              updateVisibleData();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: _getColor(filter),
                ),
                SizedBox(width: 4),
                Text(filter.title! + ":" + filter.numOfFiles.toString()),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getColor(FilterCheckModel filter) {
    if (filter.numOfFiles == 0) {
      return Colors.grey;
    } else {
      // int index = widget.filters.indexOf(filter) % Colors.primaries.length;
      return filter.color!;
    }
  }

  int saveValue(index, value) {
    valuesDeleted.add({"index": index, "valor": value});
    return 0;
  }
}
