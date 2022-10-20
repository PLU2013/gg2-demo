import 'dart:convert';

class ProductModel {
  int? id;
  String? name;
  double? price;
  String? unit;
  bool? availability;
  bool? checked;
  int? auxQty;
  int? priority;
  bool? edited;

  ProductModel(
      {this.id,
      this.name,
      this.price,
      this.unit,
      this.availability,
      this.checked,
      this.auxQty,
      this.priority});

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['idProducto'] ?? json['id'];
    name = json['name'];
    price = json['price'].toDouble();
    unit = json['unit'];
    availability = json['availability'];
    priority = json['priority'];
    auxQty = 0;
    checked = false;
    edited ??= false;
  }

  String toJson() {
    final Map<String, dynamic> data = toMap();
    return jsonEncode(data);
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['unit'] = unit;
    data['availability'] = availability;
    data['priority'] = priority;
    data['auxQty'] = auxQty;
    data['checked'] = checked;
    data['edited'] = edited ?? false;
    return data;
  }

  ProductModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    price = map['price'].toDouble();
    unit = map['unit'];
    availability = map['availability'];
    priority = map['priority'];
    auxQty = map['auxQty'] ?? 0;
    checked = map['checked'] ?? false;
    edited = map['edited'] ?? false;
  }

  @override
  String toString() {
    return '''
            id: $id - 
            name: $name - 
            Qty: $auxQty - 
            Unit: $unit - 
            Price: $price - 
            Available: $availability - 
            Priority: $priority
            ''';
  }
}


//put url/api/products/updateProducts/:id