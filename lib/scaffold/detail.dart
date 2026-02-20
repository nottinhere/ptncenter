import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/product_all_model2.dart';
import 'package:ptncenter/models/unit_size_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';

import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ptncenter/models/promote_model.dart';
import 'package:ptncenter/widget/home.dart';
import 'my_service.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:favorite_button/favorite_button.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class Detail extends StatefulWidget {
  final ProductAllModel? productAllModel;
  final UserModel? userModel;

  Detail({Key? key, this.productAllModel, this.userModel}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  // Explicit
  ProductAllModel? currentProductAllModel;
  ProductAllModel2? productAllModel;
  ProductAllModel? relateAllModel;

  List<UnitSizeModel>? unitSizeModels = [];
  List<ProductAllModel>? slideshowModels = [];
  List<ProductAllModel>? relateslideshowModels = [];

  List<int>? amounts = [0, 0, 0];
  int? amontCart = 0;
  UserModel? myUserModel;
  String? id; // productID
  // String qtyS = '', qtyM = '', qtyL = '';
  int? sizeSincart = 0, sizeMincart = 0, sizeLincart = 0;
  int? qtyS = 0, qtyM = 0, qtyL = 0;
  int? showSincart = 0, showMincart = 0, showLincart = 0;
  // var showSincart = '', showMincart = '', showLincart = '';

  List<Widget>? promoteLists = [];
  List<Widget>? relateLists = [];
  List<String>? urlImages = [];
  List<String>? urlImagesRelate = [];
  List<String>? productsName = [];
  List<String>? productsNameRelate = [];
  List<ProductAllModel>? promoteModels = [];
  List<ProductAllModel>? relateModels = [];
  List<Widget>? slideshowLists = [];
  List<Widget>? relateslideshowLists = [];

  int? banerIndex = 0, relateIndex = 0;
  int? currentIndex = 1;
  String? qrString;
  String? videoCode = "";
  int selectIndex = 1;

  // Method
  @override
  void initState() {
    super.initState();
    currentProductAllModel = widget.productAllModel;
    myUserModel = widget.userModel;
    setState(() {
      readCart();
      getProductWhereID();
    });
    readSlide();
    readRelate();
  }

  Future<void> getProductWhereID() async {
    if (currentProductAllModel! != '') {
      String? memberId = myUserModel!.id.toString();
      id = currentProductAllModel!.id.toString();
      String? url = '${MyStyle().getProductWhereId}$id&memberId=$memberId';
      print('url Detaillll ====>>> $url');
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print('result =0000000>>> $result');

      var itemProducts = result['itemsProduct'];
      print('itemProducts ===>>>>$itemProducts');
      for (var map in itemProducts) {
        print('map DEtail ==========>>>>>>>> $map');

        setState(() {
          productAllModel = ProductAllModel2.fromJson(map);

          Map<String, dynamic> priceListMap = map['price_list'];
          print('currentProductAllModel = $currentProductAllModel');

          Map<String, dynamic>? sizeSmap = priceListMap['s'];
          if (sizeSmap != null) {
            UnitSizeModel unitSizeModel = UnitSizeModel.fromJson(sizeSmap);
            unitSizeModels!.add(unitSizeModel);
          }
          Map<String, dynamic>? sizeMmap = priceListMap['m'];
          if (sizeMmap != null) {
            UnitSizeModel unitSizeModel = UnitSizeModel.fromJson(sizeMmap);
            unitSizeModels!.add(unitSizeModel);
          }
          Map<String, dynamic>? sizeLmap = priceListMap['l'];
          if (sizeLmap != null) {
            UnitSizeModel unitSizeModel = UnitSizeModel.fromJson(sizeLmap);
            unitSizeModels!.add(unitSizeModel);
          }
          print('sizeSmap = $sizeSmap');
          print('sizeMmap = $sizeMmap');
          print('sizeLmap = $sizeLmap');
        });
      } // for

      setState(() {
        showSincart = productAllModel!.itemincartSunit;
        showMincart = productAllModel!.itemincartMunit;
        showLincart = productAllModel!.itemincartLunit;

        videoCode = productAllModel?.youtube?.toString();
      });
      print('videoCode >> $videoCode');
    }
  }

  /*************************** */

  Image showImageNetWork(String urlImage) {
    return Image.network(urlImage);
  }

  /*************************** */

  Future<void> readSlide() async {
    String? memId = myUserModel!.id;
    id = currentProductAllModel!.id.toString();

    String url =
        'https://www.ptnpharma.com/apishop/json_productimage.php?memberId=$memId&id=$id';
    // String url = 'https://www.ptnpharma.com/apishop/json_slideshow.php';

    print('URL image detail >> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null

    for (var map in mapItemProduct) {
      PromoteModel? slideshowModel = PromoteModel.fromJson(map);
      ProductAllModel? productAllModel = ProductAllModel.fromJson(map);
      String? urlImage = slideshowModel.photo;
      // print('urlImage >> $urlImage');

      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        slideshowModels!.add(productAllModel);
        slideshowLists!.add(showImageNetWork(urlImage!));

        urlImages!.add(urlImage);
      });
    }
  }

  // /*************************** */
  Future<void> readRelate() async {
    String? memId = myUserModel!.id;
    id = currentProductAllModel!.id.toString();

    String url =
        'https://www.ptnpharma.com/apishop/json_relate.php?memberId=$memId&productId=$id'; // ?memberId=$memberId

    print('URL relate >> $url');
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    print('mapItemProduct >> $mapItemProduct');

    for (var map in mapItemProduct) {
      PromoteModel? relateslideshowModel = PromoteModel.fromJson(map);
      ProductAllModel? productAllModel = ProductAllModel.fromJson(map);
      String? urlImage = relateslideshowModel.photo;
      String? productName = relateslideshowModel.title;

      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        relateslideshowModels!.add(productAllModel);
        relateslideshowLists!.add(showImageNetWork(urlImage!));
        // productsNameRelate!.add(productName!);
        urlImagesRelate!.add(urlImage);
      });
    }
    print('relateslideshowModels >> $relateslideshowModels');
  }

  Widget myCircularProgress() {
    return Center(child: CircularProgressIndicator());
  }

  void routeToListProductByCate(int index, int cate, String cateName) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return ListProduct(
          index: index,
          userModel: myUserModel!,
          cate: cate,
          cateName: cateName,
        );
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToListProductfav(int index) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return ListProductfav(index: index, userModel: myUserModel!);
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  Widget categoryTag() {
    return Container(
      // width: MediaQuery.of(context).size.width * 0.20,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.blueGrey.shade400,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  productAllModel!.cateName!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click promotion');
          routeToListProductByCate(
            6,
            int.parse(productAllModel!.cateID!),
            productAllModel!.cateName!,
          );
        },
      ),
    );
  }

  Widget promotionTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.20,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade300,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'โปรโมชัน',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click promotion');
          routeToListProduct(2);
        },
      ),
    );
  }

  Widget updatepriceTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.22,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade300,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'จะปรับราคา',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click update price');
          routeToListProduct(3);
        },
      ),
    );
  }

  Widget newproductTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.20,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade300,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'สินค้าใหม่',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click new item');
          routeToListProduct(1);
        },
      ),
    );
  }

  Widget notreceiveTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade300,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'สั่งแล้วไม่ได้รับ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click not receive');
          routeToListProduct(4);
        },
      ),
    );
  }

  Widget showTag() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      // mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(width: 5.0, height: 5.0),
        // categoryTag(),
        productAllModel!.promotion == 1 ? promotionTag() : Container(),
        productAllModel!.newproduct == 1 ? newproductTag() : Container(),
        productAllModel!.updateprice == 1 ? updatepriceTag() : Container(),
        productAllModel!.notreceive == 1 ? notreceiveTag() : Container(),
        SizedBox(width: 5.0, height: 8.0),
      ],
    );
  }

  Widget showCarouseSlideshow() {
    print('slideshowLists.length >> ' + slideshowLists!.length.toString());
    return Column(
      children: [
        GestureDetector(
          child: CarouselSlider.builder(
            options: CarouselOptions(
              // pauseAutoPlayOnTouch: Duration(seconds: 5),
              autoPlay: slideshowLists!.isNotEmpty ? true : false,
              autoPlayAnimationDuration: Duration(seconds: 5),
            ),
            itemCount: (slideshowLists!.length).round(),
            itemBuilder: (context, index, realIdx) {
              final int first = index;
              // final int second = first + 1;
              return Row(
                children: [first].map((idx) {
                  return Expanded(
                    child: Container(
                      padding: EdgeInsets.all(1.0),
                      child: Center(
                        child: Image.network(
                          urlImages![idx],
                          fit: BoxFit.cover,
                          width: 1000,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        Divider(),
      ],
    );
  }

  Widget showCarouseSliderRelate() {
    print(
      'relateslideshowLists.length  (Widget) > ' +
          relateslideshowLists!.length.toString(),
    );
    return GestureDetector(
      child: CarouselSlider.builder(
        options: CarouselOptions(
          // pauseAutoPlayOnTouch: Duration(seconds: 5),
          autoPlay: (relateslideshowLists!.isNotEmpty) ? true : false,
          autoPlayAnimationDuration: Duration(seconds: 5),
        ),
        itemCount: (relateslideshowLists!.length / 2).round(),
        itemBuilder: (context, index, realIdx) {
          final int first = index * 2;
          final int second = first + 1;
          return Row(
            children: [first, second].map((idx) {
              return Expanded(
                child: GestureDetector(
                  child: Card(
                    child: Column(
                      children: [
                        Container(
                          child: Image.network(
                            urlImagesRelate![idx],
                            fit: BoxFit.cover,
                            width: 1000,
                          ),
                          height: 100.00,
                          padding: EdgeInsets.all(8.0),
                        ),
                        Text(
                          relateslideshowModels![idx].title!,
                          style: TextStyle(
                            fontSize: 12,
                            // fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    print('You Click index >> $idx');
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (BuildContext context) => Detail(
                        productAllModel: relateslideshowModels![idx],
                        userModel: myUserModel,
                      ),
                    );
                    Navigator.of(context).push(route).then((value) {});
                  },
                ),
              );
            }).toList(),
          );

          // return Row(
          //   children: [first, second].map((idx) {
          //         return Expanded(
          //           child: GestureDetector(
          //             child: Card(
          //               // flex: 1,
          //               child: Column(
          //                 children: <Widget>[
          //                   Container(
          //                     child: Image.network(urlImages![idx],
          //                         fit: BoxFit.cover, width: 1000),

          //                     // width: MediaQuery.of(context).size.width * 0.50,
          //                     height: 100.00,
          //                     // child: relateslideshowLists![idx],
          //                     padding: EdgeInsets.all(8.0),
          //                   ),
          //                   Text(
          //                     productsName![idx].toString(),
          //                     style: TextStyle(
          //                         fontSize: 12,
          //                         // fontWeight: FontWeight.bold,
          //                         color: Colors.black),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //             onTap: () {
          //               print('You Click index >> $idx');
          //               MaterialPageRoute route = MaterialPageRoute(
          //                 builder: (BuildContext context) => Detail(
          //                   productAllModel: relateslideshowModels![idx],
          //                   userModel: myUserModel,
          //                 ),
          //               );
          //               Navigator.of(context).push(route).then((value) {});
          //             },
          //           ),
          //         );
          //       }).toList() ??
          //       [],
          // );
        },
      ),
    );
  }

  Widget showImage() {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.5 - 50,
      height: MediaQuery.of(context).size.height * 0.5 - 150,
      child: Image.network(productAllModel!.photo!, fit: BoxFit.contain),
    );
  }

  // Post ค่าไปยัง API ที่ต้องการ
  Future<void> editFavorite(
    String productID,
    String memberID,
    bool _isFavorite,
  ) async {
    String url =
        'https://www.ptnpharma.com/apishop/json_favorite.php?productID=$productID&memberId=$memberID&status=$_isFavorite';

    print('url Favorites url ====>>>>> $url');
    await http.get(Uri.parse(url)).then((response) {
      setState(() {
        //readCart();
      });
    });
  }

  Widget favButton() {
    bool? favStatus = (productAllModel!.favorite == true) ? true : false;

    String? productID = id;
    String? memberID = myUserModel!.id.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Text(
        //   'รายการโปรด',
        //   style: MyStyle().h3StyleBlue,
        // ),
        FavoriteButton(
          isFavorite: favStatus,
          iconSize: 50.0,
          // iconDisabledColor: Colors.white,
          valueChanged: (_isFavorite) {
            // print('Is Favorite : $_isFavorite');
            editFavorite(productID!, memberID, _isFavorite);

            // http.Response response =  http.get(Uri.parse(url));
          },
        ),
      ],
    );
  }

  Widget showTitle() {
    return Text(productAllModel!.title!, style: MyStyle().h3bStyle);
  }

  Widget showHilight() {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.7 - 10,
          child: Text(productAllModel!.hilight!, style: MyStyle().h3StyleRed),
        ),
      ],
    );
  }

  Widget showExtrapoint() {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.7 - 10,
          child: Text(productAllModel!.extrapoint!,
              style: MyStyle().h3StyleOrange),
        ),
      ],
    );
  }
  // Widget showDetail() {
  //   return Text(productAllModel.detail);
  // }

  Widget showPackage(int index) {
    if (unitSizeModels![index].price.toString() == '0') {
      return Text(unitSizeModels![index].lable!, style: MyStyle().h3bStyleRed);
    } else {
      return Text(unitSizeModels![index].lable!, style: MyStyle().h3Style);
    }
  }

  Widget showPricePackage(int index) {
    if (unitSizeModels![index].price.toString() == '0') {
      return Text('งดจำหน่าย / ', style: MyStyle().h3bStyleRed);
    } else {
      return Text(
        '${unitSizeModels![index].price.toString()} บาท / ',
        style: MyStyle().h3bStyleGreen,
      );
    }
  }

  Widget showChoosePricePackage(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        showDetailPrice(index),
        // incDecValue(index),
        showValue(index),
      ],
    );
  }

  Widget showDetailPrice(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[showPricePackage(index), showPackage(index)],
    );
  }

  Widget showValue(int index) {
    //  int value = amounts[index];
    //  return Text('$value');
    int? iniValue = 0;
    bool? readOnlyMode;
    var iconName;
    var iconColor;
    print('incart all size -> $sizeSincart / $sizeMincart / $sizeLincart ');
    if (index == 0) {
      iniValue = showSincart;
    } else if (index == 1) {
      iniValue = showMincart;
    } else if (index == 2) {
      iniValue = showLincart;
    }

    iniValue = (iniValue); // (iniValue).toInt();

    /////////////////////////////////////////////////////////
    if (unitSizeModels![index].price.toString() == '0') {
      readOnlyMode = true;
      iconName = Icons.cancel;
      iconColor = Color.fromARGB(0xff, 0xff, 0x99, 0x99);
      return Container(
        // decoration: MyStyle().boxLightGreen,
        // height: 35.0,
        width: MediaQuery.of(context).size.width * 0.50,
        padding: EdgeInsets.only(left: 20.0, right: 10.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              style: TextStyle(color: Colors.black),
              initialValue: '$iniValue',
              // controller: TextEditingController()..text = '$iniValue',
              readOnly: readOnlyMode,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 3.0),
                prefixIcon: Icon(iconName, color: iconColor),
                border: InputBorder.none,
                // hintText: 'ระบุจำนวน',
                hintStyle: TextStyle(color: iconColor),
              ),
            ),
          ],
        ),
      );
    } else {
      readOnlyMode = false;
      iconName = Icons.mode_edit;
      iconColor = Colors.grey;
      return Container(
        // decoration: MyStyle().boxLightGreen,
        // height: 35.0,
        width: MediaQuery.of(context).size.width * 0.50,
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(
          children: <Widget>[
            Padding(
              child: SpinBox(
                min: 1,
                max: 10000,
                value: (iniValue)!
                    .toDouble(), //(iniValue == 0) ? 0 : (iniValue).toInt(),
                onChanged: (changevalue) {
                  if (index == 0) {
                    setState(() {
                      qtyS = (changevalue == 0) ? 0 : (changevalue).toInt();
                    });
                  } else if (index == 1) {
                    setState(() {
                      qtyM = (changevalue == 0) ? 0 : (changevalue).toInt();
                    });
                  } else if (index == 2) {
                    setState(() {
                      qtyL = (changevalue == 0) ? 0 : (changevalue).toInt();
                    });
                  }
                },
                // decoration: InputDecoration(labelText: 'Decimals'),
                decoration: InputDecoration(
                  border: UnderlineInputBorder(), // InputBorder.none,
                ),
              ),
              padding: const EdgeInsets.all(0),
            ),
          ],
        ),
      );
    }

    // var x = (iniValue!='0')?int.tryParse(iniValue):('').toString();
    // print('iniValue ($index)>> $iniValue');
  }

  Widget showStockExpire() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.98,
      child: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.16,
            child: Text('สต๊อก :', style: MyStyle().h3StyleGray),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.19,
            child: Text(
              ' ${productAllModel!.stock}',
              style: (productAllModel!.stock.toString() != '0')
                  ? MyStyle().h3StyleGray
                  : MyStyle().h3StyleRed,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.28,
            child: Text('วันหมดอายุ :', style: MyStyle().h3StyleGray),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.28,
            child: Text(
              ' ${productAllModel!.expire}',
              style: TextStyle(
                fontSize: 16.0,
                color: (productAllModel!.expireColor == 'red')
                    ? Colors.red
                    : (productAllModel!.expireColor == 'blue')
                        ? Colors.blue.shade700
                        : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showVideo() {
    // String videoSelectCode = videoCode!;
    String videoSelectCode = productAllModel!.youtube!;
    print('videoSelectCode ====>>>>> $videoSelectCode');
    final _controllers = YoutubePlayerController(
      initialVideoId: videoSelectCode,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: true,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );

    return Column(
      children: [
        // Align(
        //   alignment: Alignment.centerLeft,
        //   // width: MediaQuery.of(context).size.width * 0.20,
        //   child: Text(
        //     'Video ',
        //     style: MyStyle().h4bStyleGray,
        //   ),
        // ),
        YoutubePlayer(
          key: ObjectKey(_controllers),
          controller: _controllers,
          actionsPadding: const EdgeInsets.only(left: 16.0),
          bottomActions: [
            CurrentPosition(),
            const SizedBox(width: 10.0),
            ProgressBar(isExpanded: true),
            const SizedBox(width: 10.0),
            RemainingDuration(),
            FullScreenButton(),
          ],
        ),
        Divider(),
      ],
    );
  }

  // Widget showVideo() {
  //   String videoSelectCode = productAllModel!.youtube!;
  //   print('videoSelectCode ====>>>>> $videoSelectCode');
  //   final _controller = YoutubePlayerController(
  //     params: YoutubePlayerParams(
  //       mute: false,
  //       showControls: true,
  //       showFullscreenButton: true,
  //     ),
  //   );
  //   // _controller.loadVideoById(...); // Auto Play
  //   // _controller.cueVideoById(...); // Manual Play
  //   // _controller.loadPlaylist(...); // Auto Play with playlist
  //   // _controller.cuePlaylist(...); // Manual Play with playlist
  //   _controller.loadVideoById(videoId: videoSelectCode);
  //   // If the requirement is just to play a single video.
  //   return YoutubePlayer(
  //     controller: _controller,
  //     aspectRatio: 16 / 9,
  //   );
  // }

  Widget showUsefor() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          // width: MediaQuery.of(context).size.width * 0.20,
          child: Text('ใช้รักษา', style: MyStyle().h4bStyleGray),
        ),
        Container(
          // width: MediaQuery.of(context).size.width * 0.75,
          child: Text(productAllModel!.usefor!, style: MyStyle().h4StyleGray),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget showMethod() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          // width: MediaQuery.of(context).size.width * 0.20,
          child: Text('วิธีการใช้', style: MyStyle().h4bStyleGray),
        ),
        Container(
          // width: MediaQuery.of(context).size.width * 0.75,
          child: Text(productAllModel!.method!, style: MyStyle().h4StyleGray),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget showDetail() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          // width: MediaQuery.of(context).size.width * 0.20,
          child: Text('รายละเอียด :', style: MyStyle().h4bStyleGray),
        ),
        Container(
          // width: MediaQuery.of(context).size.width * 0.75,
          child: Text(productAllModel!.detail!, style: MyStyle().h4StyleGray),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget salepriceinfo() {
    return Column(
      children: [
        // Align(
        //   // width: MediaQuery.of(context).size.width * 0.16,
        //   alignment: Alignment.centerLeft,
        //   child: Text(
        //     'ข้อมูลเพิ่มเติม',
        //     style: MyStyle().h3bStyleGreen,
        //   ),
        // ),
        // SizedBox(
        //   height: 10.0,
        // ),
        Container(
          width: MediaQuery.of(context).size.width * 0.99,
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.10,
                child: Text('ราคา', style: MyStyle().h4bStyleRed),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.18,
                child: Text('ป้าย :', style: MyStyle().h4bStyleGray),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.15,
                child: Text(
                  productAllModel!.pricelabel!,
                  style: MyStyle().h3bStyleGray,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.34,
                child: Text('แนะนำขายปลีก :', style: MyStyle().h4bStyleGray),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.15,
                child: Text(
                  productAllModel!.pricesale!,
                  style: MyStyle().h3bStyleGray,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget moreinfo() {
    return Column(
      children: [
        // Align(
        //   // width: MediaQuery.of(context).size.width * 0.16,
        //   alignment: Alignment.centerLeft,
        //   child: Text(
        //     'ข้อมูลเพิ่มเติม',
        //     style: MyStyle().h3bStyleGreen,
        //   ),
        // ),
        Container(
          child: productAllModel!.usefor == '' ? Container() : showUsefor(),
        ),
        Container(
          child: productAllModel!.method == '' ? Container() : showMethod(),
        ),
        Container(
          child: productAllModel!.detail == '' ? Container() : showDetail(),
        ),
      ],
    );
  }

  Widget showPrice() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      height: (53 * unitSizeModels!.length.toDouble()),
      // color: Colors.grey,
      child: ListView.builder(
        itemCount: unitSizeModels!.length,
        itemBuilder: (BuildContext buildContext, int index) {
          print('price >> ' + unitSizeModels![index].price.toString());
          return showChoosePricePackage(index);
          // return showChoosePricePackage(index);
        },
      ),
    );
  }

  Widget relate() {
    print(
      'relateslideshowLists!.length (Widget relate)>> ' +
          relateslideshowLists!.length.toString(),
    );
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.25,
        child: relateslideshowLists!.isEmpty
            ? myCircularProgress()
            : showCarouseSliderRelate(),
      ),
    );
  }

  Widget mySizebox() {
    return SizedBox(width: 10.0, height: 30.0);
  }

  Widget headTitle(String string, IconData iconData) {
    // Widget  แทน object ประเภทไดก็ได้
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          Icon(iconData, size: 18.0, color: MyStyle().textColor),
          mySizebox(),
          Text(
            string,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MyStyle().textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> readCart() async {
    print('Here is readcart function');

    amontCart = 0;
    String memberId = myUserModel!.id.toString();
    String url =
        'https://www.ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId&screen=detaiil';

    print('url Detail =====>>>>>>>> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    for (var map in cartList) {
      // setState(() {
      amontCart = amontCart! + 1;
      // });
    }
    setState(() {
      amontCart;
    });
  }

  Widget showCart() {
    return GestureDetector(
      onTap: () {
        routeToDetailCart();
      },
      child: Container(
        margin: EdgeInsets.only(top: 5.0, right: 5.0),
        width: 32.0,
        height: 32.0,
        child: Stack(
          children: <Widget>[
            Image.asset('images/shopping_cart.png'),
            Text(
              ' $amontCart ',
              style: TextStyle(
                backgroundColor: Colors.red.shade600,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void routeToDetailCart() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return DetailCart(userModel: myUserModel);
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }


  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return ListProduct(index: index, userModel: myUserModel!);
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  Widget stylishBottomBar() {
    int? unread =
        myUserModel!.lastNewsId!.toInt() - myUserModel!.lastNewsOpen!.toInt();
    return StylishBottomBar(
      option: AnimatedBarOptions(iconStyle: IconStyle.animated, opacity: 0.3),
      items: [
        BottomBarItem(
          icon: const Icon(Icons.home),
          title: const Text('Home'),
          backgroundColor: Colors.blue,
          // selectedIcon: const Icon(Icons.home),
        ),
        BottomBarItem(
          icon: const Icon(Icons.medical_services),
          title: const Text('Medicine'),
          backgroundColor: Colors.green,
        ),
        BottomBarItem(
          icon: const Icon(Icons.favorite),
          title: const Text('Favorite'),
          backgroundColor: Colors.red,
        ),
        BottomBarItem(
          icon: const Icon(Icons.shopping_cart),
          title: const Text('Cart'),
          backgroundColor: Colors.brown,
        ),
      ],
      // fabLocation: StylishBarFabLocation.end,
      hasNotch: true,
      currentIndex: selectIndex,
      onTap: (index) {
        setState(() {
          selectIndex = index;
          // controller.jumpToPage(index);
          if (index == 0) {
            MaterialPageRoute route = MaterialPageRoute(
              builder: (value) => MyService(userModel: myUserModel),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          } else if (index == 1) {
            routeToListProduct(0);
          } else if (index == 2) {
            routeToListProductfav(0);
          } else if (index == 3) {
            routeToDetailCart();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('productAllModel (build)>> $productAllModel');
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[showCart()],
        backgroundColor: MyStyle().bgColor,
        title: Text('ข้อมูลสินค้า', style: TextStyle(color: Colors.white)),
      ),
      body: productAllModel == null ? showProgress() : showDetailList(),
      bottomNavigationBar: stylishBottomBar(), //showBottomBarNav
    );
  }

  Widget showProgress() {
    return Center(child: CircularProgressIndicator());
  }

  Widget addButtonfix() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                // color: MyStyle().mainColor,
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  String? productID = id;
                  String? memberID = myUserModel!.id.toString();

                  if ((qtyS == 0 || qtyS == null) &&
                      (qtyM == 0 || qtyM == null) &&
                      (qtyL == 0 || qtyL == null)) {
                    normalDialog(context, 'แจ้งเตือน', 'กรุณาระบุจำนวน');
                  }

                  if (qtyS != 0) {
                    String unitSize = 's';
                    print(
                      'productID = $productID, memberID=$memberID, unitSize=s, QTY=$qtyS',
                    );
                    addCart(productID!, unitSize, qtyS!, memberID);
                  }
                  if (qtyM != 0) {
                    String unitSize = 'm';
                    print(
                      'productID = $productID, memberID=$memberID, unitSize=m, QTY=$qtyM',
                    );
                    addCart(productID!, unitSize, qtyM!, memberID);
                  }
                  if (qtyL != 0) {
                    String unitSize = 'l';
                    print(
                      'productID = $productID, memberID=$memberID, unitSize=l, QTY=$qtyL',
                    );
                    addCart(productID!, unitSize, qtyL!, memberID);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget addButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                // color: MyStyle().mainColor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  String? productID = id;
                  String? memberID = myUserModel!.id.toString();

                  if ((qtyS == 0 || qtyS == null) &&
                      (qtyM == 0 || qtyM == null) &&
                      (qtyL == 0 || qtyL == null)) {
                    normalDialog(context, 'แจ้งเตือน', 'กรุณาระบุจำนวน');
                  }

                  if (qtyS != 0) {
                    String unitSize = 's';
                    print(
                      'productID = $productID, memberID=$memberID, unitSize=s, QTY=$qtyS',
                    );
                    addCart(productID!, unitSize, qtyS!, memberID);
                  }
                  if (qtyM != 0) {
                    String unitSize = 'm';
                    print(
                      'productID = $productID, memberID=$memberID, unitSize=m, QTY=$qtyM',
                    );
                    addCart(productID!, unitSize, qtyM!, memberID);
                  }
                  if (qtyL != 0) {
                    String unitSize = 'l';
                    print(
                      'productID = $productID, memberID=$memberID, unitSize=l, QTY=$qtyL',
                    );
                    addCart(productID!, unitSize, qtyL!, memberID);
                  }
                },
              ),
            ),
            SizedBox(width: 10.0, height: (myUserModel!.msg == '') ? 0 : 105.0),
          ],
        ),
      ],
    );
  }

  Future<void> addCart(
    String productID,
    String unitSize,
    int qTY,
    String memberID,
  ) async {
    String url =
        'https://www.ptnpharma.com/apishop/json_savemycart.php?productID=$productID&unitSize=$unitSize&QTY=$qTY&memberId=$memberID';
    print('urlAddcart = $url');
    await http.get(Uri.parse(url)).then((response) {});
    print('upload ok');

    Navigator.pop(context, true);
  }

  Widget showDetailList() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        side: BorderSide(width: 5, color: Colors.grey.shade200),
      ),
      child: Stack(
        children: <Widget>[
          showController(),
          MyStyle().mySizebox(),
          addButton(),
          MyStyle().mySizebox(),
        ],
      ),
    );
  }

  ListView showController() {
    // String intVL = '10';
    return ListView(
      padding: EdgeInsets.all(10.0),
      children: <Widget>[
        favButton(),
        showTitle(),
        (productAllModel?.hilight == '') ? Container() : showHilight(),
        (productAllModel?.extrapoint == '') ? Container() : showExtrapoint(),
        showTag(),
        showStockExpire(),
        Divider(),
        showPrice(),
        Divider(), //MyStyle().mySizebox(),
        (slideshowLists!.length > 0) ? showCarouseSlideshow() : Container(),
        (productAllModel?.youtube == '-') ? Container() : showVideo(),
        salepriceinfo(),
        moreinfo(),
        headTitle('สินค้าที่เกี่ยวข้อง', Icons.thumb_up),
        relate(),
        MyStyle().mySizebox(),
      ],
    );
  }
}
