import 'package:flutter/material.dart';
import 'package:greengrocery/ui/pages/commons/sizable_circular_progress_indicator.dart';

class MessageBox extends StatelessWidget {
  const MessageBox(
      {required this.icon,
      required this.cardTitle,
      required this.title,
      Key? key})
      : super(key: key);

  final Icon icon;
  final String cardTitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          width: double.maxFinite,
          height: 200,
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
                  const SizedBox(
                    height: 20,
                  ),
                  const SizableCircularProgresIndicator(size: 30),
                ],
              )),
        ),
      ),
    );
  }
}
