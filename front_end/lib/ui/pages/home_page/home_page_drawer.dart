import 'package:flutter/material.dart';

///Drawer for Home page. [menuCfg] set each of items and behavior
class HomePageDrawer extends StatelessWidget {
  const HomePageDrawer(
      {required this.userLoggedName, required this.menuCfg, Key? key})
      : super(key: key);

  final String userLoggedName;
  final Function menuCfg;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 10,
      backgroundColor: const Color.fromARGB(200, 0, 0, 0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 80,
            child: DrawerHeader(
                padding: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back)),
                    const Text(
                      '🍅Greengrocery',
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                )),
          ),
          ListTile(
            leading: const Icon(Icons.person, size: 25, color: Colors.white),
            subtitle:
                const Text('online', style: TextStyle(color: Colors.white30)),
            title: Text(
              ' $userLoggedName', //widget.userLogged,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const Divider(
            color: Colors.white24,
          ),
          ..._menuItems(),
        ],
      ),
    );
  }

  List<StatelessWidget> _menuItem(
      {required String title, required Function onTap}) {
    return [
      ListTile(
        hoverColor: Colors.white12,
        title: Text(title,
            style: const TextStyle(fontSize: 20, color: Colors.white)),
        onTap: () => onTap(),
      ),
      const Divider(
        color: Colors.white24,
      )
    ];
  }

  List<StatelessWidget> _menuItems() {
    List<StatelessWidget> itemsList = [];
    for (var e in menuCfg()) {
      if (e['visibility']) {
        List<StatelessWidget> item =
            _menuItem(title: e['title'], onTap: e['funct']);
        itemsList.addAll(item);
      }
    }
    return itemsList;
  }
}
