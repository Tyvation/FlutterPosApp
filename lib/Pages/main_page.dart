import 'package:flutter/material.dart';
import '../Pages/pos_page.dart';
import '../Sections/main_navigate_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Widget currentPageWidget = const PosPage();

  void _getReturnWidget(Widget page, int index){
    if(index==0){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
      return;
    }
    setState(() {
      currentPageWidget = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex:1, 
            child: MainNavigateBar(
              onWidgetReturned: _getReturnWidget
            ),
          ),
          Expanded(
            flex:12, 
            child: 
            Column(
              children: [
                Expanded(flex:8,child: currentPageWidget),
              ],
            )),
          
        ],
      ),
    );
  }
}
