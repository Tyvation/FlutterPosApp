import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../Providers/main_provider.dart';
import '../Models/items.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late PlatformFile file;
  late String defaultImagePath;

  void _pickFile() async{ 
    FilePickerResult? result = 
      await FilePicker.platform.pickFiles(
        type: FileType.image,
        dialogTitle: 'Pick a image for your stuff !',
      ); 
    if(result == null) return;
    setState(() {
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
 
  @override
  void initState() {
    file = PlatformFile(name: '', size: 0);
    createFolder();
    createDefaultImage('lib/assets/images/istockphoto.png', 'istockphoto.png');
    super.initState();
  }

  @override
  void dispose() {
    
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MainProvider mainProvider = Provider.of<MainProvider>(context, listen: false);
    ColorScheme myColorScheme = Theme.of(context).colorScheme;
    List<String> dropDownCategories = [];
    for(var i in mainProvider.items){
      if(!dropDownCategories.contains(i['category'])){
        dropDownCategories.add(i['category']);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: myColorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 12,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  file.name == '' 
                  ? const Text('no image') 
                  : Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.center,
                        image: FileImage(File(file.path!))
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [myColorScheme.surface, Colors.transparent, ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,                  
                      )
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 15,
              child: Container(
                color: myColorScheme.surface,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(flex: 1, child: Stack(
                            children: [
                              DropdownMenu(
                                controller: _categoryController,
                                width: 235,
                                label: const Text('Category'),
                                expandedInsets: const EdgeInsets.symmetric(horizontal: 0),
                                inputDecorationTheme: InputDecorationTheme(
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                                  constraints: BoxConstraints.tight(const Size.fromHeight(40))
                                ),
                                dropdownMenuEntries: <DropdownMenuEntry<String>>[
                                  for(var i in dropDownCategories)
                                    DropdownMenuEntry(value: i, label: i)
                                ],
                              ),
                            ]
                          )),
                          const SizedBox(width: 10),
                          Expanded(flex: 3, child:TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter the item name';
                              }
                              return null;
                            },
                          )),
                          const SizedBox(width: 10),
                          Expanded(flex:1, child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter the item price';
                              } else if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),)
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        maxLines: 5,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () { _pickFile(); }, 
                            child: const Text('Image'),
                          ),
                          ElevatedButton(
                            onPressed: () async{
                              if (_formKey.currentState!.validate()){
                                if(mainProvider.items.where((x)=>x['name']==_nameController.text).isNotEmpty){
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('item is already in stock'),
                                    duration: Duration(milliseconds: 1000),
                                  ));
                                }
                                else{
                                File imagePath;
                                file.name == ''
                                ? imagePath = File(defaultImagePath)
                                : imagePath = await saveImageFile(file, _nameController.text);
                                mainProvider.insertItem(
                                  Items(
                                    name: _nameController.text,
                                    price: double.parse(_priceController.text),
                                    stock: int.fromEnvironment(_stockController.text, defaultValue: 1),
                                    description: _descriptionController.text,
                                    imagePath: imagePath.path,
                                    category: _categoryController.text,
                                  )
                                );
                                Navigator.pop(context);
                              }}
                            },
                            child: const Text('Add Item'),
                          ),
                        ]
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
