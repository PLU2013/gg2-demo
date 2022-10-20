import 'dart:async';

import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:greengrocery/domain/models/product_model.dart';

class PurchasingTable extends StatefulWidget {
  final bool disableRows;
  final List<DataColumn> columnHeaders;
  final List<ProductModel> productList;

  final Function saveAdvance;
  final Function onEditTap;
  final Function onCheckBoxChange;

  const PurchasingTable(
      {required this.columnHeaders,
      required this.productList,
      required this.saveAdvance,
      required this.onEditTap,
      required this.onCheckBoxChange,
      required this.disableRows,
      Key? key})
      : super(key: key);

  @override
  State<PurchasingTable> createState() => _DataTableState();
}

class _DataTableState extends State<PurchasingTable> {
  late List<ProductModel> productList;
  late Function onEditTap;

  Timer? delayToSave;

  @override
  void initState() {
    productList = widget.productList;
    onEditTap = widget.onEditTap;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productList != productList) {
      setState(() {
        productList = widget.productList;
      });
    }
    return Expanded(
      child: DataTable2(
        horizontalMargin: 10,
        columnSpacing: 0,
        headingRowColor: MaterialStateProperty.all(Colors.blueGrey[300]),
        headingRowHeight: 40,
        columns: widget.columnHeaders,
        rows: List<DataRow>.generate(
            productList.length,
            (i) => DataRow(
                    selected: productList[i].checked!,
                    onSelectChanged: (value) {
                      if (!widget.disableRows) {
                        if (delayToSave != null) delayToSave!.cancel();
                        delayToSave =
                            Timer(const Duration(milliseconds: 50), () {
                          widget.saveAdvance();
                        });
                        setState(
                          () => productList[i].checked = value,
                        );
                        widget.onCheckBoxChange();
                      }
                    },
                    cells: [
                      DataCell(
                        Text('${productList[i].name}'),
                      ),
                      DataCell(Text(
                          '${productList[i].auxQty} ${productList[i].unit}')),
                      DataCell(
                          Text('\$${productList[i].price!.toStringAsFixed(2)}'),
                          showEditIcon: true,
                          onTap: !widget.disableRows
                              ? () => onEditTap(productList[i])
                              : null)
                    ])),
      ),
    );
  }
}
