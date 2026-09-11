import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:ptncenter/models/unit_size_model.dart';
import 'package:ptncenter/utility/my_style.dart';

/// แถวเลือกจำนวนสินค้าที่จะเพิ่มลงตะกร้าของขนาดบรรจุหนึ่งไซส์ (S/M/L) ในหน้ารายละเอียดสินค้า
/// แสดงราคา/หน่วยไซส์นั้น พร้อมช่อง SpinBox ให้เลือกจำนวน หรือช่องอ่านอย่างเดียว
/// พร้อมข้อความ "งดจำหน่าย" ถ้าไซส์นั้นราคาเป็น 0
class PackageSizeRow extends StatelessWidget {
  final UnitSizeModel unitSizeModel;

  /// จำนวนของไซส์นี้ที่มีอยู่ในตะกร้าอยู่แล้ว (showSincart/showMincart/showLincart)
  final int? currentQtyInCart;

  /// จำนวนสูงสุดที่สั่งได้ต่อครั้งของไซส์นี้ (limitS/limitM/limitL)
  final int? limit;

  /// เรียกเมื่อผู้ใช้เปลี่ยนจำนวนที่จะเพิ่มลงตะกร้าในช่อง SpinBox
  final ValueChanged<int> onQuantityChanged;

  const PackageSizeRow({
    super.key,
    required this.unitSizeModel,
    required this.currentQtyInCart,
    required this.limit,
    required this.onQuantityChanged,
  });

  bool get _isOutOfStock => unitSizeModel.price.toString() == '0';

  Widget _showPackage() {
    return _isOutOfStock
        ? Text(unitSizeModel.lable!,
            style: MyStyle().h3bStyleRed,
            overflow: TextOverflow.ellipsis)
        : Text(unitSizeModel.lable!,
            style: MyStyle().h3Style, overflow: TextOverflow.ellipsis);
  }

  Widget _showPricePackage() {
    return _isOutOfStock
        ? Text('งดจำหน่าย / ',
            style: MyStyle().h3bStyleRed, overflow: TextOverflow.ellipsis)
        : Text('${unitSizeModel.price.toString()} / ',
            style: MyStyle().h3bStyleGreen, overflow: TextOverflow.ellipsis);
  }

  Widget _showDetailPrice() {
    return Row(
      children: <Widget>[
        Flexible(flex: 2, child: _showPricePackage()),
        Flexible(flex: 3, child: _showPackage()),
      ],
    );
  }

  Widget _showValue(BuildContext context) {
    int? iniValue = currentQtyInCart;
    int? limitValue = limit;

    if (_isOutOfStock) {
      Color iconColor = Color.fromARGB(0xff, 0xff, 0x99, 0x99);
      return Container(
        width: MediaQuery.of(context).size.width * 0.50,
        padding: EdgeInsets.only(left: 20.0, right: 10.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              style: TextStyle(color: Colors.black),
              initialValue: '$iniValue',
              readOnly: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 3.0),
                prefixIcon: Icon(Icons.cancel, color: iconColor),
                border: InputBorder.none,
                hintStyle: TextStyle(color: iconColor),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width * 0.50,
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0),
              child: SpinBox(
                min: 0,
                max: (limitValue == 0) ? 10000 : limitValue!.toDouble(),
                value: (iniValue)!.toDouble(),
                onChanged: (changevalue) {
                  onQuantityChanged(
                      (changevalue == 0) ? 0 : changevalue.toInt());
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(child: _showDetailPrice()),
        _showValue(context),
      ],
    );
  }
}
