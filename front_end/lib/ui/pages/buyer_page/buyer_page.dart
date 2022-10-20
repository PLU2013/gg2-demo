import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greengrocery/domain/models/order_model.dart';
import 'package:greengrocery/domain/models/product_model.dart';
import 'package:greengrocery/domain/models/user_model.dart';
import 'package:greengrocery/domain/repo/repo.dart';
import 'package:greengrocery/ui/pages/commons/sizable_circular_progress_indicator.dart';
import 'package:greengrocery/ui/pages/commons/widget_blur_bg.dart';
import 'package:greengrocery/ui/pages/commons/widget_confirm_box.dart';
import 'package:greengrocery/ui/pages/buyer_page/widget_data_table.dart';
import 'package:greengrocery/ui/pages/buyer_page/widget_dialog_box.dart';
import 'package:greengrocery/ui/pages/commons/commons.dart';
import 'package:greengrocery/ui/pages/home_page/home_page.dart';
import 'package:greengrocery/ui/pages/init_page/init_page.dart';

class ToBuy extends StatefulWidget {
  final List<ProductModel> products;
  final List<UserModel> users;

  const ToBuy({required this.products, required this.users, Key? key})
      : super(key: key);

  @override
  State<ToBuy> createState() => _ToBuyState();
}

class _ToBuyState extends State<ToBuy> {
  late List<UserModel> users;
  late List<ProductModel> products;
  late ProductModel editedProduct, beforeEditingProduct;
  late bool purchasingInitiated;

  bool purchasingFinished = false;

  Timer? delayToSave;
  String totalCost = '0.00';

  bool loadingOrders = false;
  bool priceDialogBoxVisible = false;
  bool confirmStartPurchasingDialogBoxVisible = false;
  bool confirmDialogBoxVisible = false;
  bool updatingProduct = false;
  List<ProductModel> totalProducts = [];

  List<DataColumn> columnHeaders = const <DataColumn>[
    DataColumn(
        label: Text(
      'Producto',
      style: TextStyle(fontSize: 14),
    )),
    DataColumn(
        label: Text(
      'Cant',
      style: TextStyle(fontSize: 14),
    )),
    DataColumn(
        label: Text(
      'Precio Unit.',
      style: TextStyle(fontSize: 14),
    )),
  ];

