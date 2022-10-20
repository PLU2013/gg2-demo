import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/services.dart';
import 'package:greengrocery/domain/models/product_model.dart';
import 'package:greengrocery/domain/repo/repo.dart';

typedef ConfirmFn = void Function(ProductModel product);

class ProductsTable extends StatefulWidget {
  final List<DataColumn> columnHeaders;
  final List<ProductModel> productList;
  final bool sortAscending;
  final int sortColumnIndex;

  final Function saving;
  final Function reSort;
  final ConfirmFn onItemLongPress;

  const ProductsTable(
      {required this.columnHeaders,
      required this.productList,
      required this.saving,
      required this.sortAscending,
      required this.sortColumnIndex,
      required this.reSort,
      required this.onItemLongPress,
      Key? key})
      : super(key: key);

  @override
  State<ProductsTable> createState() => _ProductsTableState();
}

class _ProductsTableState extends State<ProductsTable> {
  late List<ProductModel> productList;
  late Function saving;
  late Function reSort;

  late List<TextEditingController> priceC;
  late List<TextEditingController> unitC;
  late List<TextEditingController> priorityC;

  @override
  void initState() {
    productList = widget.productList;
    productList.sort(((a, b) => a.name!.compareTo(b.name!)));
    saving = widget.saving;
    reSort = widget.reSort;
    _initControllers();
    super.initState();
  }

  void _initControllers() {
    priceC = List<TextEditingController>.generate(
        productList.length, (index) => TextEditingController());

    unitC = List<TextEditingController>.generate(
        productList.length, (index) => TextEditingController());

    priorityC = List<TextEditingController>.generate(
        productList.length, (index) => TextEditingController());

    for (int i = 0; i < priorityC.length; i++) {
      priceC[i].text = productList[i].price!.toStringAsFixed(2);
      unitC[i].text = '${productList[i].unit}';
      priorityC[i].text = '${productList[i].priority}';
    }
    setState(() {
      priceC;
      unitC;
      priorityC;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productList != productList) productList = widget.productList;

    _initControllers();
    return Expanded(
      child: DataTable2(
        sortAscending: widget.sortAscending,
        sortColumnIndex: widget.sortColumnIndex,
        horizontalMargin: 10,
        columnSpacing: 0,
        headingRowColor: MaterialStateProperty.all(Colors.blueGrey[300]),
        headingRowHeight: 40,
        columns: widget.columnHeaders,
        rows: List<DataRow>.generate(
            productList.length,
            (i) => DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      // All rows will have the same selected color.
                      if (states.contains(MaterialState.selected)) {
                        return i.isEven
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.16)
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.08);
                      }
                      // Even rows will have a grey color.
                      if (i.isEven) {
                        return Colors.grey.withOpacity(0.2);
                      }
                      return null; // Use default value for other states and odd rows.
                    }),
                    selected: productList[i].availability!,
                    onLongPress: () => widget.onItemLongPress(productList[i]),
                    onSelectChanged: (value) async {
                      saving(true);
                      setState(() {
                        productList[i].availability = value;
                      });
                      if (!(await Repo()
                          .products
                          .putProductField(productList[i], 'availability'))) {
                        setState(() {
                          productList[i].availability =
                              !productList[i].availability!;
                        });
                      }
                      saving(false);
                    },
                    cells: [
                      DataCell(
                        Text('${productList[i].name}'),
                      ),
                      DataCell(TextFormField(
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9|.]'))
                        ],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        controller: priceC[i],
                        onTap: () => priceC[i].selection = TextSelection(
                            baseOffset: 0, extentOffset: priceC[i].text.length),
                        onFieldSubmitted: (value) {
                          editValue(value, i, 'price', priceC[i]);
                        },
                      )),
                      DataCell(TextFormField(
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        controller: unitC[i],
                        onTap: () => unitC[i].selection = TextSelection(
                            baseOffset: 0, extentOffset: unitC[i].text.length),
                        onFieldSubmitted: (value) {
                          editValue(value, i, 'unit', unitC[i]);
                        },
                      )),
                      DataCell(TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                        textAlign: TextAlign.center,
                        controller: priorityC[i],
                        onTap: () => priorityC[i].selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: priorityC[i].text.length),
                        onFieldSubmitted: (value) {
                          editValue(value, i, 'priority', priorityC[i]);
                        },
                      ))
                    ])),
      ),
    );
  }

  editValue(
      String value, int i, String fieldName, TextEditingController c) async {
    saving(true);
    Map<String, dynamic> productMap = productList[i].toMap();
    var oldValue = productMap[fieldName];
    var newValue = oldValue is int
        ? int.tryParse(value)
        : oldValue is double
            ? double.tryParse(value)
            : value;

    productMap[fieldName] = newValue;

    setState(() {
      productList[i] = ProductModel.fromMap(productMap);
    });

    if (!(await Repo().products.putProductField(productList[i], fieldName))) {
      productMap[fieldName] = oldValue;
      productList[i] = ProductModel.fromMap(productMap);
      setState(() {
        c.text = fieldName == 'price'
            ? productList[i].price!.toStringAsFixed(2)
            : '${productMap[fieldName]}';
      });
    } else {
      if (fieldName == 'price') {
        c.text = productList[i].price!.toStringAsFixed(2);
      }
    }

    if (fieldName == 'price' && widget.sortColumnIndex == 1 ||
        fieldName == 'unit' && widget.sortColumnIndex == 2 ||
        fieldName == 'priority' && widget.sortColumnIndex == 3) {
      reSort(widget.sortColumnIndex, widget.sortAscending);
    }

    saving(false);
  }
}
