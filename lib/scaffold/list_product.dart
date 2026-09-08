import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'my_service.dart';
import 'detail.dart';
import 'detail_cart.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:toast/toast.dart';
import 'package:ptncenter/utility/qr_scan_mixins.dart';
import 'package:ptncenter/widget/product_list_item_card.dart';
import 'package:ptncenter/widget/product_search_form.dart';

class ListProduct extends StatefulWidget {
  final int? index;
  final UserModel? userModel;
  final int? cate;
  final String? cateName;
  final String? searchStr;
  final String? promotionGroupId;

  const ListProduct(
      {super.key,
      this.index,
      this.userModel,
      this.cate,
      this.cateName,
      this.searchStr,
      this.promotionGroupId});

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

class _ListProductState extends State<ListProduct>
    with ProductBarcodeScannerMixin<ListProduct> {
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
  String? mysearchString = '';
  String? myPromotionGroupId;
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 300); // ตั้งค่า เวลาที่จะ delay
  bool statusStart = true;

  int? currentIndex;

  String? creditterm = '-';
  String? financialamount = '-';
  String? contactAdmin = '-';


  int substart = 0;
  bool visible = true;
  int selectIndex = 1;
  bool isGridView = false;
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
    myPromotionGroupId = widget.promotionGroupId;

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
        '${MyStyle().serverName}/json_loadmycart.php?memberId=$memberId&screen=listproduct';


    http.Response response = await http.get(Uri.parse(url));
    if (!mounted) return;
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
    setState(() {
      visible = true;
    });

    String memberId = myUserModel!.id.toString();
    String? jsQuery = decodeProductCodeQuery(searchString);
    String url;
    if (jsQuery != null) {
      url =
          '${MyStyle().serverName}/json_productlist.php?memberId=$memberId&$jsQuery&page=$page';
    } else {
      url =
          '${MyStyle().serverName}/json_productlist.php?memberId=$memberId&searchKey=$searchString&page=$page';
      if (myIndex != 0) {
        if (myIndex == 1 || myIndex == 2 || myIndex == 3) {
          url =
              '${MyStyle().serverName}/json_productlist.php?memberId=$memberId&searchKey=$searchString&product_mode=$myIndex&page=$page';
        } else if (myIndex == 4) {
          url =
              '${MyStyle().serverName}/json_productnotreceive.php?memberId=$memberId&page=$page';
        } else if (myIndex == 5) {
          url =
              '${MyStyle().serverName}/json_productlist.php?memberId=$memberId&cate_id=$myCate&page=$page';
        } else if (myIndex == 6) {
          url =
              '${MyStyle().serverName}/json_productlist.php?memberId=$memberId&promotiongroup_id=$myPromotionGroupId&page=$page';
        } else if (myIndex == 7) {
          url =
              '${MyStyle().serverName}/json_productbestseller.php?memberId=$memberId&page=$page';
        } else if (myIndex == 8) {
          url =
              '${MyStyle().serverName}/json_productbestintrend.php?memberId=$memberId&page=$page';
        } else if (myIndex == 9) {
          url =
              '${MyStyle().serverName}/json_medicinepromotion.php?memberId=$memberId&page=$page';
        }
      }
    }

    // url = '${MyStyle().readProductWhereMode}$myIndex';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemProducts = result['itemsProduct'];
    // print('itemProducts >> ${itemProducts}');
    int i = 0;

