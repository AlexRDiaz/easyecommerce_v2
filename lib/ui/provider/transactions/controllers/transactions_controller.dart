import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/provider_transactions_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class TransactionsController extends ControllerMVC {
  List<ProviderTransactionsModel> transactions = [];

  Future<Map<String, dynamic>> loadTransactionsByProvider(startDate, endDate,
      populate, pageSize, currentPage, or, and, sort, search) async {
    try {
      var response = await Connections().getTransactionsByProvider(startDate,
          endDate, populate, pageSize, currentPage, or, and, sort, search);
      if (response == 1) {
        print('Error: Status Code 1');
      } else if (response == 2) {
        print('Error: Status Code 2');
      } else {
        List<dynamic> jsonData = response['data'];

        var total = response['total'];
        var lastPage = response['last_page'];

        transactions = jsonData
            .map((data) => ProviderTransactionsModel.fromJson(data))
            .toList();
        setState(() {});
        // Construir el objeto de respuesta
        Map<String, dynamic> result = {
          'data':
              transactions.map((transaction) => transaction.toJson()).toList(),
          'total': total,
          'last_page': lastPage,
        };
        return result;
      }
    } catch (e) {
      // Maneja otros errores
      print('Error al cargar transactions: $e');
    }
    return {
      'data': [],
      'total': 0,
      'last_page': 0,
    };
  }
}
