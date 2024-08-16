import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:invoice_app/Models/items.dart';
import 'package:invoice_app/Sections/test_buttons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../Providers/main_provider.dart';

class DialogHelper{
  static Future productDialog(BuildContext context, List lists , int index) async{
    return showDialog(
      context:  context,
      builder: (context){
        var list = lists[index];
        return Dialog(
          insetPadding: const EdgeInsets.all(100),
          child: SizedBox(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${list['name']}', style: const TextStyle(fontSize: 30)),
                  Text('Price : ${list['price']}'),
                  Text('Description : ${list['description']}'),
                  Text('Quantity : ${list['quantity']}'),
                  Text('ID : ${list['id']}'),
                  Text('Stock : ${list['stock']}'),
                ],
              )
            ),
          ),
        );
      }
    );
  }
  static Future productEditDialog(BuildContext context, Map item, MainProvider provider) async{
    ColorScheme myColorScheme = Theme.of(context).colorScheme;
    final _formKey = GlobalKey<FormState>();
    TextEditingController _nameEditController = TextEditingController();
    TextEditingController _barcodeEditController = TextEditingController();
    TextEditingController _categoryEditController = TextEditingController();
    TextEditingController _priceEditController = TextEditingController();
    TextEditingController _avaliableEditController = TextEditingController();

    List<String> existCategories = [];
    for(var i in provider.items){
      if(!existCategories.contains(i['category'])){
        existCategories.add(i['category']);
      }
    }
    Future<int> getWid(File image, String w) async{
      var k = await decodeImageFromList(image.readAsBytesSync());
      if(w == 'w'){return k.width;}
      else {return k.height;}
    }
    int imageW = await getWid(File(item['imagePath']), 'w');
    int imageH = await getWid(File(item['imagePath']), 'h');
    PlatformFile file = PlatformFile(name: '', size: 0);

    Future pickFile() async{ 
      FilePickerResult? result = 
        await FilePicker.platform.pickFiles(
          type: FileType.image,
          dialogTitle: 'Pick a image for your stuff !',
        ); 
      if(result == null) return;
      file = result.files.single;
    }

    Future<File> saveImageFile(PlatformFile file, String newFileName) async{
      final type = file.name.split('.').last;
      final appStorage = await getApplicationDocumentsDirectory();
      final newFile = File('${appStorage.path}/images/$newFileName.$type');
      
      return File(file.path!).copy(newFile.path);
    }

    return showDialog(
      context:  context,
      builder: (context){
        return Dialog(
          insetPadding: const EdgeInsets.all(100),
          child: Consumer<MainProvider>(
            builder: (context, provider, child) {
              
              return SizedBox(
                child: Center(
                  child: Column(
                    children: [
                      Expanded(flex: 2,
                        child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            Expanded(flex: 2,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.red),
                                      color: Colors.grey[900],
                                      image: DecorationImage(
                                        fit: imageW < imageH
                                          ? BoxFit.fitHeight
                                          : BoxFit.fitWidth,
                                        alignment: Alignment.center,
                                        image: FileImage(File(item['imagePath'])),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async{
                                      await pickFile();
                                      print('Picked File : "${file.path}');
                                      if(file.path != null){
                                        provider.updateItems(
                                          item['id'], 
                                          Items(
                                            id: item['id'],
                                            name: item['name'],
                                            price: item['price'],
                                            imagePath: file.path,
                                          )
                                        );
                                        provider.loadItems();
                                        await saveImageFile(file, item['name']);
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.3)),
                                      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                                    ), 
                                    child: const Text('Image'),
                                  )
                                ]
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(flex: 3,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      controller: _barcodeEditController..text = item['barCode'].toString(),
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        labelText: 'BarCode',
                                        alignLabelWithHint: true,
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _nameEditController..text = item['name'],
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        labelText: 'Name',
                                        alignLabelWithHint: true,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded( flex: 1,
                                          child: TextFormField(
                                            controller: _priceEditController..text = item['price'].toString(),
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                              labelText: 'Price',
                                              alignLabelWithHint: true,
                                              suffixText: '\$',
                                            ),
                                            validator: (value){
                                              if(value!.isEmpty){
                                                return 'Please enter the price';
                                              }else if(double.tryParse(value)==null){
                                                return 'Please enter only numbers';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded( flex: 2,
                                          child: DropdownMenu(
                                            controller: _categoryEditController..text=item['category'],
                                            expandedInsets: const EdgeInsets.symmetric(horizontal: 0),
                                            label: const Text('Category'),
                                            inputDecorationTheme: InputDecorationTheme(
                                              isDense: true,
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                              constraints: BoxConstraints.tight(const Size.fromHeight(40))
                                            ),
                                            dropdownMenuEntries: <DropdownMenuEntry<String>>[
                                              for(var i in existCategories)
                                                DropdownMenuEntry(
                                                  value: i, 
                                                  label: i
                                                )
                                            ]
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(children: [
                                      const Text('Avaliable : '),
                                      Text('${item['stock']}', 
                                        style: TextStyle(
                                          color: item['stock']>5
                                            ? Colors.white
                                            : Colors.red
                                        )
                                      )
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      Expanded(flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                              style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(myColorScheme.surfaceContainer)),
                              onPressed: ()async{
                                if(_formKey.currentState!.validate()){
                                  print('Changed Name: ${_nameEditController.text}, Price: ${_priceEditController.text}, Category: ${_categoryEditController.text}');
                                  showDialog(
                                    context: context, 
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('You sure to edit like this?'),
                                        content: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start ,
                                          children: [
                                            const Text('This will override you data like this : '),
                                            Text('Name : ${item['name']}'),
                                            Text('Price : ${item['price']}'),
                                            Text('Category : ${item['category']}'),
                                            Text('Avaliable : ${item['stock']}'),
                                          ]
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: (){
                                              provider.updateItems(
                                                item['id'], 
                                                Items(
                                                  id: item['id'],
                                                  name: _nameEditController.text,
                                                  barCode: int.parse(_barcodeEditController.text),
                                                  price: double.parse(_priceEditController.text),
                                                  category: _categoryEditController.text,
                                                  description: item['description'],
                                                  imagePath: item['imagePath'],
                                                  stock: item['stock']
                                                )
                                              );
                                              Navigator.of(context).pop();
                                            }, 
                                            child: const Text('Confirm')
                                          ),
                                          TextButton(
                                            onPressed: (){
                                              Navigator.of(context).pop();
                                            }, 
                                            child: const Text('Cancel'))
                                        ],
                                      );
                                    },
                                  );
                                }
                              }, 
                              child: const Text('Test')
                            ),
                            const SizedBox(width: 50)
                          ],
                        )
                      ),
                      const SizedBox(height: 30)
                    ],
                  )
                ),
              );
            },
          ),
        );
      }
    );
  }

  static Future checkingDialog(BuildContext context) async{
    return showDialog(
      context: context, 
      builder: (context){
        return Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.all(100),
          child: Column(
            children: [
              Container(
                height: 50,
                color: Colors.green,
              ),
            ],
          ),
        );
      }
    );
  }
  
}