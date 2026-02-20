import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'my_service.dart';
import 'detail.dart';
import 'detail_cart.dart';
import 'package:ptncenter/widget/home.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:toast/toast.dart';

class ListProduct extends StatefulWidget {
  final int? index;
  final UserModel? userModel;
  final int? cate;
  final String? cateName;
  final String? searchStr;
  String? _result = '';

  ListProduct(
      {Key? key,
      this.index,
      this.userModel,
      this.cate,
      this.cateName,
      this.searchStr})
      : super(key: key);

  @override
  _ListProductState createState() => _ListProductState();
}

//class
class Debouncer {
  // delay เวลาให้มีการหน่วง เมื่อ key searchview

  //Explicit
  final int? milliseconds;
  VoidCallback? action;
  Timer? timer;

  //constructor
  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(Duration(microseconds: milliseconds!), action);
  }
}

class _ListProductState extends State<ListProduct> {
  // Explicit
  int? myIndex;
  List<ProductAllModel>? productAllModels = []; // []; // set array
  List<ProductAllModel>? filterProductAllModels = []; // []; //

  int? amontCart = 0;
  UserModel? myUserModel;
  String? searchString = '';
  String? lastItemName = '';

  int? amountListView = 6;
  int? page = 1;

  String? qrString;
  int? myCate = 0;
  String? myCateName = '';
  String? mysearchString = '';
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 300); // ตั้งค่า เวลาที่จะ delay
  bool statusStart = true;

  int? currentIndex;

  String? creditterm = '-';
  String? financialamount = '-';
  String? contactAdmin = '-';


  // List<ProductAllModel> productAllModels_buffer = List(); // []; //

  var _controller = TextEditingController();

  int substart = 0;
  bool visible = true;
  int selectIndex = 1;
  // bool creditAlert = false; 

  // Method
  @override
  void initState() {
    // auto load
    super.initState();

    myIndex = widget.index;
    myUserModel = widget.userModel;
    myCate = widget.cate;
    myCateName = widget.cateName;
    mysearchString = widget.searchStr;

    if (mysearchString != null) {
      searchString = mysearchString;
    } else {
      searchString = '';
    }

    if (myIndex == 0) {
      currentIndex = 1;
    } else if (myIndex == 1) {
      currentIndex = 4;
    } else if (myIndex == 2) {
      currentIndex = 2;
    } else if (myIndex == 3) {
      currentIndex = 3;
    } else if (myIndex == 4) {
      currentIndex = 1;
    } else if (myIndex == 5) {
      currentIndex = 1;
    } else if (myIndex == 6) {
      currentIndex = 1;
    } else if (myIndex == 7) {
      currentIndex = 1;
    } else if (myIndex == 8) {
      currentIndex = 1;
    }

    createController(); // เมื่อ scroll to bottom

    setState(() {
      readData(); // read  ข้อมูลมาแสดง
      readCart();
      loadJsonAsset();
    });



    // String? creditterm = myUserModel!.credittermAlert;
    // String? financialamount = myUserModel!.financialamountAlert;
    // String? contactAdmin = myUserModel!.contactAdminAlert;

    // if(creditAlert == false){
    //   if (creditterm !='-' || financialamount !='-' || contactAdmin !='-') {
    //         Future.delayed(Duration.zero, () => showCreditAlertDialog(context));
    //         creditAlert = true;
    //   }
    // }
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          page = page! + 1;
          readData();
          print('in the end');
        }
      } else {
        setState(() {
          visible = false;
        });
        // Loader.show(context,
        //     isAppbarOverlay: false,
        //     overlayFromTop: 100,
        //     progressIndicator: CircularProgressIndicator(),
        //     themeData: Theme.of(context).copyWith(
        //         colorScheme: ColorScheme.fromSwatch()
        //             .copyWith(secondary: Colors.black38)),
        //     overlayColor: Color(0x99E8EAF6));

        // ///loader hide after 3 seconds
        // Future.delayed(Duration(seconds: 3), () {
        //   Loader.hide();
        // });
      }
    });
  }

