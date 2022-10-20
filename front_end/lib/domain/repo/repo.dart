import 'package:greengrocery/domain/models/product_model.dart';
import 'package:greengrocery/domain/services/chk_connection.dart';
import 'package:greengrocery/domain/services/local.dart';
import 'package:greengrocery/domain/services/orders_service.dart';
import 'package:greengrocery/domain/services/products_service.dart';
import 'package:greengrocery/domain/services/socket_io.dart';
import 'package:greengrocery/domain/services/user_order_service.dart';
import 'package:greengrocery/domain/services/users_service.dart';

class Repo {
  UsersService users = UsersService();
  ProductsService products = ProductsService();
  OrderService orders = OrderService();
  UserOrderService userOrder = UserOrderService();
  RepoLocal localStorage = RepoLocal();
  Ws webSocket = Ws();
  StreamSocket streamSocket = StreamSocket();
  InternetConnection internetConnection = InternetConnection();

  Future<List> getUsersAndProducts(String userLogged) async {
    List<Future> apiQueries = [
      users.getUsersApi(userLogged),
      products.getProductsApi()
    ];
    List lst = await Future.wait(apiQueries);
    return lst;
  }

  Future<Map<String, List<Object>>> purchaseComplited() async {
    bool purchasePending = false;
    bool connection = await internetConnection.check();

    List totalProductsMp = localStorage.getLocalItem('totalProducts');

    List<ProductModel> totalProducts = List.generate(totalProductsMp.length,
        (i) => ProductModel.fromMap(totalProductsMp[i]));

    if (connection) {
      String userLogged = (localStorage.getLocalUser())['name'];
      List<Map<String, dynamic>> produts2Update = [];
      for (ProductModel product in totalProducts) {
        if (!product.checked! || product.edited!) {
          produts2Update.add({
            'productId': product.id,
            'price': product.price,
            'priority': product.priority,
            'availability': product.checked
          });
        }
      }
      bool apiRes = produts2Update.isNotEmpty
          ? await products.updateProductsMany(produts2Update)
          : true;
      if (apiRes) {
        apiRes = await users.clearAllOrderReady();
        await users.sendBroadcast(from: userLogged, message: 'updateProducts');
        await localStorage.deleteLocalItem('totalProducts');
        await localStorage.deleteLocalItem('updateProductsPending');
      }
    } else {
      // if not connection
      await localStorage.setLocalItem('updateProductsPending', true);
      purchasePending = true;
    }
    //Always
    await localStorage.deleteLocalItem('purchasingState');

    if (purchasePending) return {'non connection': []};

    String userLogged = (localStorage.getLocalUser())['name'];
    List up = await getUsersAndProducts(userLogged);
    return {'users': up[0], 'products': up[1]};
  }
}
