import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greengrocery/domain/models/user_order_model.dart';
import 'package:greengrocery/domain/models/product_model.dart';
import 'package:greengrocery/ui/pages/commons/product_item.dart';

import '../../commons/commons.dart';

class AddProductsPage extends StatefulWidget {
  final List<ProductModel> products;
  final List<UserOrderModel> order;
  final String user;

  const AddProductsPage(this.products, this.user, this.order, {Key? key})
      : super(key: key);

  @override
  State<AddProductsPage> createState() => _AddProductsPageState();
}

class _AddProductsPageState extends State<AddProductsPage> {
  List<ProductModel> productsList = [];
  bool isChecked = false;

  Timer? delay;
  Timer? interval;

  @override
  void initState() {
    super.initState();
    productsList = filterProductsByUserOrder(widget.products, widget.order);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Commons.commonAppBar(backBtn: true, context: context),
        body: Column(
          children: [
            Row(
              children: const <Widget>[
                Expanded(
                    child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Seleccione sus Productos:',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ))),
              ],
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: productsList.length,
                  itemBuilder: ((context, index) {
                    return ProductItem(
                        item: productsList[index],
                        onChange: () {},
                        removeItem: () {},
                        selectable: true);
                  })),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Colors.blueGrey, Colors.black],
                  stops: [0.0, 0.9])),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10, right: 20),
                child: FloatingActionButton(
                  onPressed: () => _confirmAddProducts(),
                  backgroundColor: Colors.blue,
                  elevation: 5,
                  child: const Icon(Icons.save),
                ),
              ),
            ],
          ),
        ));
  }

  /// Delete all the products that the user already has in their orders
  List<ProductModel> filterProductsByUserOrder(
      List<ProductModel> productsList, List<UserOrderModel> order) {
    List<ProductModel> filteredProductList = productsList.where(((pe) {
      bool response = true;
      for (UserOrderModel oe in order) {
        response = response & (oe.product!.name != pe.name) & pe.availability!;
        if (!response) break;
      }
      return response;
    })).toList();

    for (var p in filteredProductList) {
      p.checked = false;
      p.auxQty = 0;
    }
    return filteredProductList;
  }

  void _confirmAddProducts() {
    List<UserOrderModel> addOrder = [];
    for (ProductModel e in productsList) {
      UserOrderModel item = UserOrderModel();
      if (e.checked!) {
        item.product = e;
        addOrder.addAll([item]);
      }
    }
    Navigator.pop(context, addOrder);
  }
}
