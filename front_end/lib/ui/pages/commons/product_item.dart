import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greengrocery/domain/models/product_model.dart';

typedef RemoveItem = void Function();
typedef OnChange = void Function();

class ProductItem extends StatefulWidget {
  const ProductItem(
      {this.editAccess,
      required this.item,
      required this.onChange,
      required this.removeItem,
      required this.selectable,
      Key? key})
      : super(key: key);

  final bool? editAccess;
  final ProductModel item;
  final OnChange onChange;
  final RemoveItem removeItem;
  final bool selectable;

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  Timer? delay;
  Timer? interval;

  late bool editAccess;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    editAccess = widget.editAccess ?? false || widget.item.checked!;
    return Dismissible(
      key: UniqueKey(),
      direction: widget.editAccess ?? false
          ? DismissDirection.startToEnd
          : DismissDirection.none,
      onDismissed: (direction) {
        widget.removeItem();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Card(
          elevation: 10,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            horizontalTitleGap: 0,
            dense: widget.selectable ? true : false,
            leading: widget.selectable
                ? Checkbox(
                    value: widget.item.checked,
                    onChanged: (value) {
                      setState(() {
                        widget.item.checked = value;
                        widget.item.auxQty = value! ? 1 : 0;
                      });
                    },
                  )
                : null,
            title: SizedBox(
              width: double.maxFinite,
              child: Row(children: [
                Expanded(
                  child: Text(
                    '${widget.item.name}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                SizedBox(
                    width: 55,
                    child: Center(
                        child:
                            Text('${widget.item.auxQty} ${widget.item.unit}')))
              ]),
            ),
            subtitle: Text(
                '\$${(widget.item.price! * (editAccess ? widget.item.auxQty! : 1)).toStringAsFixed(2)}'),
            trailing: SizedBox(
              width: 115,
              child: Row(children: [
                Listener(
                  onPointerDown: editAccess
                      ? (event) =>
                          countinuousPressedHandler(st: true, value: -1)
                      : null,
                  onPointerUp: editAccess
                      ? (event) =>
                          countinuousPressedHandler(st: false, value: -1)
                      : null,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(), elevation: 5),
                      onPressed: editAccess ? () {} : null,
                      child: const Text('-')),
                ),
                Listener(
                  onPointerDown: editAccess
                      ? (event) => countinuousPressedHandler(st: true, value: 1)
                      : null,
                  onPointerUp: editAccess
                      ? (event) =>
                          countinuousPressedHandler(st: false, value: 1)
                      : null,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(), elevation: 5),
                      onPressed: editAccess ? () {} : null,
                      child: const Text('+')),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  countinuousPressedHandler({required bool st, required int value}) {
    if (st) {
      delay = Timer(const Duration(milliseconds: 400), () {
        interval = Timer.periodic(const Duration(milliseconds: 80), (timer) {
          _plusValue(value: value);
        });
      });
    } else {
      delay!.cancel();
      if (interval != null) {
        interval!.cancel();
      }
      _plusValue(value: value);
    }
  }

  _plusValue({required int value}) {
    widget.item.auxQty! >= 50 ? value *= 10 : value;
    int newQty = widget.item.auxQty! + value;
    newQty = newQty < 1 ? 1 : newQty;
    widget.onChange();
    setState(() {
      widget.item.auxQty = newQty.toInt();
    });
  }
}
