import 'package:flutter/material.dart';

class AccountStatus2 extends StatefulWidget {
  const AccountStatus2({super.key});

  @override
  State<AccountStatus2> createState() => _AccountStatus2State();
}

class _AccountStatus2State extends State<AccountStatus2> {
  bool isMenuOpen = false;
  bool isSearchOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FullHeightContainer(),
      ),
    );
  }
}

class FullHeightContainer extends StatelessWidget {
  final List<String> menuItems = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4', // Puedes añadir más elementos a la lista de ejemplo
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.red, width: 2.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.5,
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2.0),
                ),
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(menuItems[index]));
                  },
                ),
              ),
              SizedBox(width: 10),
              Container(
                width: screenWidth * 0.15,
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2.0),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Icon(Icons.arrow_downward),
                ),
              ),
              SizedBox(width: 10),
              Container(
                width: screenWidth * 0.15,
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2.0),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Icon(Icons.search),
                ),
              ),
              SizedBox(width: 10),
              Container(
                width: screenWidth * 0.15,
                height: 50.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2.0),
                ),
                child: Center(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}