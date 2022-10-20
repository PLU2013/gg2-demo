import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greengrocery/domain/models/product_model.dart';

typedef ResponseFn = Function(bool res, ProductModel? product);

class NewProductDialogBox extends StatefulWidget {
  const NewProductDialogBox(
      {required this.response,
      required this.icon,
      required this.cardTitle,
      Key? key})
      : super(key: key);

  final ResponseFn response;
  final Icon icon;
  final String cardTitle;

  @override
  State<NewProductDialogBox> createState() => _NewProductDialogBoxState();
}

class _NewProductDialogBoxState extends State<NewProductDialogBox> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ProductModel product = ProductModel();

  @override
  void initState() {
    product.availability = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          width: double.maxFinite,
          height: 360,
          child: Card(
              child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.blueGrey[300],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: ListTile(
                  leading: widget.icon,
                  title: Text(widget.cardTitle,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          validator: (val) =>
                              val!.isValidName ? null : 'Invalid name',
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z]+|\s"))
                          ],
                          onChanged: (value) => product.name = value,
                          maxLength: 20,
                          decoration: const InputDecoration(
                              hintText: 'Nombre del producto'),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: TextFormField(
                                maxLength: 3,
                                onChanged: (value) => product.unit = value,
                                validator: (value) =>
                                    value!.isEmpty ? 'Invalid' : null,
                                decoration:
                                    const InputDecoration(hintText: 'Unidad'),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r"([0-9]|\.)"))
                                ],
                                keyboardType: TextInputType.number,
                                onChanged: (value) =>
                                    product.price = double.tryParse(value),
                                validator: (value) =>
                                    (double.tryParse(value!) ?? 0) <= 0
                                        ? 'Invalid'
                                        : null,
                                decoration:
                                    const InputDecoration(hintText: 'Precio'),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            SizedBox(
                              width: 70,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                    hintText: 'Prioridad'),
                                maxLength: 2,
                                validator: (value) =>
                                    (double.tryParse(value!) ?? 0) == 0
                                        ? 'Invalid'
                                        : null,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r"[0-9]", dotAll: false))
                                ],
                                keyboardType: TextInputType.number,
                                onChanged: (value) =>
                                    product.priority = int.tryParse(value),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                                value: product.availability,
                                onChanged: (value) => setState(() {
                                      product.availability = value;
                                    })),
                            const Text('Disponibilidad')
                          ],
                        )
                      ],
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: FloatingActionButton(
                        heroTag: 'dbHero1',
                        backgroundColor: Colors.blueGrey[300],
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.response(true, product);
                          }
                        },
                        child: const Icon(Icons.check, color: Colors.black),
                      ),
                    ),
                    Expanded(
                      child: FloatingActionButton(
                        heroTag: 'dbHero2',
                        backgroundColor: Colors.blueGrey[300],
                        onPressed: () => widget.response(false, null),
                        child: const Icon(Icons.clear, color: Colors.black),
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
        ),
      ),
    );
  }
}

extension on String {
  bool get isValidName {
    final regExp = RegExp(r'[^\n\r]{4,}', caseSensitive: false);
    return regExp.hasMatch(this);
  }
}
