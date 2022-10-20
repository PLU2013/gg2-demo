import 'package:greengrocery/domain/services/http_api.dart';
import 'package:greengrocery/domain/models/order_model.dart';

class OrderService {
  ///Gets all users orders as List<OrderModel>
  Future<List<OrdersModel>> getOrderssApi() async {
    List jsonOrders = await HttpApi(path: 'orders').get();
    List<OrdersModel> orderLst = [];
    for (Map<String, dynamic> order in jsonOrders) {
      OrdersModel item = OrdersModel.fromJson(order);
      orderLst.add(item);
    }
    return orderLst;
  }
}
