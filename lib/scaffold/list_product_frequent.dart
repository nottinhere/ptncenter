import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:ptncenter/scaffold/list_product_frequent.dart';

import 'package:ptncenter/utility/my_style.dart';
// import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'detail.dart';
import 'detail_cart.dart';
import 'package:ptncenter/widget/home.dart';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';

import 'my_service.dart';

import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';

class ListProductFrequent extends StatefulWidget {
  final int index;
  final UserModel userModel;
  final int cate;
  final String cateName;
  String _result = '';

  ListProductFrequent(
      {Key key, this.index, this.userModel, this.cate, this.cateName})
      : super(key: key);

  @override
  _ListProductFrequent createState() => _ListProductFrequent();
}

//class
class Debouncer {
  // delay เวลาให้มีการหน่วง เมื่อ key searchview

  //Explicit
  final int milliseconds;
  VoidCallback action;
  Timer timer;

  //constructor
  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (timer != null) {
      timer.cancel();
    }
    timer = Timer(Duration(microseconds: milliseconds), action);
  }
}

class _ListProductFrequent extends State<ListProductFrequent> {
  // Explicit
  int myIndex;
  List<ProductAllModel> productAllModels = List(); // []; // set array
  List<ProductAllModel> filterProductAllModels = List(); // []; //

  int amontCart = 0;
  UserModel myUserModel;
  String searchString = '';
  String lastItemName = '';

  int amountListView = 6;
  int page = 1;

  String qrString;
  int myCate = 0;
  String myCateName = '';
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 300); // ตั้งค่า เวลาที่จะ delay
  bool statusStart = true;
  bool _showbyaddcart = false;

  int currentIndex = 1;

  var _isShowincart = {};
  // List<ProductAllModel> productAllModels_buffer = List(); // []; //

  var _controller = TextEditingController();

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
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          page++;
          readData();
          print('in the end');
        }
      } else {
        setState(() {
          visible = false;
        });
      }
    });
  }

