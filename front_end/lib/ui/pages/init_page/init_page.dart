import 'package:flutter/material.dart';
import 'package:greengrocery/domain/models/product_model.dart';
import 'package:greengrocery/domain/repo/repo.dart';
import 'package:greengrocery/domain/models/user_model.dart';
import 'package:greengrocery/ui/pages/buyer_page/buyer_page.dart';
import 'package:greengrocery/ui/pages/home_page/home_page.dart';
import 'package:greengrocery/ui/pages/login_page/login_page.dart';

class Init extends StatefulWidget {
  const Init({Key? key}) : super(key: key);

  @override
  State<Init> createState() => _InitState();
}

class _InitState extends State<Init> {
  String txt = 'Start...';
  List<UserModel> u = [];
  List<ProductModel> p = [];

  @override
  void initState() {
    super.initState();
    initProcess();
  }

  ///Initialization process.
  ///Gets local user. if null shows the LoginPage.
  ///Check if purchasing process is initiated. If yes shows the PurchasingPage (buyer_page);
  ///Init websocket
  ///Gets users and products
  ///Show the HomePage.
  initProcess() async {
    setState(() {
      txt = 'Get Local User...';
    });

    await Future.delayed(Duration.zero, () {});

    Map<String, dynamic> localUser = Repo().localStorage.getLocalUser();
    bool purchasingInitiated =
        (Repo().localStorage.getLocalItem('purchasingState')) ?? false;

    UserModel user = UserModel();

    if (localUser['name'] == null) {
      _go(const Login());
    } else {
      if (purchasingInitiated) {
        _go(ToBuy(products: p, users: u));
      } else {
        setState(() {
          txt = localUser['name'];
        });
        user.id = localUser['id'];
        user.name = localUser['name'];
        setState(() {
          txt = 'Socket INIT...';
        });
        Repo().webSocket.init(user);
        setState(() {
          txt = 'Socket Connecting';
        });
        await Repo().webSocket.connect().catchError((err) {
          setState(() {
            txt = 'Socket connction ERROR';
          });
        });
        setState(() {
          txt = 'Connected, get users and products';
        });

        List queriesResponse = await Repo().getUsersAndProducts(user.name!);

        late List<UserModel> users;
        late List<ProductModel> products;

        if (queriesResponse[0].isEmpty || queriesResponse[1].isEmpty) {
          setState(() {
            txt = 'Error de acceso...';
          });
        } else {
          users = queriesResponse[0] as List<UserModel>;
          products = queriesResponse[1] as List<ProductModel>;

          setState(() {
            txt = 'Users and Products, OK';
          });
        }
        if (txt == 'Users and Products, OK') {
          _go(HomePage(user.name!, users, products));
        }
      }
    }
  }

  _go(page) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('lib/images/img_init.jpg'),
              fit: BoxFit.fitHeight)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 30),
            Text(
              txt,
              style: const TextStyle(backgroundColor: Colors.white),
            )
          ],
        ),
      ),
    ));
  }
}
