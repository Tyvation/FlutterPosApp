import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Sections/item_list_display.dart';
import '../Sections/preview_list_display.dart';

class PosPage extends StatefulWidget {
  const PosPage({super.key});

  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  late FocusNode _barFocusNode;
  late FocusNode _KLFocusNode;

  @override void initState() {
    _KLFocusNode = FocusNode();
    _barFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _KLFocusNode.dispose();
    _barFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _KLFocusNode,
      autofocus: true,
      onKeyEvent: (event){
        if(event is KeyDownEvent){
          _barFocusNode.requestFocus();
        }
      },
      child: Row(
        children:[
          Expanded(flex:2, child: ItemListDisplay()),
          Expanded(flex:1, child: PreviewListDisplay(
            barFocusNode: _barFocusNode, 
            KLfocusNode: _KLFocusNode,
          )),
        ]
      ),
    );
  }
}