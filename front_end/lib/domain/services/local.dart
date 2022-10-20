import 'package:greengrocery/domain/services/local_env.dart';
import 'package:localstorage/localstorage.dart';

class RepoLocal {
  final LocalStorage _ls = LocalStorage('greengrocery.local');
  Map get localEnvData => LocalEnv.data;
  Map<String, dynamic>? userLogged;

  bool _lsReady = false;
  bool get localStorageReady => _lsReady;

  Future<bool> init() async {
    await _ls.ready;
    await LocalEnv.readData();
    _lsReady = true;
    return _lsReady;
  }

  dynamic get(String key) {
    return _ls.getItem(key);
  }

  Future<void> set(String key, dynamic value) async {
    await _ls.setItem(key, value);
  }

  Map<String, dynamic> getLocalUser() {
    userLogged = _ls.getItem('userLogged');
    return userLogged == null
        ? {'name': null, 'id': null}
        : userLogged as Map<String, dynamic>;
  }

  Future<bool> saveLocalUser(Map<String, dynamic> user) async {
    await _ls.setItem('userLogged', user);
    return true;
  }

  deleteItem(key) async {
    await _ls.deleteItem(key);
  }

  deleteLocalUser() async {
    await deleteItem('userLogged');
  }

  getLocalItem(String key) => get(key);

  Future<void> setLocalItem(String key, dynamic data) => set(key, data);

  deleteLocalItem(String key) => deleteItem(key);
}
