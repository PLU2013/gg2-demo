import 'package:flutter/material.dart';
import 'package:greengrocery/domain/models/user_model.dart';
import 'package:greengrocery/domain/models/user_order_model.dart';

typedef ReturnFn = void Function(bool value);

class UserPageHeader extends StatelessWidget {
  const UserPageHeader(
      {required this.user,
      required this.userLogged,
      required this.onChange,
      required this.upadateOrderReady,
      required this.order,
      Key? key})
      : super(key: key);

  final UserModel user;
  final String userLogged;
  final ReturnFn onChange;
  final ReturnFn upadateOrderReady;
  final List<UserOrderModel> order;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 10,
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user.name!,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    )),
              ),
              const Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Pedido listo'))),
              OrderReadySwitch(
                  user: user,
                  userLogged: userLogged,
                  onChange: onChange,
                  upadateOrderReady: upadateOrderReady)
            ],
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(user.imageFile!),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pedido:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                        'Total aprox.: \$${order.fold<double>(0, (previousValue, e) => previousValue + e.product!.auxQty! * e.product!.price!).toStringAsFixed(2)}'),
                  ),
                  const Divider(
                    height: 0,
                    color: Colors.black26,
                    endIndent: 0,
                    thickness: 2,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrderReadySwitch extends StatefulWidget {
  const OrderReadySwitch(
      {required this.user,
      required this.userLogged,
      required this.onChange,
      required this.upadateOrderReady,
      Key? key})
      : super(key: key);

  final UserModel user;
  final String userLogged;
  final ReturnFn onChange;
  final ReturnFn upadateOrderReady;

  @override
  State<OrderReadySwitch> createState() => _OrderReadySwitchState();
}

class _OrderReadySwitchState extends State<OrderReadySwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch(
        value: widget.user.orderReady!,
        onChanged: (widget.userLogged == widget.user.name &&
                    !widget.user.orderReady!) ||
                widget.userLogged == 'Sergio'
            ? (value) => setState(() {
                  widget.user.orderReady = value;
                  if (widget.userLogged != 'Sergio') {
                    widget.onChange(value);
                  } else {
                    widget.upadateOrderReady(value);
                  }
                })
            : null);
  }
}
