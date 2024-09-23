import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/main_provider.dart';

class CheckoutPage{
  static Future checkoutPage(BuildContext context, ColorScheme myColorScheme, MainProvider provider) async{

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    Widget listingCard(listing){
      String imagePath = provider.items.firstWhere((item) => item['name'] == listing['name'])['imagePath'];
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: myColorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            imagePath == ''
            ? Container()
            : Container(
              margin: const EdgeInsets.all(10),
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  image: FileImage(File(imagePath))
                )
              ),
              child: imagePath.isEmpty ? const Icon(Icons.image_not_supported) : null,  // display icon if no image
            ),
            Expanded(
              flex: 1,
              child: Text('${listing['name']}', 
              textAlign: TextAlign.left, 
              style: TextStyle(fontSize: 18, color: myColorScheme.primary)),
            ),
            Expanded(
              flex: 1,
              child: Text('${listing['quantity']}', 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 18, color: myColorScheme.primary)),
            ),
            Expanded(
              flex: 1,
              child: Text('\$${listing['price'] * listing['quantity']}', 
              textAlign: TextAlign.right, 
              style: TextStyle(fontSize: 18, color: myColorScheme.primary)),
            ),
            const SizedBox(width: 20),
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
                        Row(
                          children: [
                            Align( //! Back Button
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                height: screenHeight * 0.07,
                                width: screenWidth * 0.08,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Material(
                                    color: myColorScheme.surfaceContainerHighest,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.arrow_back_ios_new, color: myColorScheme.primary, size: 15, weight: 20,),
                                            const SizedBox(width: 5),
                                            Text('Back', style: TextStyle(fontSize: 18, color: myColorScheme.primary)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ),
                              ),
                            ),
                            ElevatedButton(//! Debug Button
                              onPressed: (){
                                
                              }, 
                              child: Text('Debug', style: TextStyle(fontSize: 18, color: myColorScheme.primary)),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded( //! Listing Cards
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: myColorScheme.surface,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: myColorScheme.primary),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(10),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
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