import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_vote_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/list_product.dart';
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

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';
// import 'package:favorite_button/favorite_button.dart';

class ListProductvote extends StatefulWidget {
  final int index;
  final UserModel userModel;
  final int cate;
  final String cateName;
  String _result = '';

  ListProductvote(
      {Key key, this.index, this.userModel, this.cate, this.cateName})
      : super(key: key);

  @override
  _ListProductvoteState createState() => _ListProductvoteState();
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

class _ListProductvoteState extends State<ListProductvote> {
  // Explicit
  int myIndex;
  List<ProductVoteModel> productVoteModels = List(); // []; // set array
  List<ProductVoteModel> filterProductVoteModels = List(); // []; //

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

  int currentIndex = 1;

  // List<ProductVoteModel> productVoteModels_buffer = List(); // []; //

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
        'https://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    print('url Detail =====>>>>>>>> $url');

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
    // List<ProductVoteModel> productVoteModels_buffer = List(); // []; //
    // String url = MyStyle().readAllProduct;
    print('Here is readdata function');
    setState(() {
      visible = true;
    });

    String memberId = myUserModel.id.toString();
    String url =
        'https://ptnpharma.com/apishop/json_productvotelist.php?memberId=$memberId&searchKey=$searchString&page=$page';

    // url = '${MyStyle().readProductWhereMode}$myIndex';
    print("URL = $url");

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

    int len = (filterProductVoteModels.length);

    for (var map in itemProductvotes) {
      ProductVoteModel productVoteModel = ProductVoteModel.fromJson(map);

      setState(() {
        productVoteModels.add(productVoteModel);
        filterProductVoteModels = productVoteModels;
      });
      print(
          ' >> ${len} =>($i)  ${productVoteModel.id}  || ${productVoteModels[i].title} (${filterProductVoteModels[i].votescore}) <<  (${productVoteModel.votescore})');

      i = i + 1;
    }
    setState(() {
      visible = false;
    });
  }

  Future<void> updateDatalist(index) async {
    // List<ProductVoteModel> productVoteModels_buffer = List(); // []; //
    // String url = MyStyle().readAllProduct;
    print('Here is updateDatalist function');

    String memberId = myUserModel.id.toString();
    int productID = filterProductVoteModels[index].id;
    String url =
        'https://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    print("URL update item = $url");
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
  }

  Widget showName(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.7 - 10,
          child: Text(
            filterProductVoteModels[index].title,
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
        Container(
          width: MediaQuery.of(context).size.width * 0.66,
          child: Text(
            'ใช้เพื่อ:' + ' ${filterProductVoteModels[index].usefor}',
            style: MyStyle().h4StyleGray,
          ),
        ),
      ],
    );
    // return Text('na');
  }

  Widget showIncart(int index) {
    return Row(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width * 0.13,
        child: Text(
          (filterProductVoteModels[index].votescore != '0') ? 'ตะกร้า:' : '',
          style: MyStyle().h4StyleRed,
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Text(
          ((filterProductVoteModels[index].votescore != '0')
              ? '${filterProductVoteModels[index].votescore} ${filterProductVoteModels[index].votescore}  '
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
    if (filterProductVoteModels[index].pricelabel.toString() != '0') {
      txtShowPrice = filterProductVoteModels[index].pricesale.toString();
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
      // child: Image.network(filterProductVoteModels[index].photo),
      width: 60,
      height: 60,
      decoration: new BoxDecoration(
          image: new DecorationImage(
        fit: BoxFit.cover,
        alignment: FractionalOffset.topCenter,
        image: new NetworkImage(filterProductVoteModels[index].photo),
      )),
    );
  }

  Future<void> thumbLike(
      String productID, String memberID, bool _isFavorite) async {
    String url =
        'https://ptnpharma.com/apishop/json_productvote.php?productID=$productID&memberId=$memberID&status=$_isFavorite';

    print('url Favorites url ====>>>>> $url');
    await http.get(Uri.parse(url)).then((response) {
      setState(() {
        //readCart();
      });
    });
  }

  Widget showThumb(int index) {
    bool favStatus =
        (filterProductVoteModels[index].yourvote == true) ? true : false;
    String productID = filterProductVoteModels[index].id.toString();
    String memberID = myUserModel.id.toString();
    return Container(
      width: MediaQuery.of(context).size.width * 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FavoriteButton(
            isFavorite: favStatus,
            iconSize: 40.0,
            // iconDisabledColor: Colors.white,
            valueChanged: (_isFavorite) {
              // print('Is Favorite : $_isFavorite');
              thumbLike(productID, memberID, _isFavorite);

              // http.Response response =  http.get(Uri.parse(url));
            },
          ),
        ],
      ),
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

  Widget showProductvoteItem() {
    int perpage = 15;
    bool loadingIcon = false;

    // int i = 0;
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: productVoteModels.length,
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

    if (filterProductVoteModels.length == 0) {
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
      if (filterProductVoteModels.length == 0) {
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

  Widget searchForm() {
    return Container(
      decoration: MyStyle().boxLightGray,
      // color: Colors.grey,
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
      child: ListTile(
        trailing: Container(
          width: 45.0,
          child: Image.asset('images/icon_barcode.png'),
        ),
        onTap: () {
          print('You click barcode scan');
          // readQRcode();
          // readQRcodePreview();
          // Navigator.of(context).pop();
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
              productVoteModels.clear();
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
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToListProductvote(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProductvote(
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
        String webPage = 'request';

        print('You click $webPage');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebView(
                      userModel: myUserModel,
                      webPage: webPage,
                    )));

        break; // all product
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
            title: Text("โหวตยาเข้าร้าน")),
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
            title: Text("แนะนำยาที่ต้องการ")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String txtheader = '';
    txtheader = 'โหวตยาน่าขาย';
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
          // searchForm(),
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
            (Icons.thumb_up),
            color: _colorAnimation.value,
            size: _sizeAnimation.value,
          ),
        );
      },
    );
  }
}

class WebView extends StatefulWidget {
  final UserModel userModel;
  final String webPage;

  WebView({Key key, this.userModel, this.webPage}) : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  UserModel myUserModel;
  String mywebPage;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    mywebPage = widget.webPage;
  }

  @override
  Widget build(BuildContext context) {
    String memberId = myUserModel.id;
    String memberCode = myUserModel.customerCode;
    String webPage = mywebPage.toString();

    String url =
        'https://ptnpharma.com/shop/pages/forms/product_request_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
    String txtTitle = 'แนะนำยาที่ต้องการ';

    print('Click open ==>> $webPage');

    print('URL ==>> $url');
    return WebviewScaffold(
      url: url, //"https://www.androidmonks.com",
      appBar: AppBar(
        backgroundColor: MyStyle().bgColor,
        title: Text(txtTitle),
      ),
      withZoom: true,
      withJavascript: true,
      withLocalStorage: true,
      appCacheEnabled: false,
      ignoreSSLErrors: true,
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