/************************************** */
  Future<void> readCart() async {
    print('Here is readcart function');

    amontCart = 0;
    lastItemName = '';
    String memberId = myUserModel!.id.toString();
    String url =
        'https://www.ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId&screen=listproduct';

    print('url Detail =====>>>>>>>> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);

    final Map<String, dynamic>  myCredit = result['data'];
    creditterm      = myCredit['credittermAlert'];
    financialamount = myCredit['financialamountAlert'];
    contactAdmin    = myCredit['contactAdminAlert'];
    ToastContext().init(context);
    showCreditAlertMessage();

    var cartList = result['cart'];
    for (var map in cartList) {
      lastItemName = map['title'];
      amontCart = amontCart! + 1;
    }
    setState(() {
      lastItemName;
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
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return DetailCart(
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Future<void> readData() async {
    // List<ProductAllModel> productAllModels_buffer = List(); // []; //
    // String url = MyStyle().readAllProduct;
    print('Here is readdata function');
    setState(() {
      visible = true;
    });

    String memberId = myUserModel!.id.toString();
    String url =
        'https://www.ptnpharma.com/apishop/json_productlist.php?memberId=$memberId&searchKey=$searchString&page=$page';
    if (myIndex != 0) {
      if (myIndex == 1 || myIndex == 2 || myIndex == 3) {
        url =
            'https://www.ptnpharma.com/apishop/json_productlist.php?memberId=$memberId&searchKey=$searchString&product_mode=$myIndex&page=$page';
      } else if (myIndex == 4) {
        url =
            'https://www.ptnpharma.com/apishop/json_productnotreceive.php?memberId=$memberId&page=$page';
      } else if (myIndex == 5) {
        url =
            'https://www.ptnpharma.com/apishop/json_productlist.php?memberId=$memberId&cate_id=$myCate&page=$page';
      } else if (myIndex == 7) {
        url =
            'https://www.ptnpharma.com/apishop/json_productbestseller.php?memberId=$memberId&page=$page';
      } else if (myIndex == 8) {
        url =
            'https://www.ptnpharma.com/apishop/json_productbestintrend.php?memberId=$memberId&page=$page';
      }
    }

    // url = '${MyStyle().readProductWhereMode}$myIndex';
    print("URL = $url");

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemProducts = result['itemsProduct'];
    // print('itemProducts >> ${itemProducts}');
    int i = 0;
    // print('Start >> ${filterProductAllModels.length}');
    // int s = (filterProductAllModels.length);
    // if (filterProductAllModels.length == 0)
    //   int substart = 0;
    // else
    //   int substart = 20;

    int len = (filterProductAllModels!.length);

    for (var map in itemProducts) {
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);

      setState(() {
        productAllModels!.add(productAllModel);
        filterProductAllModels = productAllModels;
      });
      print(
          ' >> ${len} =>($i)  ${productAllModel.id}  || ${productAllModels![i].title} (${filterProductAllModels![i].itemincartSunit}) <<  (${productAllModel.itemincartSunit})');

      i = i + 1;
    }
    setState(() {
      visible = false;
    });
  }

  Future<void>? showCreditAlertMessage() {
    print('CREDIT CHECK > $creditterm + $financialamount + $contactAdmin');
    if (creditterm !='-' || financialamount !='-' || contactAdmin !='-') {
        var txtCreditTitle =  '';
        if(creditterm !='-' )
          txtCreditTitle =  'ท่านมียอดค้างชำระเกินกำหนด';
        else if(financialamount !='-' )
          txtCreditTitle =  'ท่านมียอดค้างชำระเกินวงเงินที่กำหนด';
        else if(contactAdmin !='-' )
          txtCreditTitle =  'กรุณาติดต่อผู้ดูแลระบบ';

      Toast.show(txtCreditTitle,
          duration: 5,// Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: const Color.fromARGB(255, 243, 88, 61));
    }
  }

  // void showCreditAlertDialog(BuildContext context) {
  //   String? creditterm = myUserModel!.credittermAlert;
  //   String? financialamount = myUserModel!.financialamountAlert;
  //   String? contactAdmin = myUserModel!.contactAdminAlert;

  //   if (creditterm !='-' || financialamount !='-' || contactAdmin !='-') {
  //       var txtCreditTitle =  '';
  //       if(creditterm !='-' )
  //         txtCreditTitle =  'ท่านมียอดค้างชำระเกินกำหนด';
  //       else if(financialamount !='-' )
  //         txtCreditTitle =  'ท่านมียอดค้างชำระเกินวงเงินที่กำหนด';
  //       else if(contactAdmin !='-' )
  //         txtCreditTitle =  'กรุณาติดต่อผู้ดูแลระบบ';


  //       AwesomeDialog(
  //         context: context,
  //         headerAnimationLoop: false,
  //         dialogType: DialogType.warning,
  //         autoHide: const Duration(seconds: 5),
  //         title:  txtCreditTitle,
  //         desc: 'กรุณาชำระรายการหรือติดต่อเจ้าหน้าที่ ',
  //         // btnCancelOnPress: () {
  //         //   debugPrint('OnClcik');
  //         // },

  //         btnOkText: ('ok'),
  //         btnOkColor: const Color.fromARGB(255, 252, 183, 36),
  //         btnOkOnPress: () {
  //           debugPrint('OnClcik');
  //         },
  //         btnOkIcon: Icons.check_circle,

  //       ).show();
  //   }
  // }

  Future<void> updateDatalist(index) async {
    // List<ProductAllModel> productAllModels_buffer = List(); // []; //
    // String url = MyStyle().readAllProduct;
    print('Here is updateDatalist function');

    String? memberId = myUserModel!.id.toString();
    int? productID = filterProductAllModels![index].id!;
    String? url =
        'https://www.ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    print("URL update item = $url");
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    for (var mapCart in cartList) {
      if (mapCart['id'] == productID) {
        setState(() {
          if (mapCart['price_list'].containsKey('s')) {
            filterProductAllModels![index].itemincartSunit =
                mapCart['price_list']['s']['quantity'];
          }
          if (mapCart['price_list'].containsKey('m')) {
            filterProductAllModels![index].itemincartMunit =
                mapCart['price_list']['m']['quantity'];
          }
          if (mapCart['price_list'].containsKey('l')) {
            filterProductAllModels![index].itemincartLunit =
                mapCart['price_list']['l']['quantity'];
          }
        });
      }
    }
  }

  Widget showName(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.7 - 10,
          child: Text(
            filterProductAllModels![index].title!,
            style: MyStyle().h3Style,
          ),
        ),
      ],
    );
  }

  Widget showHilight(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.7 - 10,
          child: Text(
            filterProductAllModels![index].hilight!,
            style: MyStyle().h3StyleRed,
          ),
        ),
      ],
    );
  }

  Widget showExtrapoint(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.7 - 10,
          child: Text(
            filterProductAllModels![index].extrapoint!,
            style: MyStyle().h3StyleOrange,
          ),
        ),
      ],
    );
  }

  Widget showStock(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.12,
          child: Text(
            'Stock:',
            style: MyStyle().h4StyleGray,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.12,
          child: Text(
            ' ${filterProductAllModels![index].stock}',
            style: (filterProductAllModels![index].stock.toString() != '0')
                ? MyStyle().h4StyleGray
                : MyStyle().h4StyleRed,
          ),
        ),
        showIncart(index),
      ],
    );
    // return Text('na');
  }

  Widget showIncart(int index) {
    return Row(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width * 0.13,
        child: Text(
          (filterProductAllModels![index].itemincartSunit != '0' ||
                  filterProductAllModels![index].itemincartMunit != '0' ||
                  filterProductAllModels![index].itemincartLunit != '0')
              ? 'ตะกร้า:'
              : '',
          style: MyStyle().h4StyleRed,
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Text(
          ((filterProductAllModels![index].itemincartSunit != '0')
                  ? '${filterProductAllModels![index].itemincartSunit} ${filterProductAllModels![index].itemSunit}  '
                  : '') +
              ((filterProductAllModels![index].itemincartMunit != '0')
                  ? '${filterProductAllModels![index].itemincartMunit} ${filterProductAllModels![index].itemMunit}  '
                  : '') +
              ((filterProductAllModels![index].itemincartLunit != '0')
                  ? '${filterProductAllModels![index].itemincartLunit} ${filterProductAllModels![index].itemLunit}'
                  : ''),
          style: MyStyle().h4StyleRed,
        ),
      ),
    ]);
  }

  Widget showPrice(int index) {
    String txtShowPrice;
    String txtShowUnit;
    String txtPriceUnit = '';
    if (filterProductAllModels![index].itemSprice.toString() != '0') {
      txtShowPrice = filterProductAllModels![index].itemSprice.toString();
      txtShowUnit = filterProductAllModels![index].itemSunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '')
        txtPriceUnit = '$txtPriceUnit' + " [$txtShowPrice/$txtShowUnit] ";
    }
    if (filterProductAllModels![index].itemMprice.toString() != '0') {
      txtShowPrice = filterProductAllModels![index].itemMprice.toString();
      txtShowUnit = filterProductAllModels![index].itemMunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '')
        txtPriceUnit = '$txtPriceUnit' + " [$txtShowPrice/$txtShowUnit] ";
    }
    if (filterProductAllModels![index].itemLprice.toString() != '0') {
      txtShowPrice = filterProductAllModels![index].itemLprice.toString();
      txtShowUnit = filterProductAllModels![index].itemLunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '')
        txtPriceUnit = '$txtPriceUnit' + " [$txtShowPrice/$txtShowUnit] ";
    }

    return Row(
      children: <Widget>[
        Text(
          '$txtPriceUnit',
          style: TextStyle(
            fontSize: 16.0,
            //  fontWeight: FontWeight.bold,
            color: Color.fromRGBO(50, 117, 168, 1.0),
          ), // h3StyleGray
        ),
      ],
    );
    // return Text('na');
  }

  Widget showText(int index) {
    return Container(
      padding: EdgeInsets.only(left: 5.0, right: 2.0),
      // height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.73,
      child: Container(
        padding: EdgeInsets.only(bottom: 5.0, top: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            showName(index),
            (filterProductAllModels![index].hilight != '')
                ? showHilight(index)
                : Container(),
            (filterProductAllModels![index].extrapoint != '')
                ? showExtrapoint(index)
                : Container(),
            showPrice(index),
            showStock(index),
          ],
        ),
      ),
    );
  }

  Widget showImage(int index) {
    return Container(
      padding: EdgeInsets.all(5.0),
      // width: MediaQuery.of(context).size.width * 0.25,
      // child: Image.network(filterProductAllModels![index].photo),
      width: 80,
      height: 80,
      decoration: new BoxDecoration(
          image: new DecorationImage(
        fit: BoxFit.cover,
        alignment: FractionalOffset.topCenter,
        image: new NetworkImage(filterProductAllModels![index].photo!),
      )),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.green.shade300),
      borderRadius: BorderRadius.all(
        Radius.circular(5.0), //                 <--- border radius here
      ),
      // border: Border(
      //   top: BorderSide(
      //     color: Colors.blueGrey.shade100,
      //     width: 1.0,
      //   ),
      // bottom: BorderSide(
      //   color: Colors.blueGrey.shade100,
      //   width: 1.0,
      // ),
      // ),
    );
  }

  Widget loading() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: visible,
      // child: Loading(indicator: BallPulseIndicator(), size: 10.0),
      child: LoadingIndicator(
          indicatorType: Indicator.ballPulse,

          /// Required, The loading type of the widget
          colors: const [Colors.red],

          /// Optional, The color collections
          strokeWidth: 2,

          /// Optional, The stroke of the line, only applicable to widget which contains line
          backgroundColor: Colors.black,

          /// Optional, Background of the widget
          pathBackgroundColor: Colors.black

          /// Optional, the stroke backgroundColor
          ),
    );
  }

  Widget myCircularProgress() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: visible,
      // child: Center(child: CupertinoActivityIndicator()),
      child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.green,
        size: 20,
      )),
    );
  }

  Widget showProductItem() {
    int perpage = 15;
    bool loadingIcon = false;

    // int i = 0;
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: productAllModels!.length,
        itemBuilder: (BuildContext buildContext, int index) {
          // print('perpage >> ${perpage} || index >> $index');

          if ((index + 1) % perpage == 0) {
            loadingIcon = true;
          } else {
            loadingIcon = false;
          }

          if (loadingIcon == true) {
            // return CupertinoActivityIndicator();
            return Column(
              children: [
                GestureDetector(
                  child: Container(
                    child: Card(
                      child: Container(
                        decoration: myBoxDecoration(),
                        padding: EdgeInsets.only(top: 0.5),
                        child: Row(
                          children: <Widget>[
                            showImage(index),
                            showText(index),
                          ],
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    print(
                        'index select item => ${filterProductAllModels![index]}');
                    MaterialPageRoute materialPageRoute =
                        MaterialPageRoute(builder: (BuildContext buildContext) {
                      return Detail(
                        productAllModel: filterProductAllModels![index],
                        userModel: myUserModel,
                      );
                    });

                    Navigator.of(context)
                        .push(materialPageRoute)
                        .then((value) => setState(() {
                              readCart();
                              updateDatalist(index);
                            }));
                    // Navigator.of(context).push(materialPageRoute);
                  },
                ),
                myCircularProgress(),
              ],
            );
          }

          return GestureDetector(
            child: Container(
              child: Card(
                child: Container(
                  decoration: myBoxDecoration(),
                  padding: EdgeInsets.only(top: 0.5),
                  child: Row(
                    children: <Widget>[
                      showImage(index),
                      showText(index),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () {
              print('index select item => ${filterProductAllModels![index]}');
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return Detail(
                  productAllModel: filterProductAllModels![index],
                  userModel: myUserModel,
                );
              });

              Navigator.of(context)
                  .push(materialPageRoute)
                  .then((value) => setState(() {
                        readCart();
                        updateDatalist(index);
                      }));
              // Navigator.of(context).push(materialPageRoute);
            },
          );
        },
      ),
    );
  }

  Widget showContent() {
    bool? searchKey;
    if (searchString != '') {
      searchKey = true;
    }

    if (filterProductAllModels!.length == 0) {
      if (myIndex != 4) {
        return showProgressIndicate(searchKey);
      } else {
        return Center(child: Text(''));
      }
    } else {
      return showProductItem();
    }
  }

  Widget showProgressIndicate(searchKey) {
    // print('searchKey >> $searchKey');

    if (searchKey == true) {
      if (filterProductAllModels!.length == 0) {
        return Center(child: Text('')); // Search not found
      } else {
        return Center(child: Text(''));
      }
    } else {
      return Center(child: CircularProgressIndicator());
    }
    /*
    return Center(
      child:
          statusStart ? CircularProgressIndicator() : Text('Search not found'),
    );
    */
  }

  /*
  Widget myLayout() {
    return Column(
      children: <Widget>[
        searchForm(),
        showProductItem(),
      ],
    );
  }
  */

  Widget lastItemInCart() {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(
            'รายการล่าสุดในตะกร้า',
            style: MyStyle().h3bStyle,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(lastItemName.toString(),
              style: TextStyle(
                fontSize: 14.0,
                // fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0x00, 0x73, 0x26),
              )),
        ),
      ],
    );
  }

  // Future<void> readQRcode() async {
  //   try {
  //     var qrString = await BarcodeScanner.scan();
  //     print('QR code = $qrString');
  //     if (qrString != null) {
  //       decodeQRcode(qrString);
  //     }
  //   } catch (e) {
  //     print('e = $e');
  //   }
  // }

  Future<void> readQRcodePreview() async {
    try {
      // final qrScanString = await Navigator.push(this.context,
      //     MaterialPageRoute(builder: (context) => ScanPreviewPage()));
      var qrScanString;
      print('Before scan');
      qrScanString = await BarcodeScanner.scan();
      print('After scan');
      print('scanl result: $qrScanString');
      qrString = qrScanString.rawContent;
      if (qrString != null) {
        decodeQRcode(qrString);
      }
      // setState(() => scanResult = qrScanString);
    } on PlatformException catch (e) {
      print('e = $e');
    }
  }

Future<void> decodeQRcode(var code) async {
    try {
      if(code != '' && code != null){
        String url =
            'https://www.ptnpharma.com/apishop/json_productlist.php?bqcode=$code';
            print('url === (decodeQRcode) >>>> $url');
        http.Response response = await http.get(Uri.parse(url));
        var result = json.decode(response.body);
        // print('result (decodeQRcode) ===>>>> $result');

        int status = result['status'];
        print('status ===>>> $status');
        if (status == 0) {
          normalDialog(context, 'Not found', 'ไม่พบ code :: $code ในระบบ');
        } else {
          var itemProducts = result['itemsProduct'];
          for (var map in itemProducts) {
            // print('map ===*******>>>> $map');

            ProductAllModel productAllModel = ProductAllModel.fromJson(map);
            MaterialPageRoute route = MaterialPageRoute(
              builder: (BuildContext context) => Detail(
                userModel: myUserModel,
                productAllModel: productAllModel,
              ),
            );

            Navigator.of(context).push(route).then((value) => readCart());
          }
        }
      }
    } catch (e) {}
  }

  List<String> jsonSuggestMed =[];
  Future<void> loadJsonAsset() async {
    String url = 'https://ptnpharma.com/jsonData/medicine_unit.json';
    http.Response response = await http.get(Uri.parse(url));
    var result =  json.decode(response.body.toLowerCase()); // json.decode(utf8.decode(response.bodyBytes).toLowerCase());
    for (var map in result) {
      jsonSuggestMed.add(map['name']+"|"+map['code']);   // map['code']+"|"+map['name']
    }
    setState(() {
       jsonSuggestMed;
    });
  }

  Widget searchForm() {
    
    List<String> listjsonSuggestMed = jsonSuggestMed;
    print('listjsonSuggestMed > $listjsonSuggestMed');
    // const List<String> _kOptions = jsonSuggestMed;
    return Column(

      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(5.00),
              width: MediaQuery.of(context).size.width * 0.85,
              child: Autocomplete<String>(
                 optionsMaxHeight : 700.00,
                 fieldViewBuilder:
                    (context, textEditingController, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    onChanged: (String string) {
                      searchString = string.trim();
                    },
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      setState(() {
                        page = 1;
                        myIndex = 0;
                        productAllModels!.clear();
                        readData();
                      });
                    },
                     decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'ค้นหาสินค้า',
                      suffixIcon: IconButton(
                        onPressed: () => textEditingController.clear(),
                        icon: Icon(Icons.clear),
                      ),
                    ),
                  );
                },  
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return listjsonSuggestMed.where((String option) {
                    return option.contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {    // onSelected: (String selection) {
                    var parts = selection.split('|');
                    var prefix = parts[0].trim();                 // prefix: "date"
                    searchString = 'x|'+parts.sublist(1).join('|').trim();
                    setState(() {
                      page = 1;
                      myIndex = 0;
                      productAllModels!.clear();
                      readData();
                    });
                
                },
              ),
            ),
             GestureDetector(
              onTap: () {
                print('You click barcode scan');
                readQRcodePreview();
              }, // Image tapped
              // padding: EdgeInsets.only(left: 5.00,right: 5.00),
              // width: MediaQuery.of(context).size.width * 0.15,
              child: Image.asset('images/icon_barcode.png',
                  width: 50.0, height: 50.0),
            ),
          ],
        ),
        // Container(
        //   decoration: MyStyle().boxLightGray,
        //   // color: Colors.grey,
        //   padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
        //   child: ListTile(
        //     trailing: Container(
        //       width: 45.0,
        //       child: Image.asset('images/icon_barcode.png'),
        //     ),
        //     onTap: () {
        //       print('You click barcode scan');
        //       // readQRcode();
        //       readQRcodePreview();
        //       // scanBarcodeNormal();
        //     },
        //     title: TextField(
        //       controller: _controller,
        //       textAlign: TextAlign.center,
        //       scrollPadding: EdgeInsets.all(1.00),
        //       style: TextStyle(
        //           color: Colors.blue.shade900,
        //           fontWeight: FontWeight.w300,
        //           fontSize: 18.00),
        //       decoration: InputDecoration(
        //         border: OutlineInputBorder(),
        //         hintText: 'ค้นหาสินค้า',
        //         suffixIcon: IconButton(
        //           onPressed: () => _controller.clear(),
        //           icon: Icon(Icons.clear),
        //         ),
        //       ),
        //       onChanged: (String string) {
        //         searchString = string.trim();
        //       },
        //       textInputAction: TextInputAction.search,
        //       onSubmitted: (value) {
        //         setState(() {
        //           page = 1;
        //           myIndex = 0;
        //           productAllModels!.clear();
        //           readData();
        //         });
        //       },
        //     ),
        //   ),
        // ),
      ],
    );
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index,
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToListProductfav(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProductfav(
        index: index,
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget stylishBottomBar() {
    int? unread =
        myUserModel!.lastNewsId!.toInt() - myUserModel!.lastNewsOpen!.toInt();
    return StylishBottomBar(
      option: AnimatedBarOptions(
        iconStyle: IconStyle.animated,
        opacity: 0.3,
      ),
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
              builder: (value) => MyService(
                userModel: myUserModel,
              ),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          } else if (index == 1) {
            routeToListProduct(0);
          } else if (index == 2) {
            routeToListProductfav(index);
          } else if (index == 3) {
            routeToDetailCart();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String txtheader = '';
    if (myIndex != 0) {
      if (myIndex == 1) {
        txtheader = 'สินค้าใหม่';
      } else if (myIndex == 2) {
        txtheader = 'สินค้าโปรโมชัน';
      } else if (myIndex == 3) {
        txtheader = 'สินค้าจะปรับราคา';
      } else if (myIndex == 4) {
        txtheader = 'สินค้าที่เคยสั่งแล้วไม่ได้รับ';
      } else if (myIndex == 5) {
        txtheader = myCateName!;
      } else if (myIndex == 6) {
        // searchString = Uri.decodeFull(searchString);
        // searchString = json.decode(searchString);
        txtheader = myCateName!;
        // txtheader = 'รายการสินค้า';
      } else if (myIndex == 7) {
        txtheader = 'สินค้าขายดี';
      } else if (myIndex == 8) {
        txtheader = 'สินค้า Intrend';
      }
    } else {
      txtheader = 'รายการสินค้า';
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: MyStyle().bgColor,
        title: Text(txtheader, style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          showCart(),
        ],
      ),

      body: Column(
        children: <Widget>[
          searchForm(),
          lastItemInCart(),
          showContent(),
        ],
      ),
      bottomNavigationBar: stylishBottomBar(), //showBottomBarNav
    );
  }
}

class ScanPreviewPage extends StatefulWidget {
  @override
  _ScanPreviewPageState createState() => _ScanPreviewPageState();
}

class _ScanPreviewPageState extends State<ScanPreviewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PTN Pharma'),
          backgroundColor: MyStyle().bgColor,
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          // child: ScanPreviewWidget(
          //   onScanResult: (result) {
          //     debugPrint('scan result: $result');
          //     Navigator.pop(context, result);
          //   },
          // ),
        ),
      ),
    );
  }
}
