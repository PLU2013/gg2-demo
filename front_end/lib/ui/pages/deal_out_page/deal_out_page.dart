import 'package:flutter/material.dart';
import 'package:greengrocery/domain/models/deal_out_model.dart';
import 'package:greengrocery/domain/models/order_model.dart';
import 'package:greengrocery/domain/models/product_model.dart';
import 'package:greengrocery/domain/models/user_model.dart';
import 'package:greengrocery/domain/repo/repo.dart';
import 'package:greengrocery/ui/pages/commons/commons.dart';

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
  List<DealOutModel> orders = [];
  Map<String, List>? local;

  @override
  void initState() {
    _getUserOrders();
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
            child: orders.isNotEmpty
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
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return genProductsList(index);
                    },
                  )
                : const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                  ),
          ),
          Scrollbar(
            controller: controllerTwo,
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                controller: controllerTwo,
                itemCount: orders.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  orders[index].completed = _chkIfCompleted(orders[index]);
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
                            child: orders[index].completed!
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

  UserModel getUserInfoById(int id) {
    return widget.users
        .firstWhere((u) => u.id == id, orElse: () => UserModel());
  }

  void _nextCard(int inc) {
    scrollIndex += inc;
    scrollIndex = scrollIndex < 0 || scrollIndex > orders.length - 1
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
    DealOutModel item = orders[i];
    item.completed = _chkIfCompleted(item);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
        child: Card(
          elevation: 15,
          color: _getCardColor(item.completed!),
          child: Column(
            children: [
              ListTile(
                  leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50 / 2),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(item.user!.imageFile!)))),
                  title: Row(
                    children: [
                      Center(
                        child: Text(
                          item.user!.name!,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (item.completed!) const Icon(Icons.check)
                    ],
                  ),
                  subtitle: Text(
                    'Total: \$${item.total!.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
              Expanded(child: ListView(children: _productsForThisUser(item)))
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _productsForThisUser(DealOutModel item) {
    Divider div = const Divider(color: Colors.black);
    List<Widget> lstItems = [];

    lstItems.add(div);
    for (int i = 0; i < item.productList!.length; i++) {
      String productName = item.productList![i].name!;
      int qty = item.productList![i].auxQty!;
      String unit = item.productList![i].unit!;
      lstItems.add(ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 5),
        title: Text(
          '$productName: $qty $unit',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        iconColor: item.productList![i].checked!
            ? Colors.blueGrey[700]
            : const Color.fromARGB(255, 255, 17, 0),
        trailing: item.productList![i].checked!
            ? const Icon(Icons.task_alt_rounded)
            : const Icon(Icons.cancel),
        onTap: () async {
          item.productList![i].checked = !item.productList![i].checked!;
          local![item.user!.name!] ??= [];
          int exist = local![item.user!.name!]!
              .indexWhere((e) => e[0] == item.productList![i].id);
          if (exist != -1) {
            local![item.user!.name!]!.removeAt(exist);
          }
          if (item.productList![i].checked!) {
            local![item.user!.name!]!
                .add([item.productList![i].id, item.productList![i].checked]);
          }
          await Repo().localStorage.setLocalItem('dealOut', local);
          setState(() {
            orders;
          });
        },
      ));
      lstItems.add(div);
    }
    return lstItems;
  }

  bool _chkIfCompleted(DealOutModel item) {
    List<ProductModel> notCompleted =
        item.productList!.where((e) => e.checked == false).toList();
    return notCompleted.isEmpty ? true : false;
  }

  Color _getCardColor(bool completed) {
    return completed
        ? Colors.blueGrey[100]!
        : const Color.fromARGB(255, 255, 255, 255);
  }

  chkAdvanceComplited() {
    int counter = 0;
    for (var i in orders) {
      counter += i.completed! ? 1 : 0;
    }
    if (counter == orders.length) {
      Repo().localStorage.deleteLocalItem('dealOut');
    }
  }

  _getUserOrders() async {
    List<OrdersModel> totalOrders = await Repo().orders.getOrderssApi();
    for (UserModel user in widget.users) {
      OrdersModel userOrder =
          totalOrders.firstWhere((order) => order.userId == user.id);
      DealOutModel order = DealOutModel.create(
          user: user,
          rawList: userOrder.orderList!,
          allProductsList: widget.products);

      orders.add(order);
    }
    Map<String, dynamic>? aux = Repo().localStorage.getLocalItem('dealOut');

    aux ??= {};

    local = {};

    aux.forEach((key, value) {
      local![key] = value;
    });

    if (local != {}) _updateOrderStatus();

    setState(() {
      orders;
    });
  }

  _updateOrderStatus() {
    for (UserModel user in widget.users) {
      if (local![user.name] != null) {
        List userProductsChecked = local![user.name]!;
        DealOutModel userOrder =
            orders.firstWhere((e) => e.user!.name == user.name);
        for (List p in userProductsChecked) {
          ProductModel userProduct = userOrder.productList!.firstWhere(
              (product) => product.id == p[0],
              orElse: () => ProductModel());
          if (userProduct.name != null) {
            userProduct.checked = p[1];
          }
        }
      }
    }
    setState(() {
      orders;
    });
  }
}