    for (var map in itemProducts) {
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

  Future<void>? showCreditAlertMessage() {
    if (creditterm !='-' || financialamount !='-' || contactAdmin !='-') {
        var txtCreditTitle =  '';
        if(creditterm !='-' ) {
          txtCreditTitle =  'ท่านมียอดค้างชำระเกินกำหนด';
        } else if(financialamount !='-' ) {
          txtCreditTitle =  'ท่านมียอดค้างชำระเกินวงเงินที่กำหนด';
        } else if(contactAdmin !='-' ) {
          txtCreditTitle =  'กรุณาติดต่อผู้ดูแลระบบ';
        }

      Toast.show(txtCreditTitle,
          duration: 5,// Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: const Color.fromARGB(255, 243, 88, 61));
    }
    return null;
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

  String priceUnitText(int index) {
    String txtShowPrice;
    String txtShowUnit;
    String txtPriceUnit = '';
    if (filterProductAllModels![index].itemSprice.toString() != '0') {
      txtShowPrice = filterProductAllModels![index].itemSprice.toString();
      txtShowUnit = filterProductAllModels![index].itemSunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '') {
        txtPriceUnit = '$txtPriceUnit [$txtShowPrice/$txtShowUnit] ';
      }
    }
    if (filterProductAllModels![index].itemMprice.toString() != '0') {
      txtShowPrice = filterProductAllModels![index].itemMprice.toString();
      txtShowUnit = filterProductAllModels![index].itemMunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '') {
        txtPriceUnit = '$txtPriceUnit [$txtShowPrice/$txtShowUnit] ';
      }
    }
    if (filterProductAllModels![index].itemLprice.toString() != '0') {
      txtShowPrice = filterProductAllModels![index].itemLprice.toString();
      txtShowUnit = filterProductAllModels![index].itemLunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '') {
        txtPriceUnit = '$txtPriceUnit [$txtShowPrice/$txtShowUnit] ';
      }
    }
    return txtPriceUnit;
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

  Widget loadMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.green,
              size: 20,
            ),
          ),
          SizedBox(width: 10.0),
          Text('กำลังโหลดข้อมูลเพิ่มเติม...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13.0)),
        ],
      ),
    );
  }

  void onTapProduct(int index) {
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
  }

  Widget showGridImage(int index) {
    String? photo = filterProductAllModels![index].photo;
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(6.0),
        topRight: Radius.circular(6.0),
      ),
      child: AspectRatio(
        aspectRatio: 1.1,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(
              left: 10.0, right: 10.0, top: 2.0, bottom: 5.0),
          alignment: Alignment.center,
          // ลดขนาดรูปลง 10% จากพื้นที่เดิม โดยไม่กระทบขนาด container/ตาราง
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

  Widget showGridStock(int index) {
    ProductAllModel model = filterProductAllModels![index];
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

  Widget showGridItem(int index) {
    ProductAllModel model = filterProductAllModels![index];
    return GestureDetector(
      onTap: () => onTapProduct(index),
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
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            showGridImage(index),
            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    model.title ?? '',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B6B41),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((model.hilight ?? '') != '')
                    Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Text(
                        model.hilight!,
                        style: TextStyle(fontSize: 14.0, color: Colors.red),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if ((model.extrapoint ?? '') != '')
                    Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Text(
                        model.extrapoint!,
                        style: TextStyle(fontSize: 11.0, color: Colors.orange),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      priceUnitText(index),
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
                    child: showGridStock(index),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showProductItem() {
    int itemCount = filterProductAllModels!.length;
    bool showLoadingFooter = visible && itemCount > 0;

    if (isGridView) {
      return Expanded(
        child: GridView.builder(
          controller: scrollController,
          padding: EdgeInsets.all(5.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.66,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: itemCount + (showLoadingFooter ? 1 : 0),
          itemBuilder: (BuildContext buildContext, int index) {
            if (index >= itemCount) {
              return loadMoreIndicator();
            }
            return showGridItem(index);
          },
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: itemCount + (showLoadingFooter ? 1 : 0),
        itemBuilder: (BuildContext buildContext, int index) {
          if (index >= itemCount) {
            return loadMoreIndicator();
          }

          return ProductListItemCard(
            product: filterProductAllModels![index],
            onTap: () => onTapProduct(index),
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

    if (filterProductAllModels!.isEmpty) {
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
    return Container(
      padding: EdgeInsets.only(left: 8.0),
      child: Row(
        children: [
          Expanded(
           child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'รายการล่าสุดในตะกร้า',
                  style: MyStyle().h3bStyle,
                ),
                Text(lastItemName.toString(),
                    style: TextStyle(
                      fontSize: 14.0,
                      // fontWeight: FontWeight.bold,
                      color: Color.fromARGB(0xff, 0x00, 0x73, 0x26),
                    )),
              ],
            ),
          ),
          showViewToggle(),
        ],
      ),
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

  List<String> jsonSuggestMed =[];
  Future<void> loadJsonAsset() async {
    String url = 'https://ptnpharma.com/jsonData/medicine_unit.json';
    http.Response response = await http.get(Uri.parse(url));
    var result =  json.decode(response.body.toLowerCase()); // json.decode(utf8.decode(response.bodyBytes).toLowerCase());
    for (var map in result) {
      jsonSuggestMed.add('${map['name']}|${map['code']}');   // map['code']+"|"+map['name']
    }
    setState(() {
       jsonSuggestMed;
    });
  }

  // productCode รูปแบบ "js|<url-encoded query string ในเครื่องหมายคำพูด>"
  // เช่น js|%22sup%3D102%22 => decode => "sup=102" => query string จริงคือ sup=102
  String? decodeProductCodeQuery(String? raw) {
    if (raw == null || !raw.startsWith('js|')) return null;
    String decoded;
    try {
      decoded = Uri.decodeComponent(raw.substring(3));
    } catch (_) {
      return null;
    }
    if (decoded.length >= 2 && decoded.startsWith('"') && decoded.endsWith('"')) {
      decoded = decoded.substring(1, decoded.length - 1);
    }
    return decoded;
  }

  String buildSearchKey(String query) {
    String trimmed = query.trim();
    if (trimmed.isEmpty) return trimmed;

    List<String> words = trimmed.split(RegExp(r'\s+'));
    if (words.length >= 2) {
      // ค้นหาด้วย 2 คำแรกพร้อมกัน (ต้องเจอทั้งคู่ใน field เดียวกัน) เช่น "Acetin 200"
      String keyword1 = Uri.encodeComponent(words[0]);
      String keyword2 = Uri.encodeComponent(words[1]);
      return 'kw2|$keyword1|$keyword2';
    }
    return trimmed;
  }

  Widget searchForm() {
    return ProductSearchForm(
      suggestions: jsonSuggestMed,
      optionPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      onSearchChanged: (String string) {
        searchString = string.trim();
      },
      onSearchSubmitted: (value) {
        setState(() {
          searchString = buildSearchKey(value);
          page = 1;
          myIndex = 0;
          productAllModels!.clear();
          readData();
        });
      },
      onSuggestionSelected: (String selection) {
        var parts = selection.split('|');
        searchString = 'x|${parts.sublist(1).join('|').trim()}';
        setState(() {
          page = 1;
          myIndex = 0;
          productAllModels!.clear();
          readData();
        });
      },
      onScanBarcode: () {
        readQRcodePreview();
      },
    );
  }

  Widget showViewToggle() {
    return Container(
      margin: EdgeInsets.only(right: 8.0),
      // padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 3.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _viewToggleButton(icon: Icons.grid_view, selected: isGridView),
          _viewToggleButton(icon: Icons.view_list, selected: !isGridView),
        ],
      ),
    );
  }

  Widget _viewToggleButton({required IconData icon, required bool selected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isGridView = icon == Icons.grid_view;
        });
      },
      child: Container(
        padding: EdgeInsets.all(9.0),
        decoration: BoxDecoration(
          color: selected ? MyStyle().bgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Icon(
          icon,
          size: 20.0,
          color: selected ? Colors.white : Colors.grey.shade600,
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
        txtheader = 'สินค้ามาแรง';
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
