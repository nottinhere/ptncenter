import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_vote_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'detail_cart.dart';

import 'my_service.dart';

import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:ptncenter/widget/simple_search_bar.dart';



class ListProductvote extends StatefulWidget {
  final int? index;
  final UserModel? userModel;
  final int? cate;
  final String? cateName;

  const ListProductvote(
      {super.key, this.index, this.userModel, this.cate, this.cateName});

  @override
  _ListProductvoteState createState() => _ListProductvoteState();
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

class _ListProductvoteState extends State<ListProductvote> {
  // Explicit
  int? myIndex;
  List<ProductVoteModel>? productVoteModels = []; // []; // set array
  List<ProductVoteModel>? filterProductVoteModels = []; // []; //

  int? amontCart = 0;
  UserModel? myUserModel;
  String? searchString = '';
  String? lastItemName = '';

  int? amountListView = 6;
  int? page = 1;

  String? qrString;
  int? myCate = 0;
  String? myCateName = '';
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 300); // ตั้งค่า เวลาที่จะ delay
  bool? statusStart = true;

  int? currentIndex = 1;

  // List<ProductVoteModel> productVoteModels_buffer = List(); // []; //

  final _controller = TextEditingController();

  int? substart = 0;
  bool? visible = true;

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
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
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
        '${MyStyle().serverName}/json_loadmycart.php?memberId=$memberId&screen=listproductvote';


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
    // List<ProductVoteModel> productVoteModels_buffer = List(); // []; //
    // String url = MyStyle().readAllProduct;
    setState(() {
      visible = true;
    });

    String memberId = myUserModel!.id.toString();
    String url =
        '${MyStyle().serverName}/json_productvotelist.php?memberId=$memberId&searchKey=$searchString&page=$page';

    // url = '${MyStyle().readProductWhereMode}$myIndex';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemProductvotes = result['itemsProduct'];
    // print('itemProducts >> ${itemProducts}');
    int i = 0;
    // print('Start >> ${filterProductVoteModels.length}');
    // int s = (filterProductVoteModels.length);
    // if (filterProductVoteModels.length == 0)
    //   int substart = 0;
    // else
    //   int substart = 20;

