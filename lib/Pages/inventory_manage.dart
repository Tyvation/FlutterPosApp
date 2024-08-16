import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_app/Models/items.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../Providers/main_provider.dart';

class InventoryManage extends StatefulWidget {
  const InventoryManage({super.key});

  @override
  State<InventoryManage> createState() => _InventoryManageState();
}

class _InventoryManageState extends State<InventoryManage> {
  final List<int> _listWidth = [3,2,2,2];
  final List<String> _listHeaders = ['Products', 'Price', 'Category', 'Stock'];
  final List<String> _listTypes = ['name', 'price', 'category', 'stock'];
  late PlatformFile file;
  late String defaultImagePath;

  void _pickFile(Function setstate) async{ 
    FilePickerResult? result = 
      await FilePicker.platform.pickFiles(
        type: FileType.image,
        dialogTitle: 'Pick a image for your stuff !',
      ); 
    if(result == null) return;
    setstate(() {
      file = result.files.single;
    });
  }

  Future createFolder() async{
    final docDir = await getApplicationDocumentsDirectory();
    if (await File('${docDir.path}/images').exists() == false){
      Directory('${docDir.path}/images').create();
    }
  }

  Future<File> saveImageFile(PlatformFile file, String newFileName) async{
    final type = file.name.split('.').last;
    final appStorage = await getApplicationDocumentsDirectory();
    final newFile = File('${appStorage.path}/images/$newFileName.$type');
    
    return File(file.path!).copy(newFile.path);
  }

  Future createDefaultImage(String assetPath, String fileName) async{
    final docDir = await getApplicationDocumentsDirectory();
    if(await File('${docDir.path}/images.$fileName').exists() == false){
      try{
        final byteData = await rootBundle.load(assetPath);
        final targetPath = path.join(docDir.path, 'images', fileName);
        final file = File(targetPath);
        await file.writeAsBytes(byteData.buffer.asUint8List());
        defaultImagePath = targetPath;
      }catch(e){
        throw Exception('Failed to copy asset image: $e');
      }
    }
  }

