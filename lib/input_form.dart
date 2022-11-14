import 'package:flutter/material.dart';
import 'package:how_much_wood/board_size_item.dart';

class InputForm extends StatefulWidget {
  const InputForm({Key? key}) : super(key: key);

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  final _formKey = GlobalKey<FormState>();
  final boardSizeCtlr = TextEditingController();
  List<Map<String, TextEditingController?>> boards = [];

  static const padding = EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);

  Widget header() {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(padding.left, 0, padding.right, padding.bottom),
      child: TextFormField(
        controller: boardSizeCtlr,
      ),
    );
  }

  Widget footer() {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding.left, padding.top, padding.right, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                boards.add({
                  "width": null,
                  "height": null,
                });
              });
            },
            child: const Text("Add board"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState == null) {
                return;
              }
              if (_formKey.currentState!.validate()) {
                final savedBoards = boards.map((item) => {
                      "width": double.tryParse(item['width']!.text),
                      "height": double.tryParse(item['height']!.text)
                    });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
              }
            },
            child: const Text("Calculate"),
          ),
        ],
      ),
    );
  }

  Widget listItemBuilder(int index) {
    return Dismissible(
        background: Container(
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white)),
        key: Key("boardSizeItem-${index - 1}"),
        onDismissed: (direction) {
          setState(() {
            boards.removeAt(index);
          });
        },
        child: BoardSizeItem(
          padding: padding,
          registerHeightController: (ctlr) => boards[index]['height'] = ctlr,
          registerWidthController: (ctlr) => boards[index]['width'] = ctlr,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Form(
          key: _formKey,
          child: ListView(
            children: [
              header(),
              ...boards
                  .asMap()
                  .entries
                  .map((entry) => listItemBuilder(entry.key)),
              footer()
            ],
          )),
    );
  }
}

/*
data:

 - board size
 - n internal boards h x w
 - options
    - units = imperial [, metric]
    - blade width (kerf) = 1/8"
    - contain method = can use outside edge of board [, must contain in board]
*/