    for (var map in itemProductvotes) {
      ProductVoteModel productVoteModel = ProductVoteModel.fromJson(map);

      setState(() {
        productVoteModels!.add(productVoteModel);
        filterProductVoteModels = productVoteModels;
      });

      i = i + 1;
    }
    setState(() {
      visible = false;
    });
  }

  Future<void> updateDatalist(index) async {
    // List<ProductVoteModel> productVoteModels_buffer = List(); // []; //
    // String url = MyStyle().readAllProduct;

    String memberId = myUserModel!.id.toString();
    String url =
        '${MyStyle().serverName}/json_loadmycart.php?memberId=$memberId';

    http.Response response = await http.get(Uri.parse(url));
    json.decode(response.body);
  }

  Widget showName(int index) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Text(
            filterProductVoteModels![index].title!,
            style: MyStyle().h3Style,
          ),
        ),
      ],
    );
  }

  Widget showStock(int index) {
    return Row(
      children: <Widget>[
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.11,
        //   child: Text(
        //     'ใช้เพื่อ:',
        //     style: MyStyle().h4StyleGray,
        //   ),
        // ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.66,
          child: Text(
            'ใช้เพื่อ:' ' ${filterProductVoteModels![index].usefor}',
            style: MyStyle().h4StyleGray,
          ),
        ),
      ],
    );
    // return Text('na');
  }

  Widget showIncart(int index) {
    return Row(children: <Widget>[
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.13,
        child: Text(
          (filterProductVoteModels![index].votescore != '0') ? 'ตะกร้า:' : '',
          style: MyStyle().h4StyleRed,
        ),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Text(
          ((filterProductVoteModels![index].votescore != '0')
              ? '${filterProductVoteModels![index].votescore} ${filterProductVoteModels![index].votescore}  '
              : ''),
          style: MyStyle().h4StyleRed,
        ),
      ),
    ]);
  }

  Widget showPrice(int index) {
    String? txtShowPrice;
    String? txtShowUnit;
    String? txtPriceUnit = '';
    if (filterProductVoteModels![index].pricelabel.toString() != '0') {
      txtShowPrice = filterProductVoteModels![index].pricesale.toString();
      if (txtShowPrice != '' && txtShowUnit != '') {
        txtPriceUnit = '$txtPriceUnit [$txtShowPrice/$txtShowUnit] ';
      }
    }

    return Row(
      children: <Widget>[
        Text(
          txtPriceUnit,
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
      padding: EdgeInsets.only(left: 2.0, right: 2.0),
      // height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.69,
      child: Container(
        padding: EdgeInsets.only(bottom: 2.0, top: 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            showName(index),
            // showPrice(index),
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
      // child: Image.network(filterProductVoteModels![index].photo),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          image: DecorationImage(
        fit: BoxFit.cover,
        alignment: FractionalOffset.topCenter,
        image: NetworkImage(filterProductVoteModels![index].photo!),
      )),
    );
  }

  Future<void> thumbLike(
      String productID, String memberID, bool isFavorite) async {
    String url =
        '${MyStyle().serverName}/json_productvote.php?productID=$productID&memberId=$memberID&status=$isFavorite';

    await http.get(Uri.parse(url)).then((response) {
      setState(() {
        //readCart();
      });
    });
  }

  Widget showThumb(int index) {
    bool favStatus =
        (filterProductVoteModels![index].yourvote == true) ? true : false;
    String productID = filterProductVoteModels![index].id.toString();
    String memberID = myUserModel!.id.toString();
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FavoriteButton(
            isFavorite: favStatus,
            iconSize: 40.0,
            // iconDisabledColor: Colors.white,
            valueChanged: (isFavorite) {
              // print('Is Favorite : $_isFavorite');
              thumbLike(productID, memberID, isFavorite);

              // http.Response response =  http.get(Uri.parse(url));
            },
          ),
        ],
      ),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.green.shade300),
      borderRadius: BorderRadius.all(
        Radius.circular(5.0), //                 <--- border radius here
      ),
    );
  }

  Widget loading() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: visible!,
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
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: visible!,
      child: Center(child: CupertinoActivityIndicator()),
    );
  }

  Widget showProductvoteItem() {
    int perpage = 15;
    bool loadingIcon = false;

    // int i = 0;
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: productVoteModels!.length,
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
                  child: Card(
                    child: Container(
                      decoration: myBoxDecoration(),
                      padding: EdgeInsets.only(top: 0.5),
                      child: Row(
                        children: <Widget>[
                          showImage(index),
                          showText(index),
                          showThumb(index),
                        ],
                      ),
                    ),
                  ),
                ),
                myCircularProgress(),
              ],
            );
          }

          return GestureDetector(
            child: Card(
              child: Container(
                decoration: myBoxDecoration(),
                padding: EdgeInsets.only(top: 0.5),
                child: Row(
                  children: <Widget>[
                    showImage(index),
                    showText(index),
                    showThumb(index),
                  ],
                ),
              ),
            ),
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

    if (filterProductVoteModels!.isEmpty) {
      if (myIndex != 4) {
        return showProgressIndicate(searchKey);
      } else {
        return Center(child: Text(''));
      }
    } else {
      return showProductvoteItem();
    }
  }

  Widget showProgressIndicate(searchKey) {
    // print('searchKey >> $searchKey');

    if (searchKey == true) {
      if (filterProductVoteModels!.isEmpty) {
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

  Widget searchForm() {
    return SimpleSearchBar(
      controller: _controller,
      decoration: MyStyle().boxLightGray,
      hintText: 'ค้นหาสินค้า',
      iconAsset: 'images/icon_barcode.png',
      onScanTap: () {},
      onChanged: (String string) {
        searchString = string.trim();
      },
      onSubmitted: (value) {
        setState(() {
          page = 1;
          myIndex = 0;
          productVoteModels!.clear();
          readData();
        });
      },
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

  void routeToListProductvote(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProductvote(
        index: index,
        userModel: myUserModel!,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void changePage(int? index) {
    setState(() {
      currentIndex = index;
    });

    //You can have a switch case to Navigate to different pages
    switch (currentIndex) {
      case 0:
        MaterialPageRoute route = MaterialPageRoute(
          builder: (value) => MyService(
            userModel: myUserModel!,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(route, (route) => false);

        break; // home
      case 1:
        break; // all product
      case 2:
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => WebView(
        //               userModel: myUserModel!,
        //               webPage: webPage,
        //             )));

        break; // all product
    }
  }

  @override
  Widget build(BuildContext context) {
    String txtheader = '';
    txtheader = 'โหวตยาน่าขาย';
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
          // searchForm(),
          // lastItemInCart(),
          showContent(),
        ],
      ),
      // bottomNavigationBar: showBubbleBottomBarNav(), //showBottomBarNav
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
