import 'package:greengrocery/domain/models/product_model.dart';
import 'package:greengrocery/domain/models/user_model.dart';

class DealOutModel {
  UserModel? user;
  List<ProductModel>? productList;
  bool? completed;
  double? total;

  DealOutModel.create(
      {this.user,
      required List rawList,
      required List<ProductModel> allProductsList}) {
    productList = [];
    total = 0;
    for (List item in rawList) {
      ProductModel product = ProductModel.fromJson(
          allProductsList.firstWhere((p) => p.id == item[0]).toMap());
      if (product.availability!) {
        product.auxQty = item[1];
        product.checked = false;
        total = total! + (product.price! * product.auxQty!);
        productList!.add(product);
      }
    }
    productList!.sort((a, b) => a.priority!.compareTo(b.priority!));
  }
}
