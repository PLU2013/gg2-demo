import 'package:flutter/material.dart';
import 'package:greengrocery/domain/models/user_model.dart';
import 'package:greengrocery/ui/pages/commons/sizable_circular_progress_indicator.dart';

class HomePageBottomNavBar extends StatefulWidget {
  const HomePageBottomNavBar(
      {required this.user,
      required this.userLogged,
      required this.hasToSave,
      required this.saving,
      required this.navigateToAddProductsPage,
      required this.saveChanges,
      Key? key})
      : super(key: key);

  final UserModel user;
  final String userLogged;
  final bool hasToSave;
  final bool saving;
  final Function saveChanges;
  final Function navigateToAddProductsPage;

  @override
  State<HomePageBottomNavBar> createState() => _HomePageBottomNavBarState();
}

class _HomePageBottomNavBarState extends State<HomePageBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.blueGrey, Colors.black],
              stops: [0.0, 0.9])),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 70.0, bottom: 10, top: 10),
              child: FloatingActionButton.extended(
                heroTag: 1,
                backgroundColor: widget.user.orderReady! |
                        !widget.hasToSave |
                        (!widget.user.userLogged! &
                            (widget.userLogged != 'Sergio'))
                    ? Colors.black12
                    : Colors.blue,
                onPressed: !widget.user.orderReady! &
                        widget.hasToSave &
                        (widget.user.userLogged! |
                            (widget.userLogged == 'Sergio'))
                    ? () => widget.saveChanges()
                    : null,
                label: Row(
                  children: [
                    const Text('Guardar'),
                    const SizedBox(
                      width: 20,
                    ),
                    if (widget.saving)
                      const SizableCircularProgresIndicator(size: 20),
                  ],
                ),
                icon: const Icon(Icons.save_rounded, size: 36),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 10, top: 10),
            child: FloatingActionButton(
              heroTag: 2,
              backgroundColor: widget.user.orderReady! |
                      (!widget.user.userLogged! &
                          (widget.userLogged != 'Sergio'))
                  ? Colors.black12
                  : Colors.blue,
              onPressed: !widget.user.orderReady! &
                      (widget.user.userLogged! |
                          (widget.userLogged == 'Sergio'))
                  ? () => widget.navigateToAddProductsPage()
                  : null,
              child: const Icon(Icons.add_shopping_cart_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
