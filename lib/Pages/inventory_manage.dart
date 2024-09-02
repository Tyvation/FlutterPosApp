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
  final List<int> _listWidth = [3,2,2,2,2];
  final List<String> _listHeaders = ['Products', 'Price', 'Category', 'Stock', 'BarCode'];
  final List<String> _listTypes = ['name', 'price', 'category', 'stock', 'barCode'];
  final int _stockAlert = 1;
  late PlatformFile file;
  late String defaultImagePath;
  late bool openfilterWindow;

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
    openfilterWindow = false;
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
                    child: Row(
                      children: [
                        Expanded(flex:1, 
                          child: _inventoryDashBoard(
                            myColorScheme, 
                            provider.items.length, 
                            'Total Products',
                            Colors.blueAccent
                          )
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: _inventoryDashBoard(
                            myColorScheme, 
                            provider.items.map((e)=>e['category']).toSet().length, 
                            'Categories',
                            Colors.green
                          )
                        ),
                        const SizedBox(width: 8),
                        Expanded(flex:1, 
                          child: _inventoryDashBoard(
                            myColorScheme,
                            'idk', 
                            'Best Selling',
                            Colors.deepPurple[400]!
                          )
                        ),
                        const SizedBox(width: 8),
                        Expanded(flex:1, 
                          child: _inventoryDashBoard(
                            myColorScheme, 
                            provider.items.where((e)=>e['stock'] < _stockAlert).length,
                            'Low Stocks',
                            Colors.red[600]!
                          )
                        ),
                        const Expanded(flex:1, child: SizedBox()),
                      ],
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
                                FilledButton(//! Add Item Button
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
                                OutlinedButton.icon(//! Filter Button
                                  onPressed: (){
                                    setState(() {
                                      openfilterWindow = !openfilterWindow;
                                    });
                                  }, 
                                  iconAlignment: IconAlignment.end,
                                  icon: const Icon(Icons.filter_alt_outlined),
                                  label: const Text('Filter'),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: myColorScheme.primary, width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Padding(
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
                                          const Divider(height: 5),
                                          Material(
                                            child: InkWell(
                                              onTap: (){
                                                _itemEditor(context, myColorScheme, provider, i);
                                              },
                                              hoverColor: myColorScheme.secondary.withOpacity(.2),
                                              splashColor: myColorScheme.primary.withOpacity(.2),
                                              borderRadius: BorderRadius.circular(5),
                                              child: SizedBox(
                                                height: 30,
                                                child: Row(children: [
                                                  for(int k=0; k<_listTypes.length; k++)
                                                    Expanded(
                                                      flex: _listWidth[k],
                                                      child: Text(
                                                        '${provider.items[i][_listTypes[k]]}',
                                                        overflow: TextOverflow.ellipsis, 
                                                        style: TextStyle(
                                                          color: (_listTypes[k] == 'stock' && provider.items[i]['stock'] < _stockAlert) 
                                                            ? Colors.red[400] 
                                                            : myColorScheme.onSurface
                                                        ),
                                                      )
                                                    )
                                                ]),
                                              ),
                                            ),
                                          )
                                        ])
                                    ]
                                  ),
                                ),
                              ),
                              Positioned( //! Filter Window
                                  right: 0, top: 10,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    //TODO : animation
                                    child: openfilterWindow
                                    ? _filterWindow(myColorScheme)
                                    : const SizedBox()
                                  )
                                )
                            ],
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

  //! Filter
  Widget _filterWindow(ColorScheme myColorScheme){
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      constraints: BoxConstraints(
        maxHeight: 200, maxWidth: 200
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: myColorScheme.primary
      ),
    );
  }

  //! Adder
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
                              if(value!.isNotEmpty && !(int.tryParse(value)!=null && !(value.length<13 || value.length>14))){
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
                                          stock: quantityController.text.isNotEmpty && int.parse(quantityController.text)>0 ? int.parse(quantityController.text) : 1,
                                          imagePath: image.path,
                                          category: categoryController.text.isEmpty ? 'no category' : categoryController.text,
                                          barCode: barcodeController.text.isEmpty ? -1 : int.parse(barcodeController.text),
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

  //! Editor
  void _itemEditor(BuildContext context, ColorScheme myColorScheme, MainProvider provider, int index){
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    file = PlatformFile(name: '', size: 0);
    final formkey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController();
    TextEditingController barCodeController = TextEditingController();
    TextEditingController stockController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    List<dynamic> itemNames = [
      provider.items[index]['name'],
      provider.items[index]['barCode'], 
      provider.items[index]['price'],
      provider.items[index]['category'],
      provider.items[index]['stock'],
    ];
    Set existCategories = provider.items.map((e)=>e['category']).toList().toSet();
    int currentPage = 0;
    int previousPage = 0;
    bool editing = false;


    Widget buttons(int index, String label, Function setStateb){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start ,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: currentPage==index ? myColorScheme.primary : myColorScheme.surface,
              border: currentPage==index ? Border.all(color: Colors.transparent) : Border.all(color: myColorScheme.primary),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10), 
                topRight: const Radius.circular(10), 
                bottomLeft: (index==0 && currentPage!=0) ? const Radius.circular(10) : Radius.zero,
                bottomRight: (index==2 && currentPage!=2) ? const Radius.circular(10) : Radius.zero
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (){
                  setStateb(() {
                    previousPage = currentPage;
                    currentPage = index;
                  });
                },
                hoverColor: Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10), 
                  topRight: const Radius.circular(10),
                  bottomLeft: (index==0 && currentPage!=0) ? const Radius.circular(10) : Radius.zero,
                  bottomRight: (index==2 && currentPage!=2) ? const Radius.circular(10) : Radius.zero
                ), 
                child: SizedBox(
                  height: screenHeight/20, width: screenWidth/12,
                  child: Center(
                    child: Text(
                      label, 
                      style: TextStyle(
                        fontWeight: FontWeight.normal, 
                        color: currentPage==index ? myColorScheme.onPrimary : myColorScheme.primary
                      )
                    )
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget productInfo(String label, dynamic display, TextEditingController controller, int index){
      double displaySize = 16;
      return Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
        SizedBox(width: screenWidth/10),  
        Expanded(
          child: Container(
            alignment: Alignment.centerLeft,
            height: screenHeight/12,
            child: Text(label, style: TextStyle(color: myColorScheme.outline, fontWeight: FontWeight.normal))
          )
        ),
        Expanded(flex:2, 
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: editing==false
              ? Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text('$display', style: TextStyle(fontSize: displaySize)),
              )
              : label == 'Category'
                ? DropdownMenu(
                  controller: categoryController..text = '$display',
                  expandedInsets: const EdgeInsets.symmetric(horizontal: 0),
                  inputDecorationTheme: InputDecorationTheme(
                    isDense: true,
                    border: const OutlineInputBorder(),
                    constraints: BoxConstraints(maxHeight: 40, maxWidth: screenHeight/3)
                  ),
                  dropdownMenuEntries: <DropdownMenuEntry<String>>[
                    for(var i in existCategories)
                      DropdownMenuEntry( value: i, label: i)
                    ]
                  )
                : TextFormField(
                  controller: controller..text = '$display',
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    isDense: true,
                    constraints: BoxConstraints(maxWidth: screenHeight/3),
                    suffix: label == 'Price' ? Text('\$') : null
                  ),
                validator: (value) {
                  switch (label){
                    case 'Product':
                      final items = provider.items.map((e)=>e['name']).toList();
                      int namesInItems = items.where((e)=>e==value).length;
                      if(namesInItems>=1 && items.indexOf(value)!=index){
                        return 'Product name has been exist in inventory.';
                      }else{return null;}
                    case 'Price': 
                      if(value!.isEmpty){
                        return 'Price can\'t be empty.';
                      }else if(double.tryParse(value)==null){
                        return 'Please enter valid number.';
                      }else{return null;}
                    case 'BarCode':
                      if((value!.isNotEmpty && value!='-1') && !(int.tryParse(value)!=null && !(value.length<13 || value.length>14))){
                        return 'Please enter valid number.';
                      }else{return null;}
                    case 'Quantity':
                      if(value!.isNotEmpty && int.tryParse(value)==null){
                        return 'Please enter valid number without float number.';
                      }else if(int.parse(value)<0){
                        return 'Quantity can\'t be less than 0';
                      }else{return null;}
                    default:
                      return null;
                  }
                },
              )
            ),
          )
        )
      ]);
    }

    Widget detailPage(int key, Function setState){
      return Row(
        key: ValueKey(key),
        children: [
          Expanded(//! Info
            flex: 2,
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  productInfo('Product', itemNames[0], nameController, index),
                  productInfo('BarCode', itemNames[1], barCodeController, index),
                  productInfo('Price', itemNames[2], priceController, index),
                  productInfo('Category', itemNames[3], categoryController, index),
                  productInfo('Quantity', itemNames[4], stockController, index),
                ],
              ),
            ),
          ),
          Expanded(//! Image
            flex: 1,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    color: Colors.grey,
                    dashPattern: const [10, 10],
                    strokeWidth: 1.5,
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          image: FileImage(File(file.name == '' ? provider.items[index]['imagePath'] : file.path!))
                        )
                      ),
                      child: Material(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent,
                        child: editing
                        ? InkWell(
                          hoverColor: Colors.red.withOpacity(.5),
                          splashColor: Colors.orange.withOpacity(.7),
                          borderRadius: BorderRadius.circular(10),
                          onTap: (){
                            _pickFile(setState);
                          },
                        )
                        : const SizedBox()
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      );
    }

    Widget testPage1(int key){
      return Container(key:ValueKey(key), color: editing ? Colors.blue : Colors.green);
    }

    Widget testPage2(int key){
      return Container(key: ValueKey(key), color: Colors.red);
    }

    List<Widget> pages() => [detailPage(0, setState), testPage1(1), testPage2(2)];

    showDialog( //! Main Things
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog.fullscreen(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: myColorScheme.surface,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: myColorScheme.primary, width: 2)
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Row(children: [ //! NavigateButton
                        const SizedBox(width: 10),
                        buttons(0, 'Detail', setState),
                        const SizedBox(width: 2),
                        buttons(1, 'History', setState),
                        const SizedBox(width: 2),
                        buttons(2, 'IDK', setState)
                      ]),
                      Stack(
                        children:[
                          Divider(indent: 25, endIndent: 20, height: 0, thickness: 0.5, color: myColorScheme.primary),
                          AnimatedPadding(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.only(left: 10+(screenWidth/12+4)*currentPage),
                            curve: Curves.easeInOut,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 4, width: screenWidth/12+2,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(width: 2, color: Colors.blueAccent)
                                ),
                              ),
                            ),
                          ),
                        ]
                      ),
                      SizedBox(height: screenHeight/16),
                      Expanded( //! Main Contents
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            final double r = currentPage>previousPage ? -1 : 1;
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: animation.status == AnimationStatus.dismissed ? Offset(r,0) : Offset(-r,0), 
                                end: Offset.zero).animate(animation), 
                              child: child,
                            );
                          },
                          child: currentPage==0 ? detailPage(0, setState) : pages()[currentPage],
                        )
                      ),
                      Row( //! Buttons
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                border: !editing ? Border.all(color: Colors.transparent) : Border.all(color: myColorScheme.primary),
                                color: !editing ? myColorScheme.primary : Colors.transparent
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: (){ 
                                    Navigator.of(context).pop();
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  hoverColor: myColorScheme.onPrimary.withOpacity(.1),
                                  child: SizedBox(
                                    width: screenWidth/8,
                                    height: screenHeight/12,
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center ,children: [
                                      Icon(Icons.arrow_back_ios_new_rounded ,color: !editing ? myColorScheme.onPrimary : myColorScheme.primary),
                                      //const SizedBox(width: 8),
                                      Text(
                                        'Back', 
                                        style: TextStyle(
                                          fontSize: 16, 
                                          fontWeight: FontWeight.normal,
                                          color: !editing ? myColorScheme.onPrimary : myColorScheme.primary)
                                      )
                                    ]),
                                  ),
                                ),
                              ),
                            )
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                border: !editing ? Border.all(color: myColorScheme.primary) : Border.all(color: Colors.transparent),
                                color: !editing ? Colors.transparent : myColorScheme.primary
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async{ 
                                    if(editing){
                                      if(formkey.currentState!.validate()){
                                        File image;
                                        image = file.name == ''
                                          ? File(provider.items[index]['imagePath'])
                                          : await saveImageFile(file, nameController.text);
                                        provider.updateItems(
                                          provider.items[index]['id'],
                                          Items(
                                            id: index,
                                            name: nameController.text,
                                            price: double.parse(priceController.text),
                                            barCode: (barCodeController.text.isEmpty || int.parse(barCodeController.text)==-1) ? -1 : int.parse(barCodeController.text),
                                            stock: int.parse(stockController.text),
                                            imagePath: image.path,
                                            category: categoryController.text.isEmpty ? provider.items[index]['category'] : categoryController.text
                                          )
                                        );
                                        setState(() {
                                          itemNames[0] = nameController.text;
                                          itemNames[1] = barCodeController.text;
                                          itemNames[2] = priceController.text;
                                          itemNames[3] = categoryController.text;
                                          itemNames[4] = stockController.text;
                                          editing = !editing;
                                        });
                                      }
                                    }else{
                                      setState(() {
                                        editing = !editing;
                                      });
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  hoverColor: myColorScheme.onPrimary.withOpacity(.1),
                                  child: SizedBox(
                                    width: screenWidth/8,
                                    height: screenHeight/12,
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center ,children: [
                                      Icon(editing ? Icons.save : Icons.edit, color: !editing ? myColorScheme.primary : myColorScheme.onPrimary),
                                      Text(
                                        editing ? 'Save' : 'Edit', 
                                        style: TextStyle(
                                          fontSize: 16, 
                                          fontWeight: FontWeight.normal,
                                          color: !editing ? myColorScheme.primary : myColorScheme.onPrimary)
                                      )
                                    ]),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ]
                      )
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

  Widget _inventoryDashBoard(ColorScheme myColorScheme, dynamic numbers, String label, Color labelColor){
    return Container(
      decoration: BoxDecoration(
        color: myColorScheme.primary.withOpacity(.1),
        borderRadius: BorderRadius.circular(10)
      ),
      height: double.infinity,
      child: Stack(
      children: [
      Align(child: Text('$numbers',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),textAlign: TextAlign.end)),
      Positioned(
        left: 10, top: 8,
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: labelColor), overflow: TextOverflow.ellipsis)
        )
      ]
      )
    );
  }
}