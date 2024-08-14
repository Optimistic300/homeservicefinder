import 'package:flutter/material.dart';

class SearchTextFieldWidget extends StatefulWidget {
  final ValueChanged<String> onTextChanged;

  SearchTextFieldWidget({required this.onTextChanged});

  @override
  _SearchTextFieldWidgetState createState() => _SearchTextFieldWidgetState();
}

class _SearchTextFieldWidgetState extends State<SearchTextFieldWidget> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textEditingController,
      onChanged: widget.onTextChanged,
      style: TextStyle(
        fontFamily: 'Montserrat',
      ),
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
