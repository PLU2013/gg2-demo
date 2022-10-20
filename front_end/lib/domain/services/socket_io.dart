import 'dart:async';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';
import 'package:greengrocery/domain/models/user_model.dart';
import 'package:greengrocery/domain/services/local_env.dart';
import 'package:socket_io_client/socket_io_client.dart';

//const webSocketServer = 'https://greengrocery.onrender.com';
//'https://greengrocery-backend.herokuapp.com';
//const webSocketServer = 'http://localhost:3000';

class Ws {
  static late Socket _socket;
  static bool _socketInitOk = false;

  static const List<String> _events = [
    'connect',
    'getAll:users',
    'getAll:products',
    'getAll:orders',
    'getById:orders',
    'updateOrder',
    'updateCampo:users'
  ];

  static Map<String, Completer> complMp = {};

  static StreamSocket streamSocket = StreamSocket();

  Socket get socket => _socket;
  bool get socketInitOk => _socketInitOk;

  init(UserModel user) {
    if (kDebugMode) {
      print('Login to Server with: ${user.name} => id ${user.id}');
    }
    final Map env = LocalEnv.data;
    final String webSocketServer = env['SERVER_URL'];
    final jwt = JWT({'userId': user.id, 'pass': env['PASS']});
    final token = jwt.sign(SecretKey(env['PRIVATE_KEY']!));

    _socket = io(webSocketServer, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.io.options['query'] = {'auth': token, 'user': user.name};

    for (String event in _events) {
      _socketEventHandler(event);
    }

    _socket.on('serverUpdateInfo', (data) {
      if (kDebugMode) {
        print('Recive from server... $data');
      }
      streamSocket.addRes(data);
    });

    _socket.onDisconnect((reason) {
      if (kDebugMode) {
        print('OFFLINE => $reason');
      }
    });

    _socket.on('connect_error', (e) {
      if (kDebugMode) {
        print('Connect Error');
      }
      if (complMp['connect'] != null) {
        complMp['connect']!.completeError('Connect Error...');
      }
      Completer completer = Completer();
      complMp['connect'] = completer;
    });

    _socket.on('error', (err) {
      if (kDebugMode) {
        print(err);
      }
    });
    _socketInitOk = true;
  }

  _socketEventHandler(String event) {
    _socket.on(event, (data) {
      if (kDebugMode) {
        print('Event => $event');
      }
      if (complMp[event] != null) {
        complMp[event]!.complete(data);
        complMp.remove(event);
      }
    });
  }

  Future _socketEventEmiter(String event, [data = const {}]) {
    Completer completer = Completer();
    complMp[event] = completer;
    if (event != 'connect') {
      _socket.emit(event, data);
    } else {
      _socket.connect();
    }
    return completer.future;
  }

  Future connect() {
    return _socketEventEmiter('connect');
  }

  disconnect() {
    _socket.disconnect();
  }

  Future getUsers() {
    return _socketEventEmiter('getAll:users');
  }

  Future getOrders() {
    return _socketEventEmiter('getAll:orders');
  }

  Future getProducts() {
    return _socketEventEmiter('getAll:products');
  }

  Future getOrderById(orderId) {
    return _socketEventEmiter('getById:orders', orderId);
  }

  Future putOrderById(data) {
    return _socketEventEmiter('updateOrder', data);
  }

  Future setOrderReady(data) {
    return _socketEventEmiter('updateCampo:users', data);
  }
}

class StreamSocket {
  static final StreamController<Map> _socketRes =
      StreamController<Map>.broadcast();

  void Function(Map) get addRes => _socketRes.sink.add;

  Stream<Map> get getRes => _socketRes.stream;

  void dispose() {
    _socketRes.close();
  }
}
