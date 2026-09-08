import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/detail.dart';
import 'package:ptncenter/utility/my_style.dart';

/// carousel รายการสินค้าแบบการ์ดแนวนอน ใช้ซ้ำสำหรับหลาย section ในหน้า Home
/// (สินค้าขายดี, สินค้ามาแรง, รายการโปรโมชัน, สินค้าจะปรับราคา) — เดิมแต่ละ section
/// มีฟังก์ชันสร้างการ์ดของตัวเองแยกกันทั้งที่โค้ดเหมือนกันทุกตัวอักษร
/// แยกออกมาเป็น widget เดียวใช้ซ้ำ พร้อมกับลดขนาด home.dart ไปในตัว
class ProductCarouselSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<ProductAllModel> products;
  final VoidCallback? onSeeAll;
  final UserModel? userModel;

  /// เรียกหลังกลับจากหน้ารายละเอียดสินค้า ให้หน้า Home รีเฟรชตะกร้า/badge ของตัวเอง
  final VoidCallback? onReturnFromDetail;

  const ProductCarouselSection({
    super.key,
    required this.title,
    required this.icon,
    required this.products,
    required this.userModel,
    this.onSeeAll,
    this.onReturnFromDetail,
  });

  @override
  State<ProductCarouselSection> createState() =>
      _ProductCarouselSectionState();
}

class _ProductCarouselSectionState extends State<ProductCarouselSection> {
  void routeToDetail(ProductAllModel product) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return Detail(userModel: widget.userModel, productAllModel: product);
    });
    Navigator.of(context).push(materialPageRoute).then((value) {
      widget.onReturnFromDetail?.call();
      updateProductCartInfo(product);
    });
  }

  /// เหมือน updateDatalist() ในหน้า list_product แต่รับ ProductAllModel ตรงๆ แทนดัชนี
  /// เพราะการ์ดในนี้อ้าง product โดยตรง ไม่ได้ผูกกับ index ของ list ใด list หนึ่งเป็นการเฉพาะ
  Future<void> updateProductCartInfo(ProductAllModel product) async {
    String? memberId = widget.userModel?.id.toString();
    if (memberId == null || product.id == null) return;
    String url =
        '${MyStyle().serverName}/json_loadmycart.php?memberId=$memberId';
    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      var cartList = result['cart'];

      Map<String, dynamic>? mapCart;
      if (cartList != null) {
        for (var m in cartList) {
          if (m['id'] == product.id) {
            mapCart = m;
            break;
          }
        }
      }

      if (mounted) {
        setState(() {
          product.itemincartSunit =
              (mapCart != null && mapCart['price_list'].containsKey('s'))
                  ? mapCart['price_list']['s']['quantity']
                  : '0';
          product.itemincartMunit =
              (mapCart != null && mapCart['price_list'].containsKey('m'))
                  ? mapCart['price_list']['m']['quantity']
                  : '0';
          product.itemincartLunit =
              (mapCart != null && mapCart['price_list'].containsKey('l'))
                  ? mapCart['price_list']['l']['quantity']
                  : '0';
        });
      }
    } catch (e) {} // ignore: empty_catches
  }

  /// เหมือน priceUnitText() ในหน้า list_product (grid view) แต่รับ model ตรงๆ แทนดัชนี
  String priceUnitText(ProductAllModel model) {
    String txtPriceUnit = '';
    if ((model.itemSprice ?? '0').toString() != '0') {
      txtPriceUnit += ' [${model.itemSprice}/${model.itemSunit}] ';
    }
    if ((model.itemMprice ?? '0').toString() != '0') {
      txtPriceUnit += ' [${model.itemMprice}/${model.itemMunit}] ';
    }
    if ((model.itemLprice ?? '0').toString() != '0') {
      txtPriceUnit += ' [${model.itemLprice}/${model.itemLunit}] ';
    }
    return txtPriceUnit;
  }

  /// เหมือน showGridImage() ในหน้า list_product
  Widget cardImage(ProductAllModel product) {
    String? photo = product.photo;
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(6.0),
        topRight: Radius.circular(6.0),
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          color: Colors.white,
          padding:
              EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
          alignment: Alignment.center,
          child: FractionallySizedBox(
            widthFactor: 0.9,
            heightFactor: 0.9,
            child: (photo != null && photo.isNotEmpty)
                ? Image.network(
                    photo,
                    fit: BoxFit.cover,
                    alignment: FractionalOffset.topCenter,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: 10.0,
                          height: 10.0,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey.shade400,
                    ),
                  )
                : Icon(Icons.image_not_supported_outlined,
                    color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  /// เหมือน showGridStock() ในหน้า list_product
  Widget stockRow(ProductAllModel model) {
    bool inStock = model.stock.toString() != '0';
    bool hasInCart = model.itemincartSunit != '0' ||
        model.itemincartMunit != '0' ||
        model.itemincartLunit != '0';

    String txtIncart = ((model.itemincartSunit != '0')
            ? '${model.itemincartSunit} ${model.itemSunit}  '
            : '') +
        ((model.itemincartMunit != '0')
            ? '${model.itemincartMunit} ${model.itemMunit}  '
            : '') +
        ((model.itemincartLunit != '0')
            ? '${model.itemincartLunit} ${model.itemLunit}'
            : '');

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Stock: ${model.stock}',
            style: TextStyle(
              fontSize: 13.0,
              color: inStock ? Colors.grey.shade900 : Colors.red,
            ),
          ),
        ),
        if (hasInCart)
          Flexible(
            child: Text(
              'ตะกร้า: $txtIncart',
              style: TextStyle(fontSize: 13.0, color: Colors.red),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  /// เหมือน showGridItem() ในหน้า list_product (แสดงแบบ gridview) แต่ใช้ในแนวนอนแบบ carousel
  Widget productCard(ProductAllModel product) {
    return GestureDetector(
      onTap: () => routeToDetail(product),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.0),
        child: Card(
          color: Colors.white,
          elevation: 1.5,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
            side: BorderSide(color: Colors.green.shade100),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              cardImage(product),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        product.title ?? '',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B6B41),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((product.hilight ?? '') != '')
                        Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Text(
                            product.hilight!,
                            style: TextStyle(fontSize: 14.0, color: Colors.red),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if ((product.extrapoint ?? '') != '')
                        Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Text(
                            product.extrapoint!,
                            style:
                                TextStyle(fontSize: 11.0, color: Colors.orange),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          priceUnitText(product),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color.fromRGBO(50, 117, 168, 1.0),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: stockRow(product),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: <Widget>[
          Icon(widget.icon, size: 22.0, color: MyStyle().textColor),
          SizedBox(width: 8.0),
          Text(widget.title, style: MyStyle().sectionTitleStyle),
          if (widget.onSeeAll != null) ...[
            Spacer(),
            GestureDetector(
              onTap: widget.onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'ดูทั้งหมด',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: MyStyle().mainColor,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 18.0, color: MyStyle().mainColor),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        header(),
        SizedBox(
          height: 260.0,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              height: 260.0,
              viewportFraction: 0.42,
              enableInfiniteScroll: false,
              padEnds: false,
            ),
            itemCount: widget.products.length,
            itemBuilder: (context, index, realIdx) {
              return productCard(widget.products[index]);
            },
          ),
        ),
      ],
    );
  }
}
