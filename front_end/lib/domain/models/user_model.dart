import 'dart:io';

class UserModel {
  int? id;
  String? name;
  String? email;
  String? imageUrl;
  File? imageFile;
  String? idLastOrder;
  bool? orderReady;
  bool? online;
  String? aliasOf;
  bool? userLogged;

  UserModel(
      {this.id,
      this.name,
      this.email,
      this.imageUrl,
      this.idLastOrder,
      this.orderReady,
      this.online,
      this.aliasOf,
      this.userLogged,
      this.imageFile});

  UserModel.fromJson(Map<String, dynamic> json, String? userLoggedName) {
    id = json['idUser'];
    name = json['nameUser'];
    email = json['email'];
    imageUrl = json['image'];
    idLastOrder = json['idLastOrder'];
    orderReady = json['orderReady'];
    imageFile = null;
    online = json['online'];
    aliasOf = '';
    userLogged = userLoggedName == name;
  }

  UserModel.fromMap(Map<String, dynamic> userMp) {
    id = userMp['id'];
    name = userMp['name'];
    email = userMp['email'];
    imageUrl = userMp['image'];
    idLastOrder = userMp['idLastOrder'];
    orderReady = userMp['orderReady'];
    imageFile = File(userMp['imageFile']);
    online = userMp['online'];
    userLogged = userMp['userLogged'];
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['image'] = imageUrl;
    data['idLastOrder'] = idLastOrder;
    data['orderReady'] = orderReady;
    data['online'] = online;
    data['imageFile'] = imageFile!.path;
    data['userLogged'] = userLogged;
    return data;
  }
}
