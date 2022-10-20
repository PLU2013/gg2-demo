import 'dart:convert';

import 'package:greengrocery/domain/services/local_env.dart';
import 'package:http/http.dart' as http;

final Map env = LocalEnv.data;

class HttpApi {
  static final String _baseUrl = '${env['SERVER_URL']}/api/';
  //'https://greengrocery-backend.herokuapp.com/api/';
  String path;
  String? id;
  String url;

  HttpApi({required this.path, this.id})
      : url = '$_baseUrl$path${id == null ? "" : "/$id"}';

  Future<List> get() async {
    try {
      final http.Response response = await http.get(Uri.parse(url));
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (err) {
      return [];
    }
  }

  Future<bool> put({required Map<String, dynamic> body}) async {
    final http.Response response = await http.put(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
    return response.statusCode == 200 ? true : false;
  }

  Future<bool> delete() async {
    final http.Response response = await http.delete(Uri.parse(url));
    return response.statusCode == 200 ? true : false;
  }

  Future<bool> post(List<Map<String, dynamic>> body) async {
    final http.Response response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
    return response.statusCode == 200 ? true : false;
  }

  Future<bool> post2(Map<String, dynamic> body) async {
    final http.Response response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
    return response.statusCode == 200 ? true : false;
  }
}