  @override
  void initState() {
    users = widget.users;
    products = widget.products;
    purchasingInitiated =
        Repo().localStorage.getLocalItem('purchasingState') ?? false;
    _fetchOrdersAndFilter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: Commons.commonAppBar(
              backBtn: !purchasingInitiated &
                  !confirmStartPurchasingDialogBoxVisible,
              context: context,
              backResult: purchasingInitiated ? 'notShowIcon' : 'showIcon'),
          body: getBody(),
          bottomNavigationBar: Container(
            height: 77,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.blueGrey, Colors.black],
                    stops: [0.0, 0.9])),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              child: FloatingActionButton.extended(
                elevation: 10,
                icon: const Icon(Icons.arrow_circle_right_outlined),
                label: Text(!purchasingInitiated
                    ? 'Iniciar compra'
                    : !purchasingFinished
                        ? 'Finalizar compra'
                        : 'Salir'),
                onPressed: (priceDialogBoxVisible |
                        confirmDialogBoxVisible |
                        confirmStartPurchasingDialogBoxVisible)
                    ? null
                    : () {
                        if (purchasingFinished) exit(0);
                        if (!purchasingInitiated) {
                          setState(() {
                            confirmStartPurchasingDialogBoxVisible = true;
                          });
                        } else {
                          setState(() {
                            confirmDialogBoxVisible = true;
                          });
                        }
                      },
                backgroundColor:
                    (priceDialogBoxVisible | confirmDialogBoxVisible)
                        ? Colors.black12
                        : Colors.blue,
              ),
            ),
          )),
    );
  }

  Widget getBody() {
    return Stack(children: [
      Column(
        children: <Widget>[
          Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pedido',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    'Total: \$$totalCost'),
              ),
            ],
          ),
          PurchasingTable(
            disableRows: purchasingFinished | !purchasingInitiated,
            columnHeaders: columnHeaders,
            productList: totalProducts,
            saveAdvance: () => _saveLocalAdvance(),
            onEditTap: (product) => _editPriceHandler(product),
            onCheckBoxChange: () =>
                setState(() => totalCost = _totalCalculator()),
          )
        ],
      ),
      if (priceDialogBoxVisible ||
          confirmDialogBoxVisible ||
          confirmStartPurchasingDialogBoxVisible)
        BlurBg(onTap: () {
          setState(() {
            priceDialogBoxVisible = false;
            confirmDialogBoxVisible = false;
            confirmStartPurchasingDialogBoxVisible = false;
          });
        }),
      if (priceDialogBoxVisible)
        PriceChangeDialogBox(
          editedProduct: editedProduct,
          onResponse: (editedProduct) =>
              _editPriceResponseHandler(editedProduct),
        ),
      if (confirmStartPurchasingDialogBoxVisible)
        ConfirmDialogBox(
          response: (res) => _startPurchasing(res),
          icon: const Icon(Icons.info_sharp),
          cardTitle: 'Inicio de compra',
          title: '¿Iniciar compra?',
          info: 'Este comando inicia el proceso de compra.',
        ),
      if (confirmDialogBoxVisible)
        ConfirmDialogBox(
            icon: const Icon(
              Icons.info_sharp,
              color: Colors.black,
              size: 30,
            ),
            cardTitle: 'Finalización de compra.',
            title: '¿Finalizar la compra actual?.',
            info:
                'Todos los productos no tildados serán marcados como no disponibles.',
            response: (res) => _purchaseComplited(res)),
      if (updatingProduct || loadingOrders)
        const Center(child: SizableCircularProgresIndicator(size: 50))
    ]);
  }

  String _totalCalculator() {
    if (!purchasingInitiated) {
      return totalProducts
          .fold<double>(
              0,
              (previousValue, e) =>
                  previousValue +
                  ((e.availability!) ? e.auxQty! * e.price! : 0))
          .toStringAsFixed(2);
    }
    return totalProducts
        .fold<double>(
            0,
            (previousValue, e) =>
                previousValue +
                ((e.availability! & e.checked!) ? e.auxQty! * e.price! : 0))
        .toStringAsFixed(2);
  }

  _editPriceHandler(ProductModel product) {
    beforeEditingProduct = ProductModel.fromMap(product.toMap());
    setState(() {
      editedProduct = product;
      priceDialogBoxVisible = true;
    });
  }

  _editPriceResponseHandler(ProductModel? editedProduct) async {
    if (editedProduct != null) {
      editedProduct.edited = true;

      List<Map<String, dynamic>> totalProductsMp =
          List.generate(totalProducts.length, (i) => totalProducts[i].toMap());
      await Repo().localStorage.setLocalItem('totalProducts', totalProductsMp);
    }
    setState(() {
      priceDialogBoxVisible = false;
      totalCost = _totalCalculator();
      totalProducts.sort(((a, b) => a.priority!.compareTo(b.priority!)));
    });
  }

  Future<void> _startPurchasing(res) async {
    if (res) {
      await Repo().localStorage.setLocalItem('purchasingState', true);
      setState(() {
        purchasingInitiated = true;
        totalCost = _totalCalculator();
      });
      await _saveLocalAdvance();
    }
    setState(() {
      confirmStartPurchasingDialogBoxVisible = false;
    });
  }

  Future<void> _saveLocalAdvance() async {
    if (purchasingInitiated) {
      List<Map<String, dynamic>> totalProductsMp =
          List.generate(totalProducts.length, (i) => totalProducts[i].toMap());
      await Repo().localStorage.setLocalItem('totalProducts', totalProductsMp);
    }
  }

  void showSnackBar({required context}) {
    String msg;
    Color bgColor;
    SnackBar snackBar(msg, bgColor) => SnackBar(
          content: Text(msg),
          backgroundColor: bgColor,
          duration: const Duration(milliseconds: 3000),
          behavior: SnackBarBehavior.floating,
        );
    msg = 'Todos deben tener pedido listo';
    bgColor = const Color.fromARGB(255, 255, 17, 0);
    ScaffoldMessenger.of(context).showSnackBar(snackBar(
      msg,
      bgColor,
    ));
  }

  _fetchOrdersAndFilter() async {
    if (!purchasingInitiated) {
      setState(() {
        loadingOrders = true;
      });
      List<OrdersModel> orders = await Repo().orders.getOrderssApi();
      totalProducts = _productsFilter(orders);
    } else {
      List totalProductsMp = Repo().localStorage.getLocalItem('totalProducts');
      totalProducts = List.generate(totalProductsMp.length,
          (i) => ProductModel.fromMap(totalProductsMp[i]));
    }

    setState(() {
      loadingOrders = false;
      totalCost = _totalCalculator();
    });
  }

  List<ProductModel> _productsFilter(List<OrdersModel> orders) {
    List<ProductModel> tProducts = [];
    for (ProductModel e in products) {
      e.auxQty = 0;
      e.checked = false;
    }
    products.sort((a, b) => a.priority!.compareTo(b.priority!));
    for (ProductModel p in products) {
      if (p.availability!) {
        for (OrdersModel oneUserOrder in orders) {
          UserModel user =
              users.where((u) => u.id == oneUserOrder.userId).toList()[0];
          if (user.orderReady!) {
            int productQty = oneUserOrder.orderList!
                .firstWhere((e) => e[0] == p.id, orElse: () => [0, 0])[1];
            if (productQty > 0) {
              p.auxQty = p.auxQty! + productQty;
            }
          }
        }
        if (p.auxQty! > 0) {
          tProducts.addAll([p]);
        }
      }
    }

    products.sort((a, b) => a.name!.compareTo(b.name!));

    return tProducts;
  }

  _purchaseComplited(bool res) async {
    if (res) {
      setState(() {
        updatingProduct = true;
      });
      Map<String, List<Object>> response = await Repo().purchaseComplited();
      if (response.containsKey('non connection')) {
        setState(() {
          purchasingFinished = true;
          confirmDialogBoxVisible = false;
          updatingProduct = false;
        });
      } else {
        setState(() {
          confirmDialogBoxVisible = false;
          updatingProduct = false;
        });
        Repo().webSocket.socketInitOk
            ? _returnHomePage(response['users'], response['products'])
            : _returnInitPage();
      }
    } else {
      setState(() {
        confirmDialogBoxVisible = false;
      });
    }
  }

  _returnHomePage(newUsers, newProducts) {
    if (products.isNotEmpty) products.removeWhere((element) => true);
    products.addAll(newProducts);
    Map<String, dynamic> localUser = Repo().localStorage.getLocalUser();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomePage(localUser['name'], newUsers, newProducts)));
  }

  _returnInitPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: ((context) => const Init())));
  }
}
