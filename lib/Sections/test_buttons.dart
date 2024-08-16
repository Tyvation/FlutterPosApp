import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../DataBase/database_helper.dart';
import '../Providers/main_provider.dart';
import 'dialog_helper.dart';

class TestButton extends StatefulWidget {
  const TestButton({super.key});

  @override
  State<TestButton> createState() => _TestButtonState();
}

class _TestButtonState extends State<TestButton> {
  @override
  Widget build(BuildContext context) {

    //final DatabaseHelper db = DatabaseHelper.instance;

    final mainProvider = Provider.of<MainProvider>(context, listen: false);
    final db = DatabaseHelper();

    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(4),
      physics: const BouncingScrollPhysics(),
      children: [
          testButton('Clear Listing',
            Icons.delete,
            (){ 
              mainProvider.clearAllListings();
            }
          ),
          testButton('Clear Items',
            Icons.delete,
            (){ 
              mainProvider.clearAllItems();
            }
          ),
          testButton('Refresh',
            Icons.replay_outlined,
            (){ 
              mainProvider.loadItems();
              mainProvider.loadListings();
            }
          ),
          testButton('test',
            Icons.tab,
            () async{ 
              List<Map<String, dynamic>> t = await db.queryAllItems();
              debugPrint('${t.last}');
            }
          ),
          testButton('delete db',
            Icons.delete,
            () async{ 
              await db.deleteDatabaseFile();
            }
          ),
          testButton('Checking',
            Icons.brightness_1_outlined,
            () async{
              await DialogHelper.checkingDialog(context);
            }
          ),
        ],
    );
  }
}

  Widget testButton(String testName, IconData icon, void Function() function){
    return FilledButton.icon(
      onPressed: function,
      iconAlignment: IconAlignment.start,
      label: Text(testName),
      icon: Icon(icon),
      style: const ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
        ),
        backgroundColor: WidgetStatePropertyAll(Colors.yellow),
      )
    );
  }
