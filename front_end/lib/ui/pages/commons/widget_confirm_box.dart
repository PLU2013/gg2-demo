import 'package:flutter/material.dart';

typedef ResponseFn = Function(bool res);

class ConfirmDialogBox extends StatelessWidget {
  const ConfirmDialogBox(
      {required this.response,
      required this.icon,
      required this.cardTitle,
      required this.title,
      this.info,
      this.cancelBtn = true,
      Key? key})
      : super(key: key);

  final ResponseFn response;
  final Icon icon;
  final String cardTitle;
  final String title;
  final String? info;
  final bool cancelBtn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          width: double.maxFinite,
          height: 250,
          child: Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blueGrey[300],
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10))),
                    child: ListTile(
                      leading: icon,
                      title: Text(cardTitle,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                  if (info != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(info!,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w300)),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FloatingActionButton(
                          heroTag: 'dbHero1',
                          backgroundColor: Colors.blueGrey[300],
                          onPressed: () => response(true),
                          child: const Icon(Icons.check, color: Colors.black),
                        ),
                      ),
                      if (cancelBtn)
                        Expanded(
                          child: FloatingActionButton(
                            heroTag: 'dbHero2',
                            backgroundColor: Colors.blueGrey[300],
                            onPressed: () => response(false),
                            child: const Icon(Icons.clear, color: Colors.black),
                          ),
                        )
                    ],
                  )
                ],
              )),
        ),
      ),
    );
  }
}
