import 'package:greengrocery/domain/services/http_api.dart';
import 'package:greengrocery/domain/models/product_model.dart';

class ProductsService {
  Future<List<ProductModel>> getProductsApi() async {
    List response = await HttpApi(path: 'products').get();
    List<ProductModel> productsList = [];
    if (response.isNotEmpty) {
      response.removeAt(0);

      for (Map<String, dynamic> key in response) {
        ProductModel item = ProductModel.fromJson(key);
        productsList.add(item);
      }
      productsList.sort((a, b) => a.name!.compareTo(b.name!));
    }
    return productsList;
  }

  Future<bool> putProductField(
      ProductModel product, String fieldtoChange) async {
    Map<String, dynamic> productMap = product.toMap();
    Map<String, dynamic> body = {fieldtoChange: productMap[fieldtoChange]};
    return productMap.containsKey(fieldtoChange)
        ? await HttpApi(
                path: 'products/updateProduct', id: product.id.toString())
            .put(body: body)
        : false;
  }

  Future<bool> newProduct(ProductModel product) async {
    Map<String, dynamic> body = product.toMap();
    return await HttpApi(path: 'products/new').put(body: body);
  }

  Future<bool> deleteProduct(int productId) async =>
      await HttpApi(path: 'products/delete', id: productId.toString()).delete();

  ///Recive a product list. List<Map<String, dynamic>>
  ///Each product in the list must contain its [productId]
  ///and its fields to be update. Ex: [price].
  ///Return true if update was OK and false when there was errors.
  Future<bool> updateProductsMany(
      List<Map<String, dynamic>> produts2Update) async {
    return await HttpApi(path: 'products/updateMany').post(produts2Update);
  }
}
