import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greengrocery/domain/repo/repo.dart';
import 'package:greengrocery/domain/models/product_model.dart';
import 'package:greengrocery/domain/models/user_model.dart';
import 'package:greengrocery/ui/pages/commons/commons.dart';
import 'package:greengrocery/ui/pages/commons/widget_blur_bg.dart';
import 'package:greengrocery/ui/pages/commons/widget_message_box.dart';
import 'package:greengrocery/ui/pages/deal_out_page/deal_out_page.dart';
import 'package:greengrocery/ui/pages/home_page/home_page_body.dart';
import 'package:greengrocery/ui/pages/home_page/home_page_drawer.dart';
import 'package:greengrocery/ui/pages/login_page/login_page.dart';
import 'package:greengrocery/ui/pages/buyer_page/buyer_page.dart';
import 'package:greengrocery/ui/pages/user_page/user_page.dart';
import 'package:greengrocery/ui/pages/products_management_page/products_management_page.dart';

/// Initial page, show an users list with its user state
class HomePage extends StatefulWidget {
  final String userLogged;
  final List<UserModel> users;
  final List<ProductModel> products;

  const HomePage(this.userLogged, this.users, this.products, {Key? key})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late List<UserModel> users;
  late StreamSubscription streamSubscription;
  late bool purchasingInitiated;
  late bool purchasePending;

  bool _isInForeground = true;
  bool updating = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    users = _loggedUserFirst();
    purchasingInitiated =
        Repo().localStorage.getLocalItem('purchasingState') ?? false;
    purchasePending =
        Repo().localStorage.getLocalItem('updateProductsPending') ?? false;
    streamSubscription =
        Repo().streamSocket.getRes.listen((data) => _handleSteamSub(data));
    if (purchasePending) _updatePuchasing();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
    await _socketConnectionHandler();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Commons.commonAppBar(backBtn: false, context: context),
        drawer: !purchasingInitiated
            ? HomePageDrawer(
                userLoggedName: widget.userLogged, menuCfg: _menuCfg)
            : null,
        body: Stack(children: [
          HomePageBody(users: users, navigateToUserPage: _navigateToUserPage),
          if (updating) BlurBg(onTap: () {}),
          if (updating)
            const MessageBox(
              icon: Icon(Icons.info_outline),
              cardTitle: 'Actualizando...',
              title:
                  'Se están guardando los cambios generados en el proceso de compra',
            )
        ]),
        bottomNavigationBar: Container(
            height: 77,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.blueGrey, Colors.black],
                    stops: [0.0, 0.9]))));
  }

  List<UserModel> _loggedUserFirst() {
    widget.users.sort(
        (a, b) => b.userLogged!.toString().compareTo(a.userLogged!.toString()));
    return widget.users;
  }

  Future<void> _socketConnectionHandler() async {
    if (!_isInForeground) {
      Repo().webSocket.disconnect();
    } else {
      if (Repo().webSocket.socket.disconnected) {
        Repo().webSocket.connect();
        List<UserModel> usersUpd =
            await Repo().users.getUsersApi(widget.userLogged);
        for (UserModel u in usersUpd) {
          int userIndex = users.indexWhere((e) => e.name == u.name);
          users[userIndex].online = u.online! || widget.userLogged == u.name!;
          users[userIndex].orderReady = u.orderReady!;
        }
        setState(() {
          users;
        });
      }
    }
  }

  _handleSteamSub(data) async {
    if (data.containsKey('idUser')) {
      int userId = data['idUser'];
      if (data.containsKey('orderReady')) {
        int userIndex = users.indexWhere((e) => e.id == userId);
        setState(() {
          users[userIndex].orderReady = data['orderReady'];
        });
      }
      if (data.containsKey('online')) {
        int userIndex = users.indexWhere((e) => e.id == userId);
        setState(() {
          users[userIndex].online = data['online'];
        });
      }
    } else if (data.containsKey('message')) {
      if (data['message'] == 'AllOrderReadyOff') {
        for (UserModel user in users) {
          user.orderReady = false;
        }
        setState(() {
          users;
        });
      } else if (data.containsKey('from')) {
        List validUsers = users.where((e) => e.name == data['from']).toList();
        if (validUsers.length == 1 &&
            data['from'] != widget.userLogged &&
            (data['to'] == 'All' || data['to'] == widget.userLogged)) {
          if (data['message'] == 'updateProducts') {
            List<ProductModel> newProductList =
                await Repo().products.getProductsApi();
            widget.products.removeWhere((element) => true);
            widget.products.addAll(newProductList);
          }
        }
      }
    }
  }

  _updatePuchasing() async {
    updating = true;
    setState(() {});
    Map<String, List<Object>> up = await Repo().purchaseComplited();
    if (widget.products.isNotEmpty) widget.products.removeWhere((p) => true);
    widget.products.addAll(up['products'] as List<ProductModel>);
    updating = false;
    setState(() {});
  }

  bool ready2buyVerification() {
    int orCount = 0;

    for (UserModel user in users) {
      orCount += user.orderReady! ? 1 : 0;
    }
    return orCount == users.length;
  }

  h() => (widget.userLogged == ('Sergio')) | (widget.userLogged == ('Walter'));

  List<Map> _menuCfg() => [
        {'title': 'User Logout', 'funct': _userLogout, 'visibility': true},
        {
          'title': 'Pedido total',
          'funct': _navigateToBuy,
          'visibility': h() && ready2buyVerification()
        },
        {'title': 'Distribuir', 'funct': _navigateToDealOut, 'visibility': h()},
        {
          'title': 'Gestión de Productos',
          'funct': _navigateToProductsMngmt,
          'visibility': h()
        },
        {'title': 'Reset', 'funct': _resetSavedAdvance, 'visibility': h()},
        {'title': 'Salir', 'funct': _exitFunction, 'visibility': true}
      ];

  Future<void> _navigateToUserPage(int i, BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UserPage(i, widget.products, users[i], widget.userLogged)));
  }

  void _userLogout() async {
    Repo().localStorage.deleteLocalUser();
    Repo().webSocket.socket.dispose();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login()));
  }

  void _navigateToBuy() async {
    String? backResult = await Navigator.push<String>(
        context,
        MaterialPageRoute(
            builder: (context) => ToBuy(
                  products: widget.products,
                  users: users,
                )));
    if (!mounted) return;
    if (backResult == 'showIcon') {
      Navigator.pop(context);
    } else {
      Navigator.of(context)
        ..pop()
        ..pop();
    }
  }

  void _navigateToProductsMngmt() async {
    var backResult = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductsMngmt(products: widget.products)));
    if (!mounted) return;
    Navigator.pop(context);
    if (backResult ?? false) {
      await Repo()
          .users
          .sendBroadcast(from: widget.userLogged, message: 'updateProducts');
    }
    widget.products.sort(((a, b) => a.name!.compareTo(b.name!)));
  }

  void _navigateToDealOut() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DealOutPage(
                  products: widget.products,
                  users: users,
                )));
    result();

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _exitFunction() {
    exit(0);
  }

  void _resetSavedAdvance() async {
    await Repo().localStorage.deleteLocalItem('totalProducts');
    await Repo().localStorage.deleteLocalItem('purchasingState');
    await Repo().localStorage.deleteLocalItem('updateProductsPending');
    Repo().localStorage.deleteLocalItem('dealOut');
    if (!mounted) return;
    Navigator.pop(context);
  }
}
