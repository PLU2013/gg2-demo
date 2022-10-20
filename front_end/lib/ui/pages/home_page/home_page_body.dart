import 'package:flutter/material.dart';
import 'package:greengrocery/domain/models/user_model.dart';

/// Group of widget for the body home page.
class HomePageBody extends StatelessWidget {
  const HomePageBody(
      {required this.users, required this.navigateToUserPage, Key? key})
      : super(key: key);

  final List<UserModel> users;
  final Function navigateToUserPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lista de Usuarios',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) => userItemList(
                  context: context,
                  i: index,
                  onTap: navigateToUserPage,
                  userList: users)),
        ),
      ],
    );
  }

  Widget userItemList(
      {required List<UserModel> userList,
      required int i,
      required Function onTap,
      required BuildContext context}) {
    UserModel user = userList[i];

    String emogi;
    if (user.orderReady!) {
      emogi = '✔';
    } else if (user.online!) {
      emogi = '😕';
    } else {
      emogi = '😴';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 8, top: 5),
      child: Card(
        color: const Color.fromARGB(255, 255, 255, 255),
        elevation: 5,
        child: ListTile(
          onTap: () => onTap(i, context),
          title: Row(
            children: <Widget>[
              const SizedBox(
                width: 10,
              ),
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(60 / 2),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(user.imageFile!),
                        )),
                  ),
                  if (user.online!)
                    const Icon(
                      Icons.circle,
                      size: 15,
                      color: Colors.green,
                    ),
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                user.name!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    emogi,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
