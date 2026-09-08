import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'detail.dart';
import 'detail_cart.dart';

import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import 'my_service.dart';

import 'package:loading_indicator/loading_indicator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ptncenter/utility/qr_scan_mixins.dart';
import 'package:ptncenter/widget/product_list_item_card.dart';

// import 'package:scan_preview/scan_preview_widget.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:loading/loading.dart';

// import 'package:loading/indicator/ball_pulse_indicator.dart';

class ListProductfav extends StatefulWidget {
  final int? index;
  final UserModel? userModel;
  final int? cate;
  final String? cateName;

  const ListProductfav(
      {super.key, this.index, this.userModel, this.cate, this.cateName});

  @override
  _ListProductfavState createState() => _ListProductfavState();
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

class _ListProductfavState extends State<ListProductfav>
    with ProductBarcodeScannerMixin<ListProductfav> {
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

  int? myCate = 0;
  String? myCateName = '';
  ScrollController? scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 300); // ตั้งค่า เวลาที่จะ delay
  bool? statusStart = true;

  int? currentIndex = 1;
  int selectIndex = 2;

  // List<ProductAllModel> productAllModels_buffer = List(); // []; //

  final _controller = TextEditingController();

  int substart = 0;
  bool visible = true;

  // Method
  @override
  void initState() {
    // auto load
    super.initState();

    myIndex = widget.index;
    myUserModel = widget.userModel;
    myCate = widget.cate;
    myCateName = widget.cateName;

    createController(); // เมื่อ scroll to bottom

    setState(() {
      readData(); // read  ข้อมูลมาแสดง
      readCart();
    });
  }

  void createController() {
    scrollController!.addListener(() {
      if (scrollController!.position.atEdge) {
        if (scrollController!.position.pixels ==
            scrollController!.position.maxScrollExtent) {
          page = page! + 1;
          readData();
        }
      } else {
        setState(() {
          visible = false;
        });
      }
    });
  }

/// ************************************
  Future<void> readCart() async {

    amontCart = 0;
    lastItemName = '';
    String memberId = myUserModel!.id.toString();
    String url =
        '${MyStyle().serverName}/json_loadmycart.php?memberId=$memberId&screen=listproductfav';


    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    for (var map in cartList) {
      lastItemName = map['title'];
      // setState(() {
      amontCart = amontCart! + 1;
      // });
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
    setState(() {
      visible = true;
    });

    String memberId = myUserModel!.id.toString();
    String url =
        '${MyStyle().serverName}/json_productfavoritelist.php?memberId=$memberId&searchKey=$searchString&page=$page';

    // url = '${MyStyle().readProductWhereMode}$myIndex';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemProductfavs = result['itemsProduct'];
    // print('itemProducts >> ${itemProducts}');
    int i = 0;
    // print('Start >> ${filterProductAllModels.length}');
    // int s = (filterProductAllModels.length);
    // if (filterProductAllModels.length == 0)
    //   int substart = 0;
    // else
    //   int substart = 20;

    for (var map in itemProductfavs) {
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);

      setState(() {
        productAllModels!.add(productAllModel);
        filterProductAllModels = productAllModels;
      });

      i = i + 1;
    }
    setState(() {
      visible = false;
    });
  }

  Future<void> updateDatalist(index) async {
    // List<ProductAllModel> productAllModels_buffer = List(); // []; //
    // String url = MyStyle().readAllProduct;

    String? memberId = myUserModel!.id.toString();
    int? productID = filterProductAllModels![index].id!;
    String? url =
        '${MyStyle().serverName}/json_loadmycart.php?memberId=$memberId';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];

    Map<String, dynamic>? mapCart;
    for (var m in cartList) {
      if (m['id'] == productID) {
        mapCart = m;
        break;
      }
    }

