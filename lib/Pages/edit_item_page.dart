import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Sections/dialog_helper.dart';
import '../Pages/add_item_page.dart';
import '../Providers/main_provider.dart';

class EditItemPage extends StatefulWidget {
  const EditItemPage({super.key});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late ColorScheme myColorScheme;
  int _currentIndex = 0;
  late String _selectedCate;
  final ScrollController _scrollController = ScrollController();
  static const List<int> listRowFlex = [1,2,5,5,3,3];

  @override
  void initState() {
    _selectedCate = 'All';
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    myColorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top:8, right:8, bottom:8, left:0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: myColorScheme.surface,
                border: Border.all(color: myColorScheme.primary, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: Consumer<MainProvider>(
                  builder:(context, provider, child) {
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
                                          _currentIndex = index;
                                          _selectedCate = categories[index];
                                          print(_selectedCate);
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
              ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 25,
            child:Stack(
                children: [
                  Container(
                    height: 1000, width: 1000,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: myColorScheme.surface,
                      border: Border.all(color: myColorScheme.primary, width: 1.5),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Consumer<MainProvider>(
                      builder: (context, itemProvider, child){ 
                        List<String> listText = ['ID','BarCode','Name','Price','Category','Stock'];
                        List fillteredItems = [];
                        fillteredItems = _selectedCate == 'All'
                        ? itemProvider.items
                        : itemProvider.items.where((x) => x['category']==_selectedCate).toList();
                        return fillteredItems.isEmpty
                        ? const Center(child: Text('The List is EMPTY'),)
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              border: TableBorder.all(
                                style: BorderStyle.none,
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))
                              ),
                              clipBehavior: Clip.antiAlias,
                              headingRowColor: const WidgetStatePropertyAll(Colors.green),
                              headingRowHeight: 40,
                              headingTextStyle: const TextStyle(fontWeight: FontWeight.w600),
                              columnSpacing: 0,
                              columns: [
                                for(var i in listText)
                                  DataColumn(label: Text(i)),
                                const DataColumn(label: Text('Actions'))
                              ], 
                              rows: [
                                for(var item in fillteredItems)
                                  DataRow(
                                    //selected: fillteredItems.indexOf(i)==2 ? true : false,
                                    cells: [
                                    for(var j=0; j<listText.length; j++)
                                      DataCell(
                                        ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 80),
                                        child: Text('${item[listText[j] == 'BarCode'? 'barCode': listText[j].toLowerCase()]}', overflow: TextOverflow.ellipsis,)
                                      )),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: (){
                                              DialogHelper.productEditDialog(context, item, itemProvider);
                                            }
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                                            onPressed: ()async{
                                              showDialog(
                                                context: context, 
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text('Delete'),
                                                    content: const Text('Are you sure to delete this?'),
                                                    actions: [
                                                      ElevatedButton(
                                                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(myColorScheme.onPrimary)),
                                                        onPressed: (){
                                                          itemProvider.deleteItem(item['id']);
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: const Text('Confirm'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: (){
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: const Text('Cancel'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                    )
                                  ])
                              ]
                            ),
                        );
                      }
                    ),
                  ),
                  Positioned(
                    right: 10, bottom: 10,
                    child: FloatingActionButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const AddItemPage()));
                      },
                      shape: const CircleBorder(side: BorderSide.none),
                      mini: true,
                      child: const Icon(Icons.add),
                    )
                  ),
                ],
              ),
          ),
        ]
      ),
    );
  }
}
