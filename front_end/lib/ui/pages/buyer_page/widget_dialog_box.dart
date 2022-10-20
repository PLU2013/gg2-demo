import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greengrocery/domain/models/product_model.dart';

typedef Response = void Function(ProductModel? editedProduct);

class PriceChangeDialogBox extends StatefulWidget {
  final ProductModel editedProduct;
  final Response onResponse;

  const PriceChangeDialogBox(
      {required this.editedProduct, required this.onResponse, Key? key})
      : super(key: key);

  @override
  State<PriceChangeDialogBox> createState() => _PriceChangeDialogBoxState();
}

class _PriceChangeDialogBoxState extends State<PriceChangeDialogBox> {
  late Response onResponse;
  late ProductModel editedProduct;
  late double initPrice;
  late int initPriority;

  bool priceDialogBoxVisible = false;
  int qty4PriceCalculator = 1;

  TextEditingController priceTxtController = TextEditingController();
  TextEditingController qtyTxtController = TextEditingController();
  TextEditingController priorityTxtController = TextEditingController();

  @override
  void initState() {
    editedProduct = widget.editedProduct;
    priceTxtController.text = editedProduct.price!.toStringAsFixed(2);
    priceTxtController.selection = TextSelection(
        baseOffset: 0, extentOffset: priceTxtController.text.length);
    qtyTxtController.text = qty4PriceCalculator.toString();
    priorityTxtController.text = editedProduct.priority.toString();
    onResponse = widget.onResponse;
    initPrice = editedProduct.price!;
    initPriority = editedProduct.priority!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: Card(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            )),
            elevation: 10,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.blueGrey[300],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: ListTile(
                    leading: const Icon(Icons.mode_edit_outline_outlined),
                    title: Text('${editedProduct.name} (${editedProduct.unit})',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Modificar precio'),
                    trailing: GestureDetector(
                      child: const Icon(Icons.cancel),
                      onTap: () {
                        onResponse(null);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      const Text('Precio: \$'),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          autofocus: true,
                          onTap: () {
                            priceTxtController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: priceTxtController.text.length);
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9|.]'))
                          ],
                          controller: priceTxtController,
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            setState(() {
                              priceTxtController;
                            });
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('para'),
                      ),
                      SizedBox(
                        width: 40,
                        child: TextField(
                          onTap: () {
                            qtyTxtController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: qtyTxtController.text.length);
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: qtyTxtController,
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            setState(() {
                              qty4PriceCalculator = int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text('${editedProduct.unit}.'),
                      )
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    children: [
                      const Text('Modificar prioridad:'),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          onTap: () {
                            priorityTxtController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset:
                                    priorityTxtController.text.length);
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: priorityTxtController,
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            editedProduct.priority = int.tryParse(value);
                            editedProduct.priority ?? 1;
                            setState(() {
                              editedProduct;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 8, right: 8, bottom: 30),
                  child: Container(
                    width: double.maxFinite,
                    height: 40,
                    color: Colors.blueGrey[300],
                    child: Center(
                      child: Text(
                        'Precio por ${editedProduct.unit} => \$'
                        '${qty4PriceCalculator > 0 ? ((double.tryParse(priceTxtController.text) ?? 0) / qty4PriceCalculator).toStringAsFixed(2) : 'Error'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                            (qty4PriceCalculator > 0 &&
                                    double.tryParse(priceTxtController.text) !=
                                        null
                                ? Colors.black
                                : Colors.grey)),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blueGrey[300])),
                    onPressed: () {
                      if (qty4PriceCalculator > 0 &&
                          double.tryParse(priceTxtController.text) != null) {
                        setState(() {
                          editedProduct.price =
                              double.tryParse(priceTxtController.text)! /
                                  qty4PriceCalculator;
                        });
                        onResponse(editedProduct.price != initPrice ||
                                editedProduct.priority != initPriority
                            ? editedProduct
                            : null);
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Listo'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
