import 'package:greengrocery/domain/repo/repo.dart';
import 'package:greengrocery/domain/services/http_api.dart';
import 'package:greengrocery/domain/models/user_model.dart';
import 'package:greengrocery/ui/pages/commons/imgs_class.dart';

class UsersService {
  Future<List<UserModel>> getUsersApi(String userLogged) async {
    List<UserModel> usersList = [];
    List apiResponse = await HttpApi(path: 'users').get();
    if (apiResponse.isNotEmpty) {
      for (Map<String, dynamic> user in apiResponse) {
        UserModel itemUser = UserModel.fromJson(user, userLogged);
        itemUser.imageFile =
            await UsersImgs.getLocalFilePath(itemUser.name, itemUser.imageUrl);
        usersList.add(itemUser);
      }
    }
    return usersList;
  }

  Future setOrderReady(Map<String, dynamic> data2Send) async {
    return await Repo().webSocket.setOrderReady(data2Send);
  }

  clearAllOrderReady() async {
    return await HttpApi(path: 'users/clearAllOrderReady').put(body: {});
  }

  Future<List<UserModel>> getUsersList() async {
    List<UserModel> usersList = [];
    List response = await HttpApi(path: 'users/nameUser').get();
    if (response.isNotEmpty) {
      for (Map<String, dynamic> userMap in response) {
        UserModel user = UserModel.fromJson(userMap, null);
        usersList.add(user);
      }
    }
    return usersList;
  }

  setUserField(UserModel user, String fieldToChange) {
    Map<String, dynamic> userMap = user.toMap();
    Map<String, dynamic> body = {fieldToChange: userMap[fieldToChange]};
    return userMap.containsKey(fieldToChange)
        ? HttpApi(path: 'users/updateUser', id: user.id.toString())
            .put(body: body)
        : false;
  }

  sendBroadcast(
      {required String from, String? to, required String message}) async {
    Map<String, dynamic> body = {'from': from, 'to': to, 'message': message};
    return await HttpApi(path: 'users/broadcast').post2(body);
  }
}
