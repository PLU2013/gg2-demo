import 'package:greengrocery/domain/models/product_model.dart';

class UserOrderModel {
  ProductModel? product;
  String? orderId;
  int? userId;

  UserOrderModel({this.product, this.orderId, this.userId});
}
