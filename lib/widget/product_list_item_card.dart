import 'package:flutter/material.dart';
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/utility/my_style.dart';

/// การ์ดสินค้าหนึ่งชิ้นในรายการ (รูป + ชื่อ/ไฮไลต์/แต้มพิเศษ/ราคา/สต๊อก/จำนวนในตะกร้า)
/// ใช้ร่วมกันในหน้ารายการสินค้า (list_product.dart) และหน้ารายการสินค้าตามโปรโมชันกลุ่ม
/// (list_product_promotion.dart)
class ProductListItemCard extends StatelessWidget {
  final ProductAllModel product;
  final VoidCallback onTap;

  const ProductListItemCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.green.shade300),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );
  }

  Widget _showImage() {
    return Container(
      padding: EdgeInsets.all(5.0),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
          image: DecorationImage(
        fit: BoxFit.cover,
        alignment: FractionalOffset.topCenter,
        image: NetworkImage(product.photo!),
      )),
    );
  }

  Widget _showName(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Text(product.title!, style: MyStyle().h3Style),
        ),
      ],
    );
  }

  Widget _showHilight(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Text(product.hilight!, style: MyStyle().h3StyleRed),
        ),
      ],
    );
  }

  Widget _showExtrapoint(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Text(product.extrapoint!, style: MyStyle().h3StyleOrange),
        ),
      ],
    );
  }

  Widget _showIncart(BuildContext context) {
    return Row(children: <Widget>[
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.13,
        child: Text(
          (product.itemincartSunit != '0' ||
                  product.itemincartMunit != '0' ||
                  product.itemincartLunit != '0')
              ? 'ตะกร้า:'
              : '',
          style: MyStyle().h4StyleRed,
        ),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Text(
          ((product.itemincartSunit != '0')
                  ? '${product.itemincartSunit} ${product.itemSunit}  '
                  : '') +
              ((product.itemincartMunit != '0')
                  ? '${product.itemincartMunit} ${product.itemMunit}  '
                  : '') +
              ((product.itemincartLunit != '0')
                  ? '${product.itemincartLunit} ${product.itemLunit}'
                  : ''),
          style: MyStyle().h4StyleRed,
        ),
      ),
    ]);
  }

  Widget _showStock(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.12,
          child: Text('Stock:', style: MyStyle().h4StyleGray),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.12,
          child: Text(
            ' ${product.stock}',
            style: (product.stock.toString() != '0')
                ? MyStyle().h4StyleGray
                : MyStyle().h4StyleRed,
          ),
        ),
        _showIncart(context),
      ],
    );
  }

  Widget _showPrice() {
    String txtShowPrice;
    String txtShowUnit;
    String txtPriceUnit = '';
    if (product.itemSprice.toString() != '0') {
      txtShowPrice = product.itemSprice.toString();
      txtShowUnit = product.itemSunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '') {
        txtPriceUnit += " [$txtShowPrice/$txtShowUnit] ";
      }
    }
    if (product.itemMprice.toString() != '0') {
      txtShowPrice = product.itemMprice.toString();
      txtShowUnit = product.itemMunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '') {
        txtPriceUnit += " [$txtShowPrice/$txtShowUnit] ";
      }
    }
    if (product.itemLprice.toString() != '0') {
      txtShowPrice = product.itemLprice.toString();
      txtShowUnit = product.itemLunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '') {
        txtPriceUnit += " [$txtShowPrice/$txtShowUnit] ";
      }
    }

    return Row(
      children: <Widget>[
        Text(
          txtPriceUnit,
          style: TextStyle(
            fontSize: 16.0,
            color: Color.fromRGBO(50, 117, 168, 1.0),
          ),
        ),
      ],
    );
  }

  Widget _showText(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 5.0, right: 0.0),
      width: MediaQuery.of(context).size.width * 0.78,
      child: Container(
        padding: EdgeInsets.only(bottom: 5.0, top: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _showName(context),
            (product.hilight != '') ? _showHilight(context) : Container(),
            (product.extrapoint != '')
                ? _showExtrapoint(context)
                : Container(),
            _showPrice(),
            _showStock(context),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          decoration: _boxDecoration(),
          padding: EdgeInsets.only(top: 0.5),
          child: Row(
            children: <Widget>[
              _showImage(),
              _showText(context),
            ],
          ),
        ),
      ),
    );
  }
}
