import 'dart:async';

import 'package:flutter/material.dart';
import 'package:greengrocery/domain/models/user_order_model.dart';
import 'package:greengrocery/domain/models/product_model.dart';
import 'package:greengrocery/domain/models/user_model.dart';
import 'package:greengrocery/domain/repo/repo.dart';
import 'package:greengrocery/ui/pages/commons/product_item.dart';
import 'package:greengrocery/ui/pages/commons/sizable_circular_progress_indicator.dart';
import 'package:greengrocery/ui/pages/commons/widget_blur_bg.dart';
import 'package:greengrocery/ui/pages/commons/widget_confirm_box.dart';
import 'package:greengrocery/ui/pages/user_page/add_products_page/add_products.dart';
import 'package:greengrocery/ui/pages/user_page/user_page_bottom_nav_bar.dart';
import 'package:greengrocery/ui/pages/user_page/user_page_header.dart';

import '../commons/commons.dart';

class UserPage extends StatefulWidget {
  final int index;
  final List<ProductModel> allProductsList;
  final UserModel user;
  final String userLogged;

  const UserPage(this.index, this.allProductsList, this.user, this.userLogged,
      {Key? key})
      : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with TickerProviderStateMixin {
  bool orderLoaded = false;
  bool saving = false;
  bool changesSaved = false;
  bool hasToSave = false;
  bool dialogBoxVisible = false;
  int total = 0;
  List<UserOrderModel> order = [];

  late UserModel user;

  @override
  void initState() {
    user = widget.user;
    _fetchOrder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: Commons.commonAppBar(
              backBtn: !dialogBoxVisible,
              context: context,
              backResult: [changesSaved]),
          body: Stack(children: [
            Column(children: <Widget>[
              UserPageHeader(
                  user: user,
                  order: order,
                  userLogged: widget.userLogged,
                  onChange: (value) => setState(() {
                        dialogBoxVisible = value;
                      }),
                  upadateOrderReady: (value) => _upadateOrderReady(value)),
              Expanded(
                child: orderLoaded
                    ? ListView.builder(
                        itemCount: order.length,
                        itemBuilder: (context, index) {
                          return ProductItem(
                              item: order[index].product!,
                              onChange: () => setState(() {
                                    hasToSave = true;
                                    order[index];
                                  }),
                              removeItem: () => _onDismissed(index),
                              editAccess: !user.orderReady! &
                                  (user.userLogged! ||
                                      widget.userLogged == 'Sergio'),
                              selectable: false);
                        },
                      )
                    : const Center(
                        child: SizableCircularProgresIndicator(size: 50)),
              ),
            ]),
            if (dialogBoxVisible)
              BlurBg(
                  onTap: () => setState(() {
                        dialogBoxVisible = false;
                        user.orderReady = false;
                      })),
            if (dialogBoxVisible)
              ConfirmDialogBox(
                  response: (response) {
                    if (!response) {
                      setState(() {
                        dialogBoxVisible = false;
                        user.orderReady = false;
                      });
                    } else {
                      _upadateOrderReady(user.orderReady!);
                    }
                  },
                  icon: const Icon(Icons.warning_amber_rounded),
                  cardTitle: 'ATENCIÓN!!',
                  title: 'Pedido listo irreversible.',
                  info: 'No podrás deshacer este cambio.\n¿Quieres continuar?')
          ]),
          bottomNavigationBar: HomePageBottomNavBar(
              user: user,
              userLogged: widget.userLogged,
              hasToSave: hasToSave,
              saving: saving,
              navigateToAddProductsPage: () =>
                  _navigateToAddProductsPage(context),
              saveChanges: () => _saveChanges())),
    );
  }

  _fetchOrder() async {
    order = await Repo()
        .userOrder
        .getOrderById(user.idLastOrder!, widget.allProductsList);
    setState(() {
      orderLoaded = true;
    });
  }

  void _onDismissed(int i) {
    setState(() {
      order.removeAt(i);
      hasToSave = true;
    });
  }

  Future<void> _navigateToAddProductsPage(BuildContext context) async {
    final String userAlias =
        user.aliasOf!.isNotEmpty ? user.aliasOf! : user.name!;
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AddProductsPage(widget.allProductsList, userAlias, order)));

    if (result != null) {
      setState(() {
        order.addAll(result);
        order.sort(((a, b) => a.product!.name!.compareTo(b.product!.name!)));
        hasToSave = true;
      });
    }
  }

  void _upadateOrderReady(bool value) async {
    setState(() {
      user.orderReady = value;
      changesSaved = true;
      dialogBoxVisible = false;
    });
    await Repo().users.setOrderReady({"idUser": user.id, "orderReady": value});
    if (value && hasToSave) {
      await _saveChanges();
    }
  }

  _saveChanges() async {
    _saving(true);
    bool accessOk =
        await Repo().userOrder.putOrderById(order, user.idLastOrder!);

    showSnackBar(context: context, access: accessOk);

    setState(() {
      saving = false;
      changesSaved = true;
      hasToSave = accessOk ? false : true;
    });
  }

  void showSnackBar({required context, required access}) {
    String msg;
    Color bgColor;
    SnackBar snackBar(msg, bgColor) => SnackBar(
          content: Text(msg),
          backgroundColor: bgColor,
          duration: const Duration(milliseconds: 2000),
          behavior: SnackBarBehavior.floating,
        );
    if (!access) {
      msg = 'Error de acceso...';
      bgColor = const Color.fromARGB(255, 255, 17, 0);
    } else {
      msg = 'Actualización exitosa!!';
      bgColor = const Color.fromARGB(255, 0, 255, 8);
    }
    ScaffoldMessenger.of(context).showSnackBar(snackBar(
      msg,
      bgColor,
    ));
  }

  _saving(bool st) {
    setState(() {
      saving = st;
    });
  }
}
