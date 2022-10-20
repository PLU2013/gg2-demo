import 'package:greengrocery/domain/services/local_env.dart';
import 'package:localstorage/localstorage.dart';

///Local storage management.
class RepoLocal {
  final LocalStorage _ls = LocalStorage('greengrocery.local');
  Map get localEnvData => LocalEnv.data;
  Map<String, dynamic>? userLogged;

  bool _lsReady = false;

  ///Local storage status ready getter
  bool get localStorageReady => _lsReady;

  ///LocalStorage initialization.
  Future<bool> init() async {
    await _ls.ready;
    await LocalEnv.readData();
    _lsReady = true;
    return _lsReady;
  }

  ///Gets a [key] from local storage.
  dynamic _get(String key) {
    return _ls.getItem(key);
  }

  ///Sets a [key] [value] to local storage.
  Future<void> _set(String key, dynamic value) async {
    await _ls.setItem(key, value);
  }

  ///Gets local user stored in local storage.
  ///If there isn't a user logged then resturns => {'name': null, 'id': null}
  Map<String, dynamic> getLocalUser() {
    userLogged = _ls.getItem('userLogged');
    return userLogged == null
        ? {'name': null, 'id': null}
        : userLogged as Map<String, dynamic>;
  }

  ///Saves a local [user] to the local storage.
  Future<bool> saveLocalUser(Map<String, dynamic> user) async {
    await _ls.setItem('userLogged', user);
    return true;
  }

  ///Deletes a [key] from local storage
  _deleteItem(key) async {
    await _ls.deleteItem(key);
  }

  ///Deletes the local user from local storage
  deleteLocalUser() async {
    await _deleteItem('userLogged');
  }

  ///Getter gets local key
  getLocalItem(String key) => _get(key);

  ///Setter Sets local key
  Future<void> setLocalItem(String key, dynamic data) => _set(key, data);

  ///Getter deletes local key
  deleteLocalItem(String key) => _deleteItem(key);
}
