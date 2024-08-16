import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:invoice_app/Sections/dialog_helper.dart';
import 'package:provider/provider.dart';
import '../Models/listings.dart';
import '../Providers/main_provider.dart';

class ItemListDisplay extends StatefulWidget {
  const ItemListDisplay({super.key});

  @override
  State<ItemListDisplay> createState() => _ItemListDisplayState();
}

class _ItemListDisplayState extends State<ItemListDisplay> {
  int _currentIndex = 0;
  String _selectedCate='';
  late List filteredItems;
  late List searchedItems;
  int providerFirstBoot = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState(){
    _selectedCate = 'All';
    final pro = Provider.of<MainProvider>(context, listen: false);
    providerFirstBoot += pro.items.isEmpty ? 0 : 1;
    filteredItems = pro.items;
    searchedItems = filteredItems;
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context){
    final myColorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top:8, right:8, bottom:8, left:0),
      child: Row(
        children: [
          //! Categories
          Expanded (flex: 1, child: Container(
            decoration: BoxDecoration(
              color: myColorScheme.surface,
              border: Border.all(color: myColorScheme.primary, width: 1.5),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: Consumer<MainProvider>(
                builder:(context, provider, child) {
                  if(providerFirstBoot==0){
                    filteredItems = provider.items;
                    searchedItems = filteredItems;
                  }
                  List categories=['All'];
                  if(categories.length==1){
                    provider.items.where((x)=>x.containsKey('category'))
                    .forEach((x) {if(!categories.contains(x['category']) && x['category']!=null){categories.add(x['category']);}});
                  }
                  return Listener(
                    onPointerSignal: (event) {
                      if(event is PointerScrollEvent){
                        final newOffset = (event.scrollDelta.dy/2);
                        _scrollController.position.moveTo(_scrollController.offset + newOffset, clamp: false);
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ListView.builder(
                        itemExtent: 50,
                        itemCount: categories.length,
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.fast),
                        controller: _scrollController,
                        itemBuilder:(context, index) {
                          return AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                color: _currentIndex==index
                                  ? myColorScheme.onPrimaryContainer
                                  : myColorScheme.surfaceContainer,
                              ),
                              child: Material(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.transparent,
                                child: InkWell(
                                    splashColor: Colors.blueAccent.withOpacity(.5),
                                    hoverColor: myColorScheme.primary.withOpacity(.2),
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: (){
                                      setState(() {
                                        if(providerFirstBoot==0){providerFirstBoot++;}
                                        _currentIndex = index;
                                        _selectedCate = categories[index];
                                        filteredItems  = _selectedCate == 'All'
                                          ? searchedItems
                                          : searchedItems.where((x)=>
                                            x['category']==_selectedCate).toList();
                                      });
                                    },
                                    child: Center(
                                      child: Text(
                                        '${categories[index]}',
                                        style: TextStyle(
                                          color: _currentIndex==index
                                            ? myColorScheme.onPrimary
                                            : myColorScheme.onSurface,
                                          fontWeight: FontWeight.bold
                                        ),
                                      )
                                    ),
                                  ),
                                ),
                            );
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          ),
          const SizedBox(width: 8),
          Expanded (flex:8, child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: myColorScheme.surface,
              border: Border.all(color: myColorScheme.primary, width: 1.5),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: Column(
              children: [
                //! Search Bar
                Expanded(
                  child: Consumer<MainProvider>(
                    builder: (context, provider, child)=>
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 4, left: 4),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: myColorScheme.primary,
                              width: 1.5
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: myColorScheme.inversePrimary,
                              width: 1.5
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search',
                          isDense: true,
                        ),
                        onChanged: (value) {
                          List result = [];
                          if (value.isEmpty){
                            result = provider.items;
                          }
                          else{
                            result = provider.items.where((x)=>
                              x['name'].toString().toLowerCase().contains(value.toLowerCase())).toList();
                          }
                          setState(() {
                            searchedItems = result;
                            filteredItems = _selectedCate == 'All'
                            ? searchedItems
                            : searchedItems.where((x)=>
                              x['category']==_selectedCate).toList();
                          });
                        },
                      ),
                    ),
                  )
                ),
                //! items
                Expanded(
                  flex: 10,
                  child: Consumer<MainProvider>(
                    builder: (context, itemProvider, child){
                      return filteredItems.isEmpty
                      ? const Center(child: Text('The List is EMPTY'),)
                      : GridView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1),
                          shrinkWrap: false,
                          itemCount: filteredItems.length,
                          itemBuilder:(context, index) {
                            return _buildGridItem(filteredItems[index], filteredItems, itemProvider, myColorScheme);
                          },
                        );
                    }),
                ),
              ],
            )
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGridItem(Map item, List items, MainProvider provider, ColorScheme myColorScheme){

    return Padding(
      key: ValueKey(item['name']),
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
            child: InkWell(
              onTap: (){
                final t = provider.listings.where((x)=>x['name']==item['name']).toList();
                if (t.isEmpty) {
                  provider.insertListings(
                    Listings(
                      name: item['name'],
                      price: item['price'],
                      quantity: 1,
                      comment: ''
                    )
                  );
                }else{
                  int tempQ = t[0]['quantity'];
                  provider.updateListings(
                    t[0]['name'],
                    Listings(
                      name: item['name'],
                      price: item['price'],
                      quantity: tempQ+1,
                      comment: ''
                    )
                  );
                }
              },
              onLongPress: () async{
                await DialogHelper.productDialog(context, provider.items, item['id']-1);
                print('${item['id']}');
              },
              borderRadius: BorderRadius.circular(15),
              splashColor: Colors.blueAccent.withOpacity(0.7),
              enableFeedback: true,
              hoverColor: Colors.white.withOpacity(0.3),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children:[
                  Container(
                    height: 20, 
                    width: 500,
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
      ),
    );
  }
}
