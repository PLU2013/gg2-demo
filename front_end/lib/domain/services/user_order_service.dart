import 'package:greengrocery/domain/repo/repo.dart';
import 'package:greengrocery/domain/models/user_order_model.dart';
import 'package:greengrocery/domain/models/product_model.dart';

class UserOrderService {
  ///Gets a order list for one user.
  ///Params [id] => orderId, [productList] => product list to parse final order
  Future<List<UserOrderModel>> getOrderById(String id, List productList) async {
    Map jsonOrder = await Repo().webSocket.getOrderById(id);
    return _parseFinalOrder(jsonOrder, productList);
  }

  ///Create the order to show in the user page
  List<UserOrderModel> _parseFinalOrder(Map jsonOrder, List productList) {
    List<UserOrderModel> finalOrder = [];
    if (jsonOrder['message'] == 'NO CONTENT') return finalOrder;
    List rawOrder = jsonOrder['listOrder'];
    for (List element in rawOrder) {
      UserOrderModel item = UserOrderModel();
      ProductModel? product = productList.firstWhere((p) => p.id == element[0],
          orElse: () => ProductModel());
      if (product!.name != null) {
        if (product.availability!) {
          item.product = product;
          item.userId = jsonOrder['idUser'];
          item.product!.auxQty = element[1];
          //item.qty = element[1];
          finalOrder.add(item);
        }
      }
    }
    finalOrder.sort(((a, b) => a.product!.name!.compareTo(b.product!.name!)));
    return finalOrder;
  }

  ///Save an order in the server
  ///Params [order] the edited user order, [orderId] order id.
  Future<bool> putOrderById(List<UserOrderModel> order, String orderId) async {
    List rawOrder = [];
    for (UserOrderModel e in order) {
      rawOrder.add([e.product!.id, e.product!.auxQty]);
    }
    Map res = await Repo()
        .webSocket
        .putOrderById({"id": orderId, "listOrder": rawOrder});
    if (res['message'] == 'OK!') {
      return true;
    }
    return false;
  }
}
