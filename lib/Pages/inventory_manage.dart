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

  void _itemEditor(BuildContext context, ColorScheme myColorScheme, MainProvider provider, int index){
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    file = PlatformFile(name: '', size: 0);
    int currentPage = 0;
    late List<Widget> pages = [];
    late List<Offset> pageOffsets = [];
    Offset toffset = Offset(0,0);

    Widget productInfo(String label, dynamic display){
      return Row(children: [
        SizedBox(width: screenHeight/16),
        Expanded(child: SizedBox(child: Text(label, style: TextStyle(color: myColorScheme.outline, fontWeight: FontWeight.bold)))),
        Expanded(flex:2, child: Text('$display'))
      ]);
    }

    Widget buttons(int index, String label, Function setStateb){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start ,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: currentPage==index ? myColorScheme.primary : myColorScheme.secondary,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (){
                  setStateb(() {
                    currentPage = index;
                    toffset = Offset(1, 0);
                  });
                },
                hoverColor: Colors.white.withOpacity(.2),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)), 
                child: SizedBox(
                  height: screenHeight/20, width: screenWidth/12,
                  child: Center(
                    child: Text(
                      label, 
                      style: TextStyle(
                        fontWeight: FontWeight.normal, 
                        color: currentPage==index ? myColorScheme.onPrimary : myColorScheme.onSecondary
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

    Widget detailPage(){
      return Row(
        children: [
          Expanded(//! Info
            flex: 2,
            child: Column(
              children: [
                productInfo('Proudct', provider.items[index]['name']),
                SizedBox(height: screenHeight/24),
                productInfo('BarCode', provider.items[index]['barCode']),
                SizedBox(height: screenHeight/24),
                productInfo('Quantity', provider.items[index]['stock']),
                SizedBox(height: screenHeight/24),
                productInfo('Category', provider.items[index]['category']),
              ],
            ),
          ),
          Expanded(//! Image
            flex: 1,
            child: Column(
              children: [
                Align(
                  alignment: const Alignment(0,0),
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
                        child: InkWell(
                          hoverColor: Colors.red.withOpacity(.5),
                          splashColor: Colors.orange.withOpacity(.7),
                          borderRadius: BorderRadius.circular(10),
                          onTap: (){
                            _pickFile(setState);
                          },
                        ),
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

    Widget testPage(){
      return Container(color: Colors.blue);
    }
    pages = [detailPage(), testPage()];
    pageOffsets = [Offset(0, 0), Offset(.1, 0)];
    showDialog(
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
                        buttons(1, 'History', setState)
                      ]),
                      
                      Stack(
                        children:[
                          const Divider(indent: 10, endIndent: 10, height: 1, thickness: 1.5),
                          AnimatedPadding(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.only(left: 10+(screenWidth/12+2)*currentPage),
                            curve: Curves.easeInOut,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                height: 4, width: screenWidth/12,
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
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 300),
                          offset: toffset,
                          onEnd: (){
                            setState(() {
                              toffset = Offset(0,0);
                            });
                          },
                          child: pages[currentPage],
                        )
                      ),
                      Row( //! Buttons
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: screenWidth/8,
                              height: screenHeight/12,
                              child: FilledButton.icon(
                                onPressed: (){ Navigator.of(context).pop(); }, 
                                label: const Text('Back', style: TextStyle( fontSize: 16)),
                                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.only(left:5, right:10),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: SizedBox(
                                width: screenWidth/8,
                                height: screenHeight/12,
                                child: OutlinedButton.icon(
                                  onPressed: (){}, 
                                  label: const Text('Edit', style: TextStyle( fontSize: 16)),
                                  icon: const Icon(Icons.edit),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.only(left:5, right:10),
                                  ),
                                ),
                              ),
                            )
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