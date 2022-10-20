import 'package:greengrocery/domain/repo/repo.dart';
import 'package:greengrocery/domain/services/http_api.dart';
import 'package:greengrocery/domain/models/user_model.dart';
import 'package:greengrocery/ui/pages/commons/imgs_class.dart';

class UsersService {
  ///Gets users list from server (API)
  ///Uses [useLogged] to conform the [UserModel].
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

  ///Sets the user order as ready (WebSocket)
  ///[data2Send] is a Map like this {"idUser": user.id, "orderReady": value}
  ///This command triggers a broadcast socket message to all online users
  ///to update theirs ui.
  Future setOrderReady(Map<String, dynamic> data2Send) async {
    return await Repo().webSocket.setOrderReady(data2Send);
  }

  ///Clears all users orrder ready field (API)
  Future<bool> clearAllOrderReady() async {
    return await HttpApi(path: 'users/clearAllOrderReady').put(body: {});
  }

  ///Gets a list of user's IDs and names as JSON (API)
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

  ///Sets the indicated field [fieldToChange]
  ///NOT USED
  setUserField(UserModel user, String fieldToChange) {
    Map<String, dynamic> userMap = user.toMap();
    Map<String, dynamic> body = {fieldToChange: userMap[fieldToChange]};
    return userMap.containsKey(fieldToChange)
        ? HttpApi(path: 'users/updateUser', id: user.id.toString())
            .put(body: body)
        : false;
  }

  ///Sends broadcast message via websocket
  ///[from] user name ?? unknown
  ///[to] user name ?? all
  Future<bool> sendBroadcast(
      {required String from, String? to, required String message}) async {
    Map<String, dynamic> body = {'from': from, 'to': to, 'message': message};
    return await HttpApi(path: 'users/broadcast').post2(body);
  }
}
