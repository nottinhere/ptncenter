import 'package:flutter/material.dart';
import 'package:ptncenter/scaffold/map.dart';
import 'package:ptncenter/utility/my_style.dart';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  Widget sectionHeader(IconData iconData, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: <Widget>[
          Icon(iconData, size: 20.0, color: MyStyle().textColor),
          SizedBox(width: 8.0),
          Text(title, style: MyStyle().sectionTitleStyle),
        ],
      ),
    );
  }

  Widget sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MyStyle().radiusM),
        border: Border.all(color: MyStyle().borderColor),
      ),
      child: child,
    );
  }

  Widget infoRow(IconData iconData, String text, {double topPadding = 8.0}) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(iconData, size: 16.0, color: MyStyle().mutedTextColor),
          SizedBox(width: 8.0),
          Expanded(child: Text(text, style: MyStyle().h4StyleGray)),
        ],
      ),
    );
  }

  Widget branchCard({
    required String name,
    required List<String> addressLines,
    required String phone,
    required String hours,
  }) {
    return sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(name, style: MyStyle().h3bStyle),
          for (final line in addressLines) infoRow(Icons.location_on_outlined, line),
          infoRow(Icons.call_outlined, phone),
          infoRow(Icons.access_time, hours),
        ],
      ),
    );
  }

  Widget headerCard() {
    return sectionCard(
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 26.0,
            backgroundColor: MyStyle().primaryLight,
            child: Icon(Icons.storefront_rounded,
                color: MyStyle().mainColor, size: 26.0),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'บริษัท พี ที เอ็น ฟาร์มาเซ็นเตอร์ จำกัด',
                  style: MyStyle().h3bStyle,
                ),
                SizedBox(height: 2.0),
                Text('ติดต่อเรา', style: MyStyle().captionStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mapCard() {
    return GestureDetector(
      onTap: () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return HomePage();
        });
        Navigator.of(context).push(materialPageRoute);
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MyStyle().radiusM),
          border: Border.all(color: MyStyle().borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: <Widget>[
            Image.asset(
              'images/icon_googlemap.jpg',
              width: 72.0,
              height: 72.0,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Text('ดูตำแหน่งบน Google Maps', style: MyStyle().h4bStyleGray),
            ),
            Icon(Icons.chevron_right, color: MyStyle().mutedTextColor),
            SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }

  Widget socialTile({
    required String iconAsset,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MyStyle().radiusS),
        border: Border.all(color: MyStyle().borderColor),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: MyStyle().primaryLight,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(7.0),
            child: Image.asset(iconAsset, fit: BoxFit.contain),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Text(
              label,
              style: MyStyle().h4StyleGray,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyStyle().scaffoldBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            headerCard(),
            sectionHeader(Icons.storefront_outlined, 'สาขา'),
            branchCard(
              name: 'บริษัท พี ที เอ็น ฟาร์มาเซ็นเตอร์ จำกัด',
              addressLines: <String>[
                '919/30 ม.10 ถ.พหลโยธิน ต.นครสวรรค์ตก',
                'อ.เมือง จ.นครสวรรค์ 60000',
              ],
              phone: '056-371370, มือถือ 092-0319999',
              hours: 'เวลาทำการ 9.30 - 18.00 น.',
            ),
            branchCard(
              name: 'คลังสินค้า พัฒนาเภสัช',
              addressLines: <String>[
                '159/1 ม.4 นครสวรรค์ตก',
                'อำเภอเมืองนครสวรรค์ จ.นครสวรรค์ 60000',
              ],
              phone: '056-345625, มือถือ 081-9164131',
              hours: 'เวลาทำการ 9.30 - 17.00 น.',
            ),
            mapCard(),
            sectionHeader(Icons.forum_outlined, 'ช่องทางออนไลน์'),
            socialTile(
              iconAsset: 'images/icon_line.png',
              label: 'https://line.me/ti/p/_P0vaper0j',
            ),
            socialTile(
              iconAsset: 'images/icon_facebook.png',
              label: 'https://www.facebook.com/pattana.rx',
            ),
          ],
        ),
      ),
    );
  }
}
