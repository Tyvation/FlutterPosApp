import 'package:flutter/material.dart';
import 'package:invoice_app/Pages/history_page.dart';
import 'package:provider/provider.dart';
import '../Providers/theme_provider.dart';
import '../Pages/dash_board_page.dart';
import '../Pages/inventory_manage.dart';
import '../Pages/edit_item_order_page.dart';
import '../Pages/pos_page.dart';
import '../Pages/test_home_page.dart';
import '../Pages/edit_item_page.dart';

class MainNavigateBar extends StatefulWidget {
  final Function(Widget, int) onWidgetReturned;
  const MainNavigateBar({
    super.key, 
    required this.onWidgetReturned,
  });

  @override
  State<MainNavigateBar> createState() => _MainNavigateBarState();
}

class _MainNavigateBarState extends State<MainNavigateBar> {
  int _currentIndex=1;
  List<String> pageName = ['Home', 'Pos', 'Edit', 'Reorder','Inventory\nManage', 'Dash\nBoard', 'Histories'];
  List<IconData> pageIcon = [
    Icons.home, 
    Icons.point_of_sale, 
    Icons.edit, 
    Icons.view_list_rounded, 
    Icons.inventory_outlined,
    Icons.bar_chart_outlined,
    Icons.timelapse_outlined,
  ];
  List<Widget> pageWidget = const [
    TestHomePage(), 
    PosPage() ,
    EditItemPage(), 
    EditItemOrderPage(), 
    InventoryManage(),
    DashBoardPage(),
    HistoryPage(),
  ];
  late ColorScheme myColorScheme;

  @override
  Widget build(BuildContext context) {
    myColorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: pageName.length,
            itemBuilder: (context, index) {
              return _buttonWithText(
                pageName[index], 
                pageIcon[index], 
                index,
              );
            },
          ),
        ),
        Switch(
          value: themeProvider.isDarkMode, 
          onChanged: (value) {
            themeProvider.toggleTheme();
          }
        ),
        const SizedBox(height: 5)
      ],
    );
  }

  Widget _buttonWithText(String buttonName, IconData icon, int index){
    return Padding(
      padding: const EdgeInsets.only(top:8, left:8, right:8, bottom:2),
      child: AspectRatio(
        aspectRatio: 5/4,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _currentIndex == index
              ? myColorScheme.primary
              : myColorScheme.secondaryContainer,
          ),
          child: Material(
            color: index!=0
              ? Colors.transparent
              : Colors.orange,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentIndex = index;
                  widget.onWidgetReturned(pageWidget[index], index);
                });
              },
              hoverColor: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        child: Icon(icon,
                          color: _currentIndex==index
                            ? myColorScheme.onSecondary
                            : myColorScheme.inverseSurface,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FittedBox(
                        clipBehavior: Clip.antiAlias,
                        child: Text(buttonName, 
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _currentIndex==index
                              ? myColorScheme.onSecondary
                              : myColorScheme.inverseSurface,
                              overflow: TextOverflow.fade
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}