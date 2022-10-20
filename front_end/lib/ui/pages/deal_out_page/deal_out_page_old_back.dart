import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greengrocery/domain/models/order_model.dart';
import 'package:greengrocery/domain/models/product_model.dart';
import 'package:greengrocery/domain/models/user_model.dart';
import 'package:greengrocery/domain/repo/repo.dart';
import 'package:greengrocery/ui/pages/commons/commons.dart';
import 'package:greengrocery/ui/pages/commons/sizable_circular_progress_indicator.dart';

class DealOutPage extends StatefulWidget {
  final List<ProductModel> products;
  final List<UserModel> users;

  const DealOutPage({required this.products, required this.users, Key? key})
      : super(key: key);

  @override
  State<DealOutPage> createState() => _DealOutPageState();
}

class _DealOutPageState extends State<DealOutPage> {
  final PageController pageController = PageController();
  final ScrollController controllerTwo = ScrollController();
  int scrollIndex = 0;
  List filteredProducts = [];

  @override
  void initState() {
    _fetchOrdersAndFilter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Commons.commonAppBar(
          backBtn: true, context: context, backResult: chkAdvanceComplited),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Distribuir',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
          ),
          Expanded(
            child: filteredProducts.isNotEmpty
                ? PageView.builder(
                    onPageChanged: (value) {
                      setState(() {
                        scrollIndex = pageController.page!.round();
                        controllerTwo.animateTo(
                            (35 * (scrollIndex - 5)).toDouble(),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut);
                      });
                    },
                    controller: pageController,
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return genProductsList(index);
                    },
                  )
                : const Center(
                    child: SizableCircularProgresIndicator(size: 50)),
          ),
          Scrollbar(
            controller: controllerTwo,
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                controller: controllerTwo,
                itemCount: filteredProducts.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  filteredProducts[index]['productCompleted'] =
                      _chkIfProductCompleted(filteredProducts[index]['users']);
                  return Padding(
                    padding: const EdgeInsets.only(
                        right: 2.5, left: 2.5, top: 8, bottom: 8),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: index == scrollIndex
                              ? Colors.blueGrey
                              : Colors.blueGrey[100],
                        ),
                        width: 30,
                        child: GestureDetector(
                            onTap: () {
                              scrollIndex = index;
                              _scroll();
                            },
                            child: filteredProducts[index]['productCompleted']
                                ? Icon(
                                    Icons.check,
                                    color: Colors.blueGrey[800],
                                  )
                                : null)),
                  );
                },
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.blueGrey, Colors.black],
                stops: [0.0, 0.95])),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              FloatingActionButton(
                heroTag: 1,
                backgroundColor: Colors.blue,
                onPressed: () => _nextCard(-1),
                child: const Icon(Icons.arrow_back_ios),
              ),
              const Expanded(child: SizedBox()),
              FloatingActionButton(
                heroTag: 2,
                backgroundColor: Colors.blue,
                onPressed: () => _nextCard(1),
                child: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _fetchOrdersAndFilter() async {
    filteredProducts = await _productsFilter();
    setState(() {
      filteredProducts;
    });
  }

  Future<List<Map<String, dynamic>>> _productsFilter() async {
    List<Map<String, dynamic>> fProducts = [];
    List? record = Repo().localStorage.getLocalItem('dealOut');
    if (record != null) {
      List<Map<String, dynamic>> saved = record.map((e) {
        List users = e['users'];
        Map<String, dynamic> item = {
          'product': e['product'] is String
              ? ProductModel.fromJson(jsonDecode(e['product']))
              : e['product'],
          'users': users.map((el) => el as Map<String, dynamic>).toList()
        };
        return item;
      }).toList();

      return saved;
    }
    List<OrdersModel> orders = await Repo().orders.getOrderssApi();
    for (ProductModel p in widget.products) {
      if (p.availability!) {
        Map<String, dynamic> item = {
          'product': p,
          'users': <Map<String, dynamic>>[],
          'productCompleted': false
        };
        for (OrdersModel oneUserOrder in orders) {
          int productQty = oneUserOrder.orderList!
              .firstWhere((e) => e[0] == p.id, orElse: () => [0, 0])[1];
          if (productQty > 0) {
            UserModel? user = getUserInfoById(oneUserOrder.userId!);
            item['users'].add({
              'userName': user.name,
              'qty': productQty,
              'completed': false,
              'img': user.imageFile!.path
            });
          }
        }
        if (item['users'].length > 0) {
          fProducts.add(item);
        }
      }
    }
    fProducts
        .sort((a, b) => a['product'].priority.compareTo(b['product'].priority));
    return fProducts;
  }

  UserModel getUserInfoById(int id) {
    return widget.users
        .firstWhere((u) => u.id == id, orElse: () => UserModel());
  }

  void _nextCard(int inc) {
    scrollIndex += inc;
    scrollIndex = scrollIndex < 0 || scrollIndex > filteredProducts.length - 1
        ? scrollIndex -= inc
        : scrollIndex;
    _scroll();
  }

  _scroll() {
    pageController.animateTo(MediaQuery.of(context).size.width * scrollIndex,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    setState(() {
      pageController;
    });
  }

  Widget genProductsList(int i) {
    Map<String, dynamic> item = filteredProducts[i];
    ProductModel p = item['product'];
    filteredProducts[i]['productCompleted'] =
        _chkIfProductCompleted(item['users']);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
        child: Card(
          elevation: 15,
          color: _getCardColor(item['users']),
          child: ListTile(
            title: Row(
              children: [
                Text(
                  p.name!,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (filteredProducts[i]['productCompleted'])
                  const Icon(Icons.check)
              ],
            ),
            subtitle: ListView(children: _usersForThisProduct(item)),
          ),
        ),
      ),
    );
  }

  List<Widget> _usersForThisProduct(Map<String, dynamic> item) {
    Divider div = const Divider(color: Colors.black);
    List<Widget> lstItems = [];
    List<Map<String, dynamic>> usersLst = item['users'];
    ProductModel product = item['product'];
    lstItems.add(div);
    for (int i = 0; i < usersLst.length; i++) {
      String user = usersLst[i]['userName'];
      int qty = usersLst[i]['qty'];
      String unit = product.unit!;
      File img = File(usersLst[i]['img']);
      lstItems.add(ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(60 / 2),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: FileImage(img),
              )),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 5),
        title: Text(
          '$user: $qty $unit',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        iconColor: usersLst[i]['completed']
            ? Colors.blueGrey[700]
            : const Color.fromARGB(255, 255, 17, 0),
        trailing: usersLst[i]['completed']
            ? const Icon(Icons.task_alt_rounded)
            : const Icon(Icons.cancel),
        onTap: () async {
          usersLst[i]['completed'] = !usersLst[i]['completed'];
          await Repo().localStorage.setLocalItem('dealOut', filteredProducts);
          setState(() {
            filteredProducts;
          });
        },
      ));
      lstItems.add(div);
    }
    return lstItems;
  }

  bool _chkIfProductCompleted(List<Map<String, dynamic>> users) {
    List<Map<String, dynamic>> notCompleted =
        users.where((e) => e['completed'] == false).toList();
    return notCompleted.isEmpty ? true : false;
  }

  Color _getCardColor(List<Map<String, dynamic>> users) {
    return _chkIfProductCompleted(users)
        ? Colors.blueGrey[100]!
        : const Color.fromARGB(255, 255, 255, 255);
  }

  chkAdvanceComplited() {
    int counter = 0;
    for (var i in filteredProducts) {
      counter += i['productCompleted'] ? 1 : 0;
    }
    if (counter == filteredProducts.length) {
      Repo().localStorage.deleteLocalItem('dealOut');
    }
  }
}
