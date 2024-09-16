import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/main_provider.dart';

class CheckoutPage{
  static Future checkoutPage(BuildContext context, ColorScheme myColorScheme, MainProvider provider) async{

    Widget listingCard(listing){
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: myColorScheme.surfaceContainerHighest,
        ),
        child: Column(
          children: [
            Text('${listing['name']}'),
            Text('${listing['price']}'),
          ],
        ),
      );
    }
    
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Container(
            color: myColorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded( //! Listing Cards
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: myColorScheme.surface,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: myColorScheme.primary),
                            ),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(10),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                    for(var listing in provider.listings)
                                      listingCard(listing)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded( //! Total Price
                          flex: 1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: myColorScheme.surface,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: myColorScheme.primary),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded( //! Payment
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: myColorScheme.primary),
                      ),
                      child: Column(
                        children: [
                          Text('Checkout'),
                        ],
                      ),
                    )
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}