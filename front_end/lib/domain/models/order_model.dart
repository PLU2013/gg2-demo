class OrdersModel {
  String? id;
  int? userId;
  List<dynamic>? orderList;

  OrdersModel({
    this.id,
    this.userId,
    this.orderList,
  });

  OrdersModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    userId = json['idUser'];
    orderList = json['listOrder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['idUser'] = userId;
    data['listOrder'] = orderList;
    return data;
  }
}
