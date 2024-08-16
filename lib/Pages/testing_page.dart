import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_app/Providers/main_provider.dart';
import 'package:provider/provider.dart';

class TestingPage extends StatefulWidget {

  const TestingPage({super.key});

  @override
  State<TestingPage> createState() => _TestingPageState();
}

class _TestingPageState extends State<TestingPage> {
  late Map<String, dynamic> product;
  late FocusNode _focusNode;
  late FocusNode _KLfocusNode;
  final _barcodeController = TextEditingController();
  TextEditingController _itemBarcodeCon = TextEditingController();
  TextEditingController _itemNameCon = TextEditingController();
  String tempText = '';
  List<Map<dynamic, String>> testItemList = [];
  List<Map<dynamic, String>> testBuyList = [];
  @override
  void initState() {
    _focusNode = FocusNode();
    _KLfocusNode = FocusNode();
    super.initState();
  }


  @override
  void dispose(){
    _focusNode.dispose();
    _KLfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        autofocus: true,
        focusNode: _KLfocusNode,
        onKeyEvent: (value) {
          if(value is KeyDownEvent){
            _focusNode.requestFocus();
          }
        },
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for(var i in testItemList)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            Expanded(child: Text('${i['name']}')),
                            Expanded(child: Text('   ${i['barcode']}',textAlign: TextAlign.end),)
                          ],)
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 100),
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (value) {
                        List t = testItemList.map((e)=>e['barcode']).toList();
                        List bt = testBuyList.map((e)=>e['name']).toList();
                        String? s;
                        if(t.contains(value)){
                          s = testItemList[t.indexOf(value)]['name'];
                          if(!bt.contains(s)){
                            testBuyList.add({
                              'name' : s!,
                              'count' : '1'
                            });
                          }else{
                            int k = int.parse(testBuyList[bt.indexOf(s)]['count']!);
                            testBuyList[bt.indexOf(s)]['count'] = (k+1).toString();
                          }
                        }else{
                          s = 'Can\'t find item';
                        }
                        setState(() {
                          tempText = s!;
                        });
                        _KLfocusNode.requestFocus();
                        _barcodeController.clear();
                      },
                      onTapOutside: (event) {
                        if(event.down){
                          FocusManager.instance.primaryFocus?.unfocus();
                          _KLfocusNode.requestFocus();
                        }
                      },
                      
                    ),
                  ),
                  Text(
                    tempText == ''
                    ? 'No Barcode'
                    : tempText
                  ),
                  ElevatedButton(
                    onPressed: (){
                      _barcodeController.clear();
                      testItemList.clear();
                    },
                    child: const Text('reset')
                  ),
                  ElevatedButton(
                    onPressed: ()async{
                      showDialog(
                        context: context, 
                        builder: (context) {
                          return Dialog(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _itemNameCon,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    label: Text('Name'),
                                  ),
                                ),
                                TextField(
                                  controller: _itemBarcodeCon,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    label: Text('BarCode'),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: (){
                                        setState(() {
                                          testItemList.add({
                                          'name' : _itemNameCon.text,
                                          'barcode' : _itemBarcodeCon.text
                                          });
                                        });
                                        _itemNameCon.clear();
                                        _itemBarcodeCon.clear();
                                        Navigator.of(context).pop();
                                      }, 
                                      child: Text('Add')
                                    ),
                                    ElevatedButton(
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                      }, 
                                      child: Text('Cancel')
                                    )
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      );
                    }, 
                    child: const Text('Edit')
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const SizedBox(height: 200),
                  for(var i in testBuyList)
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${i['name']}'),
                      Text('${i['count']}', textAlign: TextAlign.end),
                    ])
                ]
              ),
            ),
            const SizedBox(width: 100,)
          ],
        ),
      ),
    );
  }
}