/************************************** */
  Future<void> readCart() async {
    print('Here is readcart function');

    amontCart = 0;
    lastItemName = '';
    String memberId = myUserModel.id.toString();
    String url =
        'http://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    // print('url Detail =====>>>>>>>> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    for (var map in cartList) {
      lastItemName = map['title'];
      // setState(() {
      amontCart++;
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
    print('Here is readdata function');
    setState(() {
      visible = true;
    });

    String memberId = myUserModel.id.toString();
    String url =
        'http://ptnpharma.com/apishop/json_productfrequentlist.php?memberId=$memberId&searchKey=$searchString&page=$page';

    // url = '${MyStyle().readProductWhereMode}$myIndex';
    print("URL = $url");

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

    int len = (filterProductAllModels.length);

    for (var map in itemProductfavs) {
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);

      setState(() {
        productAllModels.add(productAllModel);
        filterProductAllModels = productAllModels;
      });
      print(
          ' >> ${len} =>($i)  ${productAllModel.id}  || ${productAllModels[i].title} (${filterProductAllModels[i].itemincartSunit}) <<  (${productAllModel.itemincartSunit})');

      i = i + 1;
    }
    setState(() {
      visible = false;
    });
  }

  Widget showName(int index) {
    bool favStatus = ((filterProductAllModels[index].itemFeqSunit != '0' &&
                filterProductAllModels[index].itemFeqSunit ==
                    filterProductAllModels[index].itemincartSunit) ||
            (filterProductAllModels[index].itemFeqMunit != '0' &&
                filterProductAllModels[index].itemFeqMunit ==
                    filterProductAllModels[index].itemincartMunit) ||
            (filterProductAllModels[index].itemFeqLunit != '0' &&
                filterProductAllModels[index].itemFeqLunit ==
                    filterProductAllModels[index].itemincartLunit))
        ? false
        : true;

    return Visibility(
      visible: true,
      child: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.7 - 10,
            child: Text(
              filterProductAllModels[index].title,
              style: MyStyle().h3Style,
            ),
          ),
        ],
      ),
    );
  }

  Widget showPrice(int index) {
    String txtShowPrice;
    String txtShowUnit;
    String txtPriceUnit = '';
    if (filterProductAllModels[index].itemSprice.toString() != '0') {
      txtShowPrice = filterProductAllModels[index].itemSprice.toString();
      txtShowUnit = filterProductAllModels[index].itemSunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '')
        txtPriceUnit = '$txtPriceUnit' + " [$txtShowPrice/$txtShowUnit] ";
    }
    if (filterProductAllModels[index].itemMprice.toString() != '0') {
      txtShowPrice = filterProductAllModels[index].itemMprice.toString();
      txtShowUnit = filterProductAllModels[index].itemMunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '')
        txtPriceUnit = '$txtPriceUnit' + " [$txtShowPrice/$txtShowUnit] ";
    }
    if (filterProductAllModels[index].itemLprice.toString() != '0') {
      txtShowPrice = filterProductAllModels[index].itemLprice.toString();
      txtShowUnit = filterProductAllModels[index].itemLunit.toString();
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
      padding: EdgeInsets.only(left: 5.0, right: 0.0),
      // height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.69,
      child: Container(
        padding: EdgeInsets.only(bottom: 5.0, top: 5.0),
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
      // child: Image.network(filterProductAllModels[index].photo),
      width: 80,
      height: 80,
      decoration: new BoxDecoration(
          image: new DecorationImage(
        fit: BoxFit.cover,
        alignment: FractionalOffset.topCenter,
        image: new NetworkImage(filterProductAllModels[index].photo),
      )),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Colors.blueGrey.shade100,
          width: 1.0,
        ),
        // bottom: BorderSide(
        //   color: Colors.blueGrey.shade100,
        //   width: 1.0,
        // ),
      ),
    );
  }

  Widget loading() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: visible,
      child: Loading(indicator: BallPulseIndicator(), size: 10.0),
    );
  }

  Widget myCircularProgress() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: visible,
      child: Center(child: CupertinoActivityIndicator()),
    );
  }

  Future<void> iconAddCart(String memberID, String productID, String selectUnit,
      String qty, bool _isFavorite) async {
    String url =
        'http://ptnpharma.com/apishop/json_addfeqitemtocart.php?memberId=$memberID&productID=$productID&selectUnit=$selectUnit&qty=$qty&status=$_isFavorite';

    print('url Favorites url ====>>>>> $url');
    await http.get(Uri.parse(url)).then((response) {
      setState(() {
        // readCart();
      });
    });
  }

  Widget showThumb(int index) {
    bool favStatus = ((filterProductAllModels[index].itemFeqSunit != '0' &&
                filterProductAllModels[index].itemFeqSunit ==
                    filterProductAllModels[index].itemincartSunit) ||
            (filterProductAllModels[index].itemFeqMunit != '0' &&
                filterProductAllModels[index].itemFeqMunit ==
                    filterProductAllModels[index].itemincartMunit) ||
            (filterProductAllModels[index].itemFeqLunit != '0' &&
                filterProductAllModels[index].itemFeqLunit ==
                    filterProductAllModels[index].itemincartLunit))
        ? false
        : true;
    String qty;
    String productID = filterProductAllModels[index].id.toString();
    String memberID = myUserModel.id.toString();
    String selectUnit = filterProductAllModels[index].selectUnit;
    switch (selectUnit) {
      case 's':
        qty = filterProductAllModels[index].itemFeqSunit;
        break;
      case 'm':
        qty = filterProductAllModels[index].itemFeqMunit;
        break;
      case 'l':
        qty = filterProductAllModels[index].itemFeqLunit;
        break;
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.07,
      margin: const EdgeInsets.only(right: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          (favStatus == true)
              ? FavoriteButton(
                  isFavorite: true, //favStatus,
                  iconSize: 40.0,
                  // iconDisabledColor: Colors.white,
                  valueChanged: (_isFavorite) {
                    // print('Is Favorite : $_isFavorite');
                    iconAddCart(
                        memberID, productID, selectUnit, qty, _isFavorite);

                    setState(() {
                      _isShowincart[index] = true;
                      showName(index);
                      favStatus = true;
                      readCart();
                    });
                  },
                )
              : Icon(
                  Icons.add_shopping_cart,
                  color: Colors.grey.shade400,
                ),
        ],
      ),
    );
  }

  Widget showStock(int index) {
    bool favStatus = ((filterProductAllModels[index].itemFeqSunit != '0' &&
                filterProductAllModels[index].itemFeqSunit ==
                    filterProductAllModels[index].itemincartSunit) ||
            (filterProductAllModels[index].itemFeqMunit != '0' &&
                filterProductAllModels[index].itemFeqMunit ==
                    filterProductAllModels[index].itemincartMunit) ||
            (filterProductAllModels[index].itemFeqLunit != '0' &&
                filterProductAllModels[index].itemFeqLunit ==
                    filterProductAllModels[index].itemincartLunit))
        ? false
        : true;
    _isShowincart[index] =
        (favStatus == false || _isShowincart[index] == true) ? true : false;

    print(
        '($index)_isShowincart[$index] >> ' + _isShowincart[index].toString());

    String qty;
    String productID = filterProductAllModels[index].id.toString();
    String memberID = myUserModel.id.toString();
    String selectUnit = filterProductAllModels[index].selectUnit;
    switch (selectUnit) {
      case 's':
        qty = filterProductAllModels[index].itemFeqSunit;
        break;
      case 'm':
        qty = filterProductAllModels[index].itemFeqMunit;
        break;
      case 'l':
        qty = filterProductAllModels[index].itemFeqLunit;
        break;
    }

    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.15,
          child: Text(
            'สั่งประจำ:',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.blue,
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.16,
          child: Text(
            ((filterProductAllModels[index].itemFeqSunit != '0')
                    ? '${filterProductAllModels[index].itemFeqSunit} ${filterProductAllModels[index].itemSunit}  '
                    : '') +
                ((filterProductAllModels[index].itemFeqMunit != '0')
                    ? '${filterProductAllModels[index].itemFeqMunit} ${filterProductAllModels[index].itemMunit}  '
                    : '') +
                ((filterProductAllModels[index].itemFeqLunit != '0')
                    ? '${filterProductAllModels[index].itemFeqLunit} ${filterProductAllModels[index].itemLunit}'
                    : ''),
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.blue,
            ),
          ),
        ),
        ///////////////  show  incart     ////////////////
        Visibility(
          visible: _isShowincart[index],
          child: Row(children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              child: Text(
                ' ตะกร้า:',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.red,
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              child: Text(
                ((filterProductAllModels[index].itemFeqSunit != '0')
                        ? '${filterProductAllModels[index].itemFeqSunit} ${filterProductAllModels[index].itemSunit}  '
                        : '') +
                    ((filterProductAllModels[index].itemFeqMunit != '0')
                        ? '${filterProductAllModels[index].itemFeqMunit} ${filterProductAllModels[index].itemMunit}  '
                        : '') +
                    ((filterProductAllModels[index].itemFeqLunit != '0')
                        ? '${filterProductAllModels[index].itemFeqLunit} ${filterProductAllModels[index].itemLunit}'
                        : ''),
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.red,
                ),
              ),
            ),
          ]),
        ),
      ],
    );
    // return Text('na');
  }

  Widget showProductfavItem() {
    int perpage = 15;
    bool loadingIcon = false;

    // int i = 0;
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: productAllModels.length,
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
                            showThumb(index),
                          ],
                        ),
                      ),
                    ),
                  ),
                  onTap: () {},
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
                      showThumb(index),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget showContent() {
    bool searchKey;
    if (searchString != '') {
      searchKey = true;
    }

    if (filterProductAllModels.length == 0) {
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
      if (filterProductAllModels.length == 0) {
        return Center(child: Text('')); // Search not found
      } else {
        return Center(child: Text(''));
      }
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  Future<void> addAlltoCart() async {
    String memberID = myUserModel.id.toString();
    String url =
        'http://ptnpharma.com/apishop/json_addallfeqitemtocart.php?memberId=$memberID';

    print('url Favorites url ====>>>>> $url');
    await http.get(Uri.parse(url)).then((response) {
      setState(() {
        page = 1;
        myIndex = 0;
        // productAllModels.clear();
        filterProductAllModels.clear();
        readData();
        readCart();
      });
    });
  }

  void confirmAddAll() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ยืนยันเพิ่มสินค้า'),
            content: Text('เพิ่มทุกรายการลงตะกร้า'),
            actions: <Widget>[
              cancelButton(),
              comfirmButton(),
            ],
          );
        });
  }

  Widget cancelButton() {
    return TextButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget comfirmButton() {
    return TextButton(
      child: Text('Confirm'),
      onPressed: () {
        addAlltoCart();
        Navigator.of(context).pop();
      },
    );
  }

  Widget addAllBTN() {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 18));
    return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Align(
          alignment: Alignment.topRight,
          child: ElevatedButton(
            style: style,
            child: const Text('เพิ่มทั้งหมดลงตะกร้า'),
            onPressed: () {
              confirmAddAll();
            },
          ),
        ));
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

  void changePage(int index) {
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

  Widget showBubbleBottomBarNav() {
    return BubbleBottomBar(
      hasNotch: true,
      // fabLocation: BubbleBottomBarFabLocation.end,
      opacity: .2,
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(
              16)), //border radius doesn't work when the notch is enabled.
      elevation: 8,
      currentIndex: currentIndex,
      onTap: changePage,
      items: <BubbleBottomBarItem>[
        BubbleBottomBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.home,
              color: Colors.blue,
            ),
            title: Text("หน้าหลัก")),
        BubbleBottomBarItem(
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.favorite,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            title: Text("สินค้าสั่งประจำ")),
        BubbleBottomBarItem(
            backgroundColor: Colors.green,
            icon: Icon(
              Icons.medical_services,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.medical_services,
              color: Colors.green,
            ),
            title: Text("สินค้า")),
        BubbleBottomBarItem(
            backgroundColor: Colors.brown,
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.shopping_cart,
              color: Colors.brown,
            ),
            title: Text("ตะกร้าสินค้า")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String txtheader = '';
    txtheader = 'สินค้าสั่งประจำ';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().bgColor,
        title: Text(txtheader),
        actions: <Widget>[
          showCart(),
        ],
      ),

      body: Column(
        children: <Widget>[
          addAllBTN(),
          // lastItemInCart(),
          showContent(),
        ],
      ),
      bottomNavigationBar: showBubbleBottomBarNav(), //showBottomBarNav
    );
  }
}

