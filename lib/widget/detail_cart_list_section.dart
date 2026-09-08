import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:ptncenter/models/product_all_model2.dart';
import 'package:ptncenter/utility/my_style.dart';

/// รายการสินค้าในตะกร้า แต่ละใบแสดงชื่อ/ไฮไลต์สินค้า พร้อมช่องแก้ไขจำนวนและปุ่มลบ
/// แยกตามไซส์ (S/M/L) ที่มีอยู่ในตะกร้า
class CartListSection extends StatelessWidget {
  final List<ProductAllModel2> productAllModels;
  final List<dynamic> allArrIncartS;
  final List<dynamic> allArrIncartM;
  final List<dynamic> allArrIncartL;
  final List<Map<String, dynamic>> sMap;
  final List<Map<String, dynamic>> mMap;
  final List<Map<String, dynamic>> lMap;

  /// จำนวนคะแนนพิเศษที่สินค้าชิ้นนี้เข้าเงื่อนไข (คำนวนจาก state ฝั่งหน้าตะกร้า)
  final double Function(int? productId) extraPointsForProduct;

  /// เรียกเมื่อผู้ใช้เปลี่ยนจำนวนสินค้าในช่อง SpinBox ของไซส์ใดไซส์หนึ่ง
  final void Function(String productID, String size, double newQty) onQuantityChanged;

  /// เรียกเมื่อผู้ใช้ยืนยันลบสินค้าไซส์นั้นออกจากตะกร้า (หลังกด Confirm ใน dialog แล้ว)
  final void Function(int index, String size) onDeleteConfirmed;

  const CartListSection({
    super.key,
    required this.productAllModels,
    required this.allArrIncartS,
    required this.allArrIncartM,
    required this.allArrIncartL,
    required this.sMap,
    required this.mMap,
    required this.lMap,
    required this.extraPointsForProduct,
    required this.onQuantityChanged,
    required this.onDeleteConfirmed,
  });

