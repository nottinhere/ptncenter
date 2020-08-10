import 'package:flutter/material.dart';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  @override
   Widget spaceBox() {
    return SizedBox(
      width: 10.0,
      height: 16.0,
    );
  }
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: Color.fromRGBO(235, 254, 255, 1.0),
          child: Container(
            padding: EdgeInsets.only(bottom: 15.0, top: 15.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Contact',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
                spaceBox(),
                Text(
                  'PTN CENTER ต.นครสวรรค์ตก',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
                spaceBox(),
                Text(
                  'อ.เมือง จ.นครสวรรค์ 60000',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
                spaceBox(),
                Text(
                  'ติดต่อ :: 056 371 370',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}