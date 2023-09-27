import 'package:flutter/material.dart';
import 'package:frontend/ui/sellers/my_wallet/controllers/my_wallet_controller.dart';

class Transaction {
  final String title;
  final double amount;

  Transaction(this.title, this.amount);
}

class MyWallet extends StatefulWidget {
  @override
  _MyWalletState createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  MyWalletController walletController = MyWalletController();

  double saldo = 0;
  // Saldo inicial de cuenta
  List<Transaction> transactions = [
    Transaction('Compra 1', -50.0),
    Transaction('Compra 2', -75.0),
    Transaction('Depósito 1', 200.0),
  ];

  loadData() {
    saldo = walletController.getSaldo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billetera Virtual',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Billetera Virtual'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Saldo de Cuenta',
                style: TextStyle(fontSize: 24),
              ),
              Text(
                '\$${saldo.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Transacciones Recientes',
                style: TextStyle(fontSize: 24),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (ctx, index) {
                    final transaction = transactions[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(transaction.title),
                        trailing: Text(
                          '\$${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: transaction.amount < 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