  @override void initState() {
    file = PlatformFile(name: '', size: 0);
    createFolder();
    createDefaultImage('lib/assets/images/istockphoto.png', 'istockphoto.png');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme myColorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8, right: 8, bottom: 8),
        child: Consumer<MainProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: myColorScheme.surface,
                      border: Border.all(color: myColorScheme.primary, width: 1.5),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: myColorScheme.surface,
                      border: Border.all(color: myColorScheme.primary, width: 1.5),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ' Products',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: myColorScheme.primary
                              ),  
                            ),
                            Row(
                              children: [
                                FilledButton(
                                  onPressed: (){
                                    _addItemDialog(context, provider);
                                  },
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    backgroundColor: myColorScheme.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ), 
                                  child: Text(
                                    'Add Item', 
                                    style: TextStyle(
                                      color: myColorScheme.onPrimary, 
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: (){}, 
                                  iconAlignment: IconAlignment.end,
                                  icon: const Icon(Icons.filter_alt_outlined),
                                  label: const Text('Filter'),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: myColorScheme.primary, width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  // this changes alot?
                                )
                              ],
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  //! Header
                                  Row(children: [
                                    for(var i in _listHeaders)
                                      Expanded(
                                        flex: _listWidth[_listHeaders.indexOf(i)], 
                                        child: Text(i, style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: myColorScheme.outline
                                        ))
                                      )
                                  ]),
                                  //! Products
                                  for(int i=0; i<provider.items.length; i++)
                                    Column(children: [
                                      const Divider(),
                                      Row(children: [
                                        for(int k=0; k<_listTypes.length; k++)
                                          Expanded(
                                            flex: _listWidth[k],
                                            child: Text('${provider.items[i][_listTypes[k]]}', overflow: TextOverflow.ellipsis,)
                                          )
                                      ]),
                                    ])
                                ]
                              ),
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      )
    );
  }

  void _addItemDialog(BuildContext context, MainProvider provider) {
    final formKey = GlobalKey<FormState>();
    TextEditingController categoryController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController barcodeController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    file = PlatformFile(name: '', size: 0);
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    
    List<String> dropDownCategories = [];
    for(var i in provider.items){
      if(!dropDownCategories.contains(i['category'])){
        dropDownCategories.add(i['category']);
      }
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: deviceWidth/4, vertical: deviceHeight/10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Row(
                        children: [
                          Text('New Proudct',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.start,),
                          Expanded(child:SizedBox())
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row( //! Image
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10),
                            color: Colors.grey,
                            dashPattern: const [10, 10],
                            strokeWidth: 2,
                            child: Container(
                              width: 100, height: 100,
                              decoration: file.name == ''
                              ? const BoxDecoration()
                              : BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  image: FileImage(File(file.path!))
                                )
                              ),
                              child: Material(
                                clipBehavior: Clip.antiAlias,
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent,
                                child: InkWell(
                                  hoverColor: Colors.red.withOpacity(.5),
                                  splashColor: Colors.orange.withOpacity(.7),
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: (){
                                    _pickFile(setState);
                                  },
                                  onHover: (value) {
                                    print('$value, ${file.name}');
                                  },
                                ),
                              ),
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 100),
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text('Press the Square to select your image.')
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(children: [ //! Name
                        const Expanded(child: Text('Product Name', overflow: TextOverflow.ellipsis)),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true
                            ),
                          ),
                        )
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [ //! Price
                        const Expanded(child: Text('Price', overflow: TextOverflow.ellipsis)),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: priceController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true
                            ),
                            validator: (value) {
                              if(value!.isEmpty){
                                return 'Price can\'t be empty.';
                              }else if(double.tryParse(value)==null){
                                return 'Please enter valid number.';
                              }else{
                                return null;
                              }
                            },
                          ),
                        )
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [ // !Barcode
                        const Expanded(child: Text('Barcode', overflow: TextOverflow.ellipsis)),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: barcodeController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true,
                            ),
                            validator: (value) {
                              if(value!.isNotEmpty && int.tryParse(value)==null){
                                return 'Please enter valid number.';
                              }else{
                                return null;
                              }
                            },
                          ),
                        )
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [ //! Category
                        const Expanded(child: Text('Category', overflow: TextOverflow.ellipsis)),
                        Expanded(
                          flex: 2,
                          child: DropdownMenu(
                            controller: categoryController,
                            width: 235,
                            label: const Text('Category'),
                            expandedInsets: const EdgeInsets.symmetric(horizontal: 0),
                            inputDecorationTheme: InputDecorationTheme(
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              constraints: BoxConstraints.tight(const Size.fromHeight(40))
                            ),
                            dropdownMenuEntries: <DropdownMenuEntry<String>>[
                              for(var i in dropDownCategories)
                                DropdownMenuEntry(value: i, label: i)
                            ],
                          ),
                        )
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [ //! Qunatity
                        const Expanded(child: Text('Quantity', overflow: TextOverflow.ellipsis)),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: quantityController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true,
                              hintText: '1',
                              suffixText: 'Stock'
                            ),
                          ),
                        )
                      ]),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ), 
                                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                FilledButton(
                                  onPressed: () async{
                                    if(formKey.currentState!.validate()){
                                      if(provider.items.where((x)=>x['name']==nameController.text).isNotEmpty){
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text('Product name exists in the inventory'),
                                          duration: Duration(seconds: 3),
                                        ));
                                      }else{
                                      File image;
                                      image = file.name == ''
                                        ? File(defaultImagePath)
                                        : await saveImageFile(file, nameController.text);
                                      provider.insertItem(
                                        Items(
                                          name: nameController.text,
                                          price: double.parse(priceController.text),
                                          stock: int.fromEnvironment(quantityController.text, defaultValue: 1),
                                          imagePath: image.path,
                                          category: categoryController.text,
                                          barCode: int.fromEnvironment(barcodeController.text, defaultValue: -1),
                                        )
                                      );
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }
}