    // ถ้าไม่พบสินค้าในตะกร้าแล้ว (ถูกลบออกทั้งหมด) หรือไซส์นั้นไม่มีอยู่ในตะกร้าแล้ว
    // (ถูกลบออกโดยการตั้งจำนวนเป็น 0) ให้เคลียร์ข้อความจำนวนในตะกร้าของไซส์นั้นด้วย
    setState(() {
      filterProductAllModels![index].itemincartSunit =
          (mapCart != null && mapCart['price_list'].containsKey('s'))
              ? mapCart['price_list']['s']['quantity']
              : '0';
      filterProductAllModels![index].itemincartMunit =
          (mapCart != null && mapCart['price_list'].containsKey('m'))
              ? mapCart['price_list']['m']['quantity']
              : '0';
      filterProductAllModels![index].itemincartLunit =
          (mapCart != null && mapCart['price_list'].containsKey('l'))
              ? mapCart['price_list']['l']['quantity']
              : '0';
    });
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
          colors: const [Colors.white],

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
      maintainSize: false,
      maintainAnimation: false,
      maintainState: false,
      visible: visible,
      child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.green,
        size: 20,
      )),
    );
  }

  Widget showProductfavItem() {
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

          Widget card = ProductListItemCard(
            product: filterProductAllModels![index],
            onTap: () {
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
            },
          );

          if (loadingIcon == true) {
            return Column(
              children: [
                card,
                myCircularProgress(),
              ],
            );
          }

          return card;
        },
      ),
    );
  }

  Widget showContent() {
    bool? searchKey;
    if (searchString != '') {
      searchKey = true;
    }

    if (filterProductAllModels!.isEmpty) {
      if (myIndex != 4) {
        return showProgressIndicate(searchKey);
      } else {
        return Center(child: Text(''));
      }
    } else {
      return showProductfavItem();
    }
  }

  Widget showProgressIndicate(searchKey) {
    // print('searchKey >> $searchKey');

    if (searchKey == true) {
      if (filterProductAllModels!.isEmpty) {
        return Center(child: Text('')); // Search not found
      } else {
        return Center(child: Text(''));
      }
    } else {
      return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.green,
        size: 30,
      ));
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
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(
            'รายการล่าสุดในตะกร้า',
            style: MyStyle().h3bStyle,
          ),
        ),
        SizedBox(
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

  @override
  void onProductFound(ProductAllModel product) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (BuildContext context) => Detail(
        userModel: myUserModel,
        productAllModel: product,
      ),
    );
    Navigator.of(context).push(route).then((value) => readCart());
  }

  Widget searchForm() {
    return Container(
      decoration: MyStyle().boxLightGray,
      // color: Colors.grey,
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
      child: ListTile(
        trailing: SizedBox(
          width: 45.0,
          child: Image.asset('images/icon_barcode.png'),
        ),
        onTap: () {
          // readQRcode();
          readQRcodePreview();
          // scanBarcodeNormal();
        },
        title: TextField(
          controller: _controller,
          textAlign: TextAlign.center,
          scrollPadding: EdgeInsets.all(1.00),
          style: TextStyle(
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w300,
              fontSize: 18.00),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'ค้นหาสินค้า',
            suffixIcon: IconButton(
              onPressed: () => _controller.clear(),
              icon: Icon(Icons.clear),
            ),
          ),
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
        ),
      ),
    );
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index,
        userModel: myUserModel!,
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

/*
  void changePage(int? index) {
    setState(() {
      currentIndex = index;
    });

    //You can have a switch case to Navigate to different pages
    switch (currentIndex) {
      case 0:
        MaterialPageRoute route = MaterialPageRoute(
          builder: (value) => MyService(
            userModel: myUserModel,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(route, (route) => false);

        break; // home
      case 1:
        break; // all product
      case 2:
        routeToListProduct(0);
        break; // all product
      case 3:
        routeToListProduct(2);
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return DetailCart(
            userModel: myUserModel,
          );
        });
        Navigator.of(context).push(materialPageRoute).then((value) {
          setState(() {
            print('Here is change page');

            readCart();
          });
        });
        break; // Shopping cart
    }
  }
*/
  // Widget showBubbleBottomBarNav() {
  //   return BubbleBottomBar(
  //     hasNotch: true,
  //     // fabLocation: BubbleBottomBarFabLocation.end,
  //     opacity: .2,
  //     borderRadius: BorderRadius.vertical(
  //         top: Radius.circular(
  //             16)), //border radius doesn't work when the notch is enabled.
  //     elevation: 8,
  //     currentIndex: currentIndex,
  //     onTap: changePage,
  //     items: <BubbleBottomBarItem>[
  //       BubbleBottomBarItem(
  //           backgroundColor: Colors.blue,
  //           icon: Icon(
  //             Icons.home,
  //             color: Colors.black,
  //           ),
  //           activeIcon: Icon(
  //             Icons.home,
  //             color: Colors.blue,
  //           ),
  //           title: Text("หน้าหลัก")),
  //       BubbleBottomBarItem(
  //           backgroundColor: Colors.red,
  //           icon: Icon(
  //             Icons.favorite,
  //             color: Colors.black,
  //           ),
  //           activeIcon: Icon(
  //             Icons.favorite,
  //             color: Colors.red,
  //           ),
  //           title: Text("รายการโปรด")),
  //       BubbleBottomBarItem(
  //           backgroundColor: Colors.green,
  //           icon: Icon(
  //             Icons.medical_services,
  //             color: Colors.black,
  //           ),
  //           activeIcon: Icon(
  //             Icons.medical_services,
  //             color: Colors.green,
  //           ),
  //           title: Text("สินค้า")),
  //       BubbleBottomBarItem(
  //           backgroundColor: Colors.brown,
  //           icon: Icon(
  //             Icons.shopping_cart,
  //             color: Colors.black,
  //           ),
  //           activeIcon: Icon(
  //             Icons.shopping_cart,
  //             color: Colors.brown,
  //           ),
  //           title: Text("ตะกร้าสินค้า")),
  //     ],
  //   );
  // }

  Widget stylishBottomBar() {
    return StylishBottomBar(
      //  option: AnimatedBarOptions(
      //    iconSize: 32,
      //    barAnimation: BarAnimation.liquid,
      //    iconStyle: IconStyle.animated,
      //    opacity: 0.3,
      //  ),

      // option: BubbleBarOptions(
      //   barStyle: BubbleBarStyle.horizontal,
      //   // barStyle: BubbleBarStyle.vertical,
      //   bubbleFillStyle: BubbleFillStyle.fill,
      //   // bubbleFillStyle: BubbleFillStyle.outlined,
      //   opacity: 0.3,
      // ),

      // option: DotBarOptions(
      //   dotStyle: DotStyle.tile,
      //   gradient: const LinearGradient(
      //     colors: [
      //       Colors.deepPurple,
      //       Colors.pink,
      //     ],
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      // ),
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
    txtheader = 'รายการโปรด';
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
  const ScanPreviewPage({super.key});

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
