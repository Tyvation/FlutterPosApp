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
  String _buffer = '';
  DateTime _lastKeyPressTime = DateTime.now();
  static const Duration _inhumanTypeSpeed = Duration(milliseconds: 50); // 調整這個值以適應您的掃描器速度

  @override 
  void initState() {
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

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final now = DateTime.now();
      if (now.difference(_lastKeyPressTime) < _inhumanTypeSpeed) {
        _buffer += event.character ?? '';
        if (_buffer.length >= 5) { // 假設條碼至少有5個字符
          _barFocusNode.requestFocus();
          // 在這裡處理 _buffer 中的條碼
          print('Scanned barcode: $_buffer');
          _buffer = '';
        }
      } else {_buffer = event.character ?? '';}
      _lastKeyPressTime = now;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _KLFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
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