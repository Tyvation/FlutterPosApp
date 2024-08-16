import 'dart:io';

import 'package:flutter/material.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'package:provider/provider.dart';
import '../Providers/main_provider.dart';

class EditItemOrderPage extends StatefulWidget {
  const EditItemOrderPage({super.key});

  @override
  State<EditItemOrderPage> createState() => _EditItemOrderPageState();
}

class _EditItemOrderPageState extends State<EditItemOrderPage> {
  @override
  Widget build(BuildContext context){
    final myColorScheme = Theme.of(context).colorScheme;
    List<Map<String, dynamic>> tempItems = [];
    return  Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top:8 ,bottom:8 ,right:8 ,left:0 ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: myColorScheme.surface,
                border: Border.all(color: myColorScheme.primary, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: Consumer<MainProvider>(
                builder: (context, itemProvider, child) {
                  tempItems = itemProvider.items.map((e){
                    Map<String, dynamic> ni = Map.from(e);
                    ni.remove('id');
                    return ni;
                  }).toList();
                  return itemProvider.items.isEmpty
                  ? const Center(child: Text('The List is EMPTY'))
                  : ReorderableGridView.extent(
                      maxCrossAxisExtent: 150, 
                      childAspectRatio: 1,
                      shrinkWrap: false,
                      onReorder: ((oldIndex, newIndex) async{
                        var item = tempItems.removeAt(oldIndex);
                        tempItems.insert(newIndex, item);
                        await itemProvider.reorderItems(tempItems);
                      }),
                      children: itemProvider.items.map((item) {
                        return _buildGridItem(item, myColorScheme);
                      }).toList(),
                    );
                }
              ),
            ),
          )
        ],
      );
  }

  Widget _buildGridItem(Map item, ColorScheme myColorScheme){
    return Padding(
      key: ValueKey(item['id']),
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: myColorScheme.primary, width: 2),
          image: DecorationImage(
            image: FileImage(File(item['imagePath'])),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Material(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children:[
              Container(
                height: 20, width: 500,
                color: myColorScheme.surface.withOpacity(.75),
                child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: FittedBox(
                        child: Text('${item['name']}', 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
