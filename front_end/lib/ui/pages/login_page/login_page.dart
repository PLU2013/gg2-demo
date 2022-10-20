import 'package:flutter/material.dart';
import 'package:greengrocery/domain/models/product_model.dart';
import 'package:greengrocery/domain/repo/repo.dart';
import 'package:greengrocery/domain/models/user_model.dart';

import '../home_page/home_page.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LogginState();
}

class _LogginState extends State<Login> {
  String selectedUser = 'Elige tu nombre!';
  late List<String> usersList;
  List<UserModel>? users;
  bool waitIndicator = true;

  @override
  void initState() {
    usersList = [selectedUser];
    fetchUsers();
    super.initState();
  }

  fetchUsers() async {
    users = await Repo().users.getUsersList();
    setState(() {
      usersList = [selectedUser, ...users!.map((e) => e.name!).toList()];
    });
    _showWaitIndicator(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('lib/images/img_init.jpg'),
                fit: BoxFit.fitHeight)),
        child: Stack(children: [
          Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: SizedBox(
              width: double.infinity,
              height: 300,
              child: Card(
                color: const Color.fromARGB(120, 0, 0, 0),
                elevation: 10,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      '¿Quien soy?',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    DropdownButton<String>(
                        iconEnabledColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        iconSize: 40,
                        dropdownColor: const Color.fromARGB(200, 0, 0, 0),
                        focusColor: const Color.fromARGB(150, 0, 0, 0),
                        borderRadius: BorderRadius.circular(10),
                        itemHeight: 50,
                        style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 255, 255, 255)),
                        elevation: 10,
                        value: selectedUser,
                        items: _usersDropdownList(),
                        onChanged: usersList.length > 1 && !waitIndicator
                            ? (String? newValue) {
                                setState(() {
                                  selectedUser = newValue!;
                                });
                              }
                            : null),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: const Color.fromARGB(150, 0, 0, 0),
                            onSurface: Colors.white),
                        onPressed: selectedUser != 'Elige tu nombre!'
                            ? () => _userLogin()
                            : null,
                        child: const SizedBox(
                            width: 150,
                            height: 50,
                            child: Center(
                                child: Text(
                              'Iniciar',
                              style: TextStyle(fontSize: 20),
                            ))))
                  ],
                ),
              ),
            ),
          )),
          if (waitIndicator) const Center(child: CircularProgressIndicator())
        ]),
      ),
    );
  }

  _showWaitIndicator(bool state) {
    setState(() {
      waitIndicator = state;
    });
  }

  void _userLogin() async {
    _showWaitIndicator(true);
    final UserModel user =
        users!.where((e) => e.name == selectedUser).toList()[0];
    await Repo().localStorage.saveLocalUser({'name': user.name, 'id': user.id});
    _navigate(user);
  }

  void _navigate(UserModel user) async {
    Repo().webSocket.init(user);
    await Repo().webSocket.connect();

    List queriesResponse = await Repo().getUsersAndProducts(user.name!);

    List<UserModel> users = queriesResponse[0];
    List<ProductModel> products = queriesResponse[1];

    _showWaitIndicator(false);

    _goToPage(users, products);
  }

  void _goToPage(List<UserModel> users, List<ProductModel> products) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(selectedUser, users, products)));
  }

  _usersDropdownList() => usersList
      .map((e) => DropdownMenuItem(
          value: e, child: SizedBox(width: 150, child: Text(e))))
      .toList();
}