class FavoriteButton extends StatefulWidget {
  FavoriteButton({
    double iconSize,
    Color iconColor,
    Color iconDisabledColor,
    bool isFavorite,
    Function valueChanged,
    Key key,
  })  : _iconSize = iconSize ?? 60.0,
        _iconColor = iconColor ?? Colors.blueAccent,
        _iconDisabledColor = iconDisabledColor ?? Colors.grey[400],
        _isFavorite = isFavorite ?? false,
        _valueChanged = valueChanged,
        super(key: key);

  final double _iconSize;
  final Color _iconColor;
  final bool _isFavorite;
  final Function _valueChanged;
  final Color _iconDisabledColor;

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Color> _colorAnimation;
  Animation<double> _sizeAnimation;

  CurvedAnimation _curve;

  double _maxIconSize = 0.0;
  double _minIconSize = 0.0;

  final int _animationTime = 400;

  bool _isFavorite = false;
  bool _isAnimationCompleted = false;

  @override
  void initState() {
    super.initState();

    _isFavorite = widget._isFavorite;
    _maxIconSize = (widget._iconSize < 20.0)
        ? 20.0
        : (widget._iconSize > 100.0)
            ? 100.0
            : widget._iconSize;
    final double _sizeDifference = _maxIconSize * 0.30;
    _minIconSize = _maxIconSize - _sizeDifference;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _animationTime),
    );

    _curve = CurvedAnimation(curve: Curves.slowMiddle, parent: _controller);
    Animation<Color> _selectedColorAnimation = ColorTween(
      begin: widget._iconColor,
      end: widget._iconDisabledColor,
    ).animate(_curve);

    Animation<Color> _deSelectedColorAnimation = ColorTween(
      begin: widget._iconDisabledColor,
      end: widget._iconColor,
    ).animate(_curve);

    _colorAnimation = (_isFavorite == true)
        ? _selectedColorAnimation
        : _deSelectedColorAnimation;
    _sizeAnimation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: _minIconSize,
            end: _maxIconSize,
          ),
          weight: 50,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: _maxIconSize,
            end: _minIconSize,
          ),
          weight: 50,
        ),
      ],
    ).animate(_curve);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimationCompleted = true;
        _isFavorite = !_isFavorite;
        widget._valueChanged(_isFavorite);
      } else if (status == AnimationStatus.dismissed) {
        _isAnimationCompleted = false;
        _isFavorite = !_isFavorite;
        widget._valueChanged(_isFavorite);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return InkResponse(
          onTap: () {
            setState(() {
              if (_isAnimationCompleted == true) {
                _controller.reverse();
              } else {
                _controller.forward();
              }
            });
          },
          child: Icon(
            (Icons.add_shopping_cart),
            color: _colorAnimation.value,
            size: _sizeAnimation.value,
          ),
        );
      },
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
          child: ScanPreviewWidget(
            onScanResult: (result) {
              debugPrint('scan result: $result');
              Navigator.pop(context, result);
            },
          ),
        ),
      ),
    );
  }
}