  String _formatNum(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  Widget _showTitle(BuildContext context, int index) {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 10.0),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: Text(
              productAllModels[index].title!,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0x00, 0x73, 0x26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _extraPointInlineBadge(double points) {
    return Container(
      margin: EdgeInsets.only(left: 6.0),
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Color(0xFFFFF3D6),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Color(0xFFFFE0A3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.star, size: 12.0, color: Color(0xFFF5A623)),
          SizedBox(width: 2.0),
          Text('+${_formatNum(points)}',
              style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A5B00))),
        ],
      ),
    );
  }

  Widget _showHilight(BuildContext context, int index) {
    double extraPoints = extraPointsForProduct(productAllModels[index].id);

    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 16.00),
          width: MediaQuery.of(context).size.width * 0.75,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(productAllModels[index].hilight!, style: MyStyle().h3StyleRed),
              if (extraPoints > 0) _extraPointInlineBadge(extraPoints),
            ],
          ),
        ),
      ],
    );
  }

  Widget _changeQTY(
      String productID, String size, double quantity, double limitorder) {
    return SizedBox(
      width: 140.0,
      child: SpinBox(
        decoration: InputDecoration(
          border: UnderlineInputBorder(), // InputBorder.none,
        ),
        value: quantity,
        min: 1,
        max: (limitorder == 0) ? 10000 : limitorder, //10000,//
        onChanged: (changevalue) {
          onQuantityChanged(
              productID, size, (changevalue == 0) ? 0 : changevalue.toDouble());
        },
      ),
    );
  }

  Widget _cancelButton(BuildContext context) {
    return TextButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _comfirmButton(BuildContext context, int index, String size) {
    return TextButton(
      child: Text('Confirm'),
      onPressed: () {
        onDeleteConfirmed(index, size);
        Navigator.pop(context);
      },
    );
  }

  void _confirmDelete(BuildContext context, int index, String size) {
    String titleProduct = productAllModels[index].title!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('ลบสินค้าออกจากตะกร้า'),
          content: Text('ต้องการลบรายการออกจากตะกร้า : $titleProduct'),
          actions: <Widget>[
            _cancelButton(dialogContext),
            _comfirmButton(dialogContext, index, size),
          ],
        );
      },
    );
  }

  Widget _deleteButton(BuildContext context, int index, String size) {
    return IconButton(
      icon: Icon(Icons.delete, color: Colors.red),
      onPressed: () {
        _confirmDelete(context, index, size);
      },
    );
  }

  Widget _showSText(BuildContext context, int proIndex, int index) {
    String? productID = productAllModels[proIndex].id.toString();
    String? priceS = sMap[index]['price']?.toString();
    String? lableS = sMap[index]['lable'];
    String? quantityS = sMap[index]['quantity'];
    String? pricechange = sMap[index]['pricechange']?.toString();

    double? showQTYS =
        (quantityS == null) ? 0.0 : double.parse(quantityS.replaceAll(',', ''));

    double? showlimitS = (sMap[index]['limitorder'] == null)
        ? 0.0
        : double.parse(sMap[index]['limitorder']);

    return lableS!.isEmpty
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              (pricechange != '-')
                  ? Column(
                      children: [
                        Text('$priceS บาท/ $lableS', style: MyStyle().h3Style),
                        (pricechange != '-')
                            ? Text(
                                'ปรับราคา ${pricechange!} บาท',
                                style: (double.parse(pricechange) > 0)
                                    ? MyStyle().h5StyleRed
                                    : MyStyle().h5StyleBlue,
                              )
                            : Container(),
                      ],
                    )
                  : Text('$priceS บาท/ $lableS', style: MyStyle().h3Style),
              _changeQTY(productID, 's', showQTYS, showlimitS),
              _deleteButton(context, proIndex, 's'),
            ],
          );
  }

  Widget _showMText(BuildContext context, int proIndex, int index) {
    String? productID = productAllModels[proIndex].id.toString();
    String? priceM = mMap[index]['price']?.toString();
    String? lableM = mMap[index]['lable'];
    String? quantityM = mMap[index]['quantity'];
    String? pricechange = mMap[index]['pricechange']?.toString();

    double? showQTYM =
        (quantityM == null) ? 0.0 : double.parse(quantityM.replaceAll(',', ''));

    double? showlimitM = (mMap[index]['limitorder'] == null)
        ? 0.0
        : double.parse(mMap[index]['limitorder']);

    return lableM!.isEmpty
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              (pricechange != '-')
                  ? Column(
                      children: [
                        Text('$priceM บาท/ $lableM', style: MyStyle().h3Style),
                        (pricechange != '-')
                            ? Text(
                                'ปรับราคา ${pricechange!} บาท',
                                style: (double.parse(pricechange) > 0)
                                    ? MyStyle().h5StyleRed
                                    : MyStyle().h5StyleBlue,
                              )
                            : Container(),
                      ],
                    )
                  : Text('$priceM บาท/ $lableM', style: MyStyle().h3Style),
              _changeQTY(productID, 'm', showQTYM, showlimitM),
              _deleteButton(context, proIndex, 'm'),
            ],
          );
  }

  Widget _showLText(BuildContext context, int proIndex, int index) {
    String? productID = productAllModels[proIndex].id.toString();
    String? priceL = lMap[index]['price']?.toString();
    String? lableL = lMap[index]['lable'];
    String? quantityL = lMap[index]['quantity'];
    String? pricechange = lMap[index]['pricechange']?.toString();

    double? showQTYL =
        (quantityL == null) ? 0.0 : double.parse(quantityL.replaceAll(',', ''));

    double? showlimitL = (lMap[index]['limitorder'] == null)
        ? 0.0
        : double.parse(lMap[index]['limitorder']);

    return lableL!.isEmpty
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              (pricechange != '-')
                  ? Column(
                      children: [
                        Text('$priceL บาท/ $lableL', style: MyStyle().h3Style),
                        (pricechange != '-')
                            ? Text(
                                'ปรับราคา ${pricechange!} บาท',
                                style: (double.parse(pricechange) > 0)
                                    ? MyStyle().h5StyleRed
                                    : MyStyle().h5StyleBlue,
                              )
                            : Container(),
                      ],
                    )
                  : Text('$priceL บาท/ $lableL', style: MyStyle().h3Style),
              _changeQTY(productID, 'l', showQTYL, showlimitL),
              _deleteButton(context, proIndex, 'l'),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
      physics: ScrollPhysics(),
      shrinkWrap: true,
      itemCount: productAllModels.length,
      itemBuilder: (BuildContext buildContext, int index) {
        int? proID = productAllModels[index].id;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            side: BorderSide(width: 2, color: Colors.grey.shade200),
          ),
          child: Container(
            padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
            child: Column(
              children: <Widget>[
                _showTitle(buildContext, index),
                (productAllModels[index].hilight! == '')
                    ? Container()
                    : _showHilight(buildContext, index),
                (allArrIncartS.contains(proID))
                    ? _showSText(buildContext, index, allArrIncartS.indexOf(proID))
                    : Container(),
                (allArrIncartM.contains(proID))
                    ? _showMText(buildContext, index, allArrIncartM.indexOf(proID))
                    : Container(),
                (allArrIncartL.contains(proID))
                    ? _showLText(buildContext, index, allArrIncartL.indexOf(proID))
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}
