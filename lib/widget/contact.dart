import 'package:flutter/material.dart';
import 'package:ptncenter/scaffold/map.dart';

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
          // color: Color.fromRGBO(235, 254, 255, 1.0),
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
                  'คลังสินค้า พัฒนาเภสัช',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
                spaceBox(),
                Text(
                  ' 159/1 ม .4 นครสวรรค์ตก',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),Text(
                  ' อำเภอเมืองนครสวรรค์ จ.นครสวรรค์ 60000',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
                spaceBox(),
                Text(
                  ' โทร 056-345625 มือถือ 081-9164131',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
                spaceBox(),
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  // height: 80.0,
                  child: GestureDetector(
                    child: Card(
                      // color: Colors.green.shade100,
                      child: Container(
                        // padding: EdgeInsets.all(16.0),
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 150.0,
                              child: Image.asset('images/icon_googlemap.jpg'),
                            ),
                            
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      print('You click cart');
                      MaterialPageRoute materialPageRoute =
                                    MaterialPageRoute(builder: (BuildContext buildContext) {
                                  return HomePage();
                                });
                                Navigator.of(context).push(materialPageRoute);
                    },
                  ),
                ),               
                spaceBox(),
                spaceBox(),
                spaceBox(),
                Text(
                  'บริษัท พี ที เอ็น ฟาร์มาเซ็นเตอร์ จำกัด',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
                spaceBox(),
                Text(
                  '919/30 ม.10 ถ.พหลโยธิน ต.นครสวรรค์ตก',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),Text(
                  'อ.เมือง จ.นครสวรรค์ 60000',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
                spaceBox(),
                Text(
                  ' โทร 056-371370  มือถือ  092-0319999 ',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(0xff, 0, 0, 0),
                  ),
                ),
                spaceBox(),
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  // height: 80.0,
                  child: GestureDetector(
                    child: Card(
                      // color: Colors.green.shade100,
                      child: Container(
                        // padding: EdgeInsets.all(16.0),
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 150.0,
                              child: Image.asset('images/icon_googlemap.jpg'),
                            ),
                            
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      print('You click cart');
                      MaterialPageRoute materialPageRoute =
                                    MaterialPageRoute(builder: (BuildContext buildContext) {
                                  return HomePage();
                                });
                                Navigator.of(context).push(materialPageRoute);
                    },
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
