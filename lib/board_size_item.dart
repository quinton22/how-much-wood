import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BoardSizeItem extends StatefulWidget {
  final EdgeInsets padding;
  final Function(TextEditingController widthController) registerWidthController;
  final Function(TextEditingController heightController)
      registerHeightController;

  const BoardSizeItem({
    Key? key,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    required this.registerHeightController,
    required this.registerWidthController,
  }) : super(key: key);

  @override
  State<BoardSizeItem> createState() => _BoardSizeItemState();
}

class _BoardSizeItemState extends State<BoardSizeItem> {
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final GlobalKey rowKey = GlobalKey();
  final GlobalKey key = GlobalKey();
  final padding = const EdgeInsets.all(8.0);
  String? heightUnits, widthUnits;
  Map<String, double> boxDim = {"width": 0.0, "height": 0.0};
  bool hasRunOnFirstBuild = false;

  void genericControllerListener() {
    setState(() {
      boxDim = getBoxDim(
          factoredDim: getFactored(
        width: widthController.text,
        height: heightController.text,
      ));
    });
  }

  @override
  void initState() {
    widthController.addListener(genericControllerListener);
    heightController.addListener(genericControllerListener);
    widget.registerHeightController(heightController);
    widget.registerWidthController(widthController);
    super.initState();
  }

  List<String> getCurrentUnits() {
    // ['mm', 'cm', 'm']
    return ['in', 'ft'];
  }

  String? validator(String? str) {
    return str == null || str.isEmpty ? "Fill in field" : null;
  }

  double getDouble(String? d) {
    try {
      return double.parse(d!);
    } catch (e) {}

    return 0.0;
  }

  Map<String, double> getFactored({String? width, String? height}) {
    double factoredWidth = 0.0, factoredHeight = 0.0;
    double parsedWidth = getDouble(width), parsedHeight = getDouble(height);
    try {
      if (parsedWidth == 0.0) {
        // width is null or 0
        factoredHeight = parsedHeight > 0.0 ? 1.0 : 0.0;
      } else if (parsedHeight == 0.0) {
        // width > 0 && height is null or 0
        factoredWidth = parsedHeight > 0.0 ? 1.0 : 0.0;
      } else {
        // width > 0 && height > 0
        final w = parsedWidth;
        final h = parsedHeight;

        final factor = max(w, h);
        factoredHeight = h / factor;
        factoredWidth = w / factor;
      }
      return {"width": factoredWidth, "height": factoredHeight};
    } catch (e) {}

    return {"width": 0.0, "height": 0.0};
  }

  Map<String, double> getBoxDim({required Map<String, double> factoredDim}) {
    if (key.currentContext == null) {
      return {"width": 0.0, "height": 0.0};
    }

    if (rowKey.currentContext == null) {
      return {"width": 0.0, "height": 0.0};
    }

    final rowRenderBox = rowKey.currentContext!.findRenderObject() as RenderBox;
    final flexRenderBox = key.currentContext!.findRenderObject() as RenderBox;

    final maxHeight = rowRenderBox.size.height - padding.bottom - padding.top;
    final maxWidth = flexRenderBox.size.width - padding.left - padding.right;

    final minDim = min(maxHeight, maxWidth);

    return {
      "width": (factoredDim['width'] ?? 0.0) * minDim,
      "height": (factoredDim['height'] ?? 0.0) * minDim
    };
  }

  @override
  void dispose() {
    widthController.removeListener(genericControllerListener);
    heightController.removeListener(genericControllerListener);

    super.dispose();
  }

  // todo: update to table?

  @override
  Widget build(BuildContext context) {
    heightUnits ??= widthUnits ??= getCurrentUnits()[0];

    return Padding(
      padding: widget.padding,
      child: Row(
        key: rowKey,
        children: [
          Flexible(
            key: key,
            child: Padding(
              padding: padding,
              child: Center(
                  child: Container(
                color: Colors.blue,
                width: boxDim['width'] ?? 0.0,
                height: boxDim['height'] ?? 0.0,
              )),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: heightController,
                          textAlign: TextAlign.end,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "height",
                          ),
                          inputFormatters: [
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              try {
                                final text = newValue.text;
                                if (text.isNotEmpty) double.parse(text);
                                return newValue;
                              } catch (e) {}
                              return oldValue;
                            }),
                          ],
                          validator: validator,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: DropdownButton(
                          items: getCurrentUnits()
                              .map((unit) => DropdownMenuItem(
                                  value: unit, child: Text(unit)))
                              .toList(),
                          onChanged: (String? value) {
                            setState(() {
                              heightUnits = value;
                            });
                          },
                          isDense: true,
                          value: heightUnits,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 48.0, top: 8.0),
                    child: Text(
                      "x",
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: TextFormField(
                          controller: widthController,
                          textAlign: TextAlign.end,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "width",
                          ),
                          inputFormatters: [
                            // FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              try {
                                final text = newValue.text;
                                if (text.isNotEmpty) double.parse(text);
                                return newValue;
                              } catch (e) {}
                              return oldValue;
                            }),
                          ],
                          validator: validator,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: DropdownButton(
                          items: getCurrentUnits()
                              .map((unit) => DropdownMenuItem(
                                  value: unit, child: Text(unit)))
                              .toList(),
                          onChanged: (String? value) {
                            setState(() {
                              widthUnits = value;
                            });
                          },
                          value: widthUnits,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
