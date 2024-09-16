import 'package:flutter/material.dart';
import 'package:invoice_app/Models/listings.dart';
import 'package:provider/provider.dart';
import '../Providers/main_provider.dart';
import '../Components/dialog_helper.dart';
import '../Components/checkout_page.dart';

class PreviewListDisplay extends StatefulWidget {
  final FocusNode barFocusNode;
  final FocusNode KLfocusNode;

  const PreviewListDisplay({
    super.key, 
    required this.barFocusNode, 
    required this.KLfocusNode,
  });

  @override
  State<PreviewListDisplay> createState() => _PreviewListDisplayState();
}

class _PreviewListDisplayState extends State<PreviewListDisplay> {
  late double total;
  late double tax;
  late MainProvider itemProvider;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void initState() {
    total = 0;
    tax = 0.1;
    itemProvider = Provider.of<MainProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    final myColorScheme = Theme.of(context).colorScheme;

    return Consumer<MainProvider>(
      builder: (context, listingProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(top:8, left:0, bottom:8, right:8),
          child: Column(
            children: [
              Expanded( //! Preview List
                flex: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: myColorScheme.surface,
                    border: Border.all(color: myColorScheme.primary, width: 1.5),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),
                  child: Builder(
                    builder: (context){
                      var l = listingProvider.listings;
                      total=0;
                      for(int i=0; i<listingProvider.listings.length; i++){
                        total = total+l[i]['price']*l[i]['quantity'];
                      }
                      return listingProvider.listings.isEmpty
                      ? const Center(child: Text('No Listing Found'))
                      : Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ListView.builder(
                              itemCount: listingProvider.listings.length,
                              itemBuilder: (context, index) {
                                var listing = listingProvider.listings[index];
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Dismissible(
                                    key: UniqueKey(),
                                    direction: DismissDirection.endToStart,
                                    resizeDuration: const Duration(milliseconds: 200),
                                    onDismissed: (direction) {
                                      listingProvider.deleteListings(listing['id']);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('${listing['name']} dismissed'),
                                        duration: const Duration(milliseconds: 700),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                      ));
                                    },
                                    background: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Material(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.red,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.only(right: 15),
                                          child: const Icon(Icons.delete),
                                        )
                                      ),
                                    ),
                                    child: Card(
                                      child: ListTile(
                                        title: Text(listing['name']),
                                        trailing: Text('${listing['quantity']}'),
                                        leading: Text('${listing['price']}'),
                                        dense: true,
                                        onTap: () async {
                                          return await DialogHelper.productDialog(
                                            context,
                                            listingProvider.listings,
                                            index
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Material(
                                color: myColorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Sub Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('$total', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Tax', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('${(total*tax).roundToDouble()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const Divider(color: Colors.white,thickness: 2),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('${(total*(1+tax)).roundToDouble()}', style: const TextStyle(fontWeight: FontWeight.bold))
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Consumer<MainProvider>( //! Barcode Input
                builder: (context, provider, child) {
                  return Form(
                    key: _formKey,
                    child: TextFormField(
                      focusNode: widget.barFocusNode,
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        label: const Text('barcode'),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            if(_formKey.currentState!.validate()) {
                              _handleSumbit(provider, _barcodeController.text, context);
                              widget.KLfocusNode.requestFocus();
                              _barcodeController.clear();
                            }
                          },
                        ),
                      ),
                      validator: (value) {
                        if(value!.isEmpty){
                          return 'Input can\'t be empty';
                        }else if(int.tryParse(value) == null){
                          return 'Please enter valid barcode';
                        }else{
                          return null;
                        }
                      },
                      onFieldSubmitted: (value){
                        if(!_formKey.currentState!.validate()) return;
                              
                        _handleSumbit(provider, value, context);
                        widget.KLfocusNode.requestFocus();
                        _barcodeController.clear();
                      },
                      onTapOutside: (event) {
                        if(event.down){
                          FocusManager.instance.primaryFocus?.unfocus();
                          widget.KLfocusNode.requestFocus();
                        }
                      },
                    ),
                  );
                }
              ),
              const SizedBox(height: 10),
              SizedBox( //! Checkout Button
                width: double.infinity, height: 40,
                child: ElevatedButton(
                  onPressed: listingProvider.listings.isEmpty ? null : () {
                    CheckoutPage.checkoutPage(context, myColorScheme, listingProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: listingProvider.listings.isEmpty ? myColorScheme.surfaceContainerHighest : myColorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ), 
                  child: Text(
                    'Checkout(${listingProvider.listings.length})', 
                    style: TextStyle(
                      color: listingProvider.listings.isEmpty ? myColorScheme.onSurfaceVariant : myColorScheme.onPrimary
                    )
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _handleSumbit(MainProvider provider, String value, BuildContext context) {
    final ls = provider.items.map((e)=>e['barCode']).toList();
    final bls = provider.listings.map((e)=>e['name']).toList();
    final s;
    if(ls.contains(int.parse(value))){
      s = provider.items[ls.indexOf(int.parse(value))];
      if(!bls.contains(s['name'])){
        print('no');
        provider.insertListings(
          Listings(
            name: s['name'],
            price: s['price'],
            quantity: 1,
            comment: ''
          )
        );
      }else{
        print('yes');
        int tempQ = provider.listings[bls.indexOf(s['name'])]['quantity'];
        provider.updateListings(
          s['name'],
          Listings(
            name: s['name'], 
            price: s['price'], 
            quantity: tempQ+1
          )
        );
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('no items found.'),
        duration: Duration(milliseconds: 1000),
      ));
    }
  }
}
