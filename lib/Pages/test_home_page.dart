import 'package:flutter/material.dart';
import 'main_page.dart';
import 'testing_page.dart';

class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final myColorSheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: myColorSheme.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Builder(
                builder: (context){
                  double maxHeight = MediaQuery.of(context).size.height;
                  double fabSize = maxHeight * 0.3;
                  return Row(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            width: fabSize, height: fabSize,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (context) => const MainPage()),
                                );
                              },
                              child: Icon(Icons.shopping_basket, size: fabSize*0.6),
                            )
                          ),
                          const Text('POS System', style: TextStyle(fontWeight: FontWeight.w600))
                        ],
                      ),
                      SizedBox(width: fabSize),
                      Column(
                        children: [
                          SizedBox(
                            width: fabSize, height: fabSize,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)
                                )
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => TestingPage()),
                                );
                              },
                              child: Icon(Icons.receipt, size: fabSize*0.6),
                            )
                          ),
                          const Text('Receipt System', style: TextStyle(fontWeight: FontWeight.w600))
                        ],
                      ),
                    ],
                  );
                }
              ),
            ],
          ),
        ],
      ),
    );
  }
}
