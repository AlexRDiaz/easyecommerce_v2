import 'dart:convert';

import 'package:frontend/helpers/server.dart';
import 'package:http/http.dart' as http;

class ReportServiceConnections {
  String reportservice = reportService;

  getOrdersbyStatus(page, pageSize, filters) async {
    try {
      // Aseguramos que filters sea un mapa (objeto JSON) en lugar de una lista
      Map<String, dynamic> requestBody = {
        "filters": filters, // Debe ser un mapa {}
        "page": page,
        "page_size": pageSize,
      };

      var request = await http.post(
        Uri.parse("$reportservice/pedidos"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody), // Convertimos correctamente a JSON
      );

      var response = request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return decodeData;
      }
    } catch (e) {
      print(e);
    }
  }

  getOrdersStats(page, pageSize, filters) async {
    try {
      // Aseguramos que filters sea un mapa (objeto JSON) en lugar de una lista
      Map<String, dynamic> requestBody = {
        "filters": filters, // Debe ser un mapa {}
        "page": page,
        "page_size": pageSize,
      };

      var request = await http.post(
        Uri.parse("$reportservice/pedido-stats"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody), // Convertimos correctamente a JSON
      );

      var response = request.body;
      var decodeData = json.decode(response);

      if (request.statusCode != 200) {
        return false;
      } else {
        return decodeData;
      }
    } catch (e) {
      print(e);
    }
  }

  getSellingProducts(start, end) async {
    try {
      var request =
          await http.post(Uri.parse("$reportservice/top-selling-products"),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                "start_date": start,
                "end_date": end,
              }));

      var response = await request.body;
      var decodeData = json.decode(response);
      if (request.statusCode != 200) {
        return false;
      } else {
        return decodeData;
      }
    } catch (e) {
      print(e);
    }
  }
}
