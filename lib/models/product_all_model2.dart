class ProductAllModel2 {
  String? title;
  String? hilight;
  String? extrapoint;
  String? productCode;
  String? photo;
  PriceList? priceList;
  String? expire;
  String? expireColor;
  String? detail;
  String? usefor;
  String? method;
  int? itemincartSunit;
  int? itemincartMunit;
  int? itemincartLunit;
  int? limitS;
  int? limitM;
  int? limitL;
  int? subtractS; // จำนวนตัดของ S เทียบหน่วยฐาน (ปกติ = 1)
  int? subtractM; // จำนวนตัดของ M เช่น 12 ชิ้น/โหล
  int? subtractL; // จำนวนตัดของ L เช่น 96 ชิ้น/ลัง
  int? btnAdd1; // 1 = แสดงปุ่ม quick-add ไซส์ M (จำนวนตัดM/หน่วยM)
  int? btnAdd2; // 1 = แสดงปุ่ม quick-add ไซส์ L (จำนวนตัดL/หน่วยL)
  int? recommend;
  int? promotion;
  int? updateprice;
  int? newproduct;
  int? notreceive;
  bool? favorite;
  int? stock;
  String? cateID;
  String? cateName;
  String? youtube;
  String? tiktok;
  String? pricelabel;
  String? pricesale;
  int? id;

  ProductAllModel2(
      {this.title,
      this.hilight,
      this.extrapoint,
      this.productCode,
      this.photo,
      this.priceList,
      this.expire,
      this.expireColor,
      this.detail,
      this.usefor,
      this.method,
      this.itemincartSunit,
      this.itemincartMunit,
      this.itemincartLunit,
      this.limitS,
      this.limitM,
      this.limitL,
      this.subtractS,
      this.subtractM,
      this.subtractL,
      this.btnAdd1,
      this.btnAdd2,
      this.recommend,
      this.promotion,
      this.updateprice,
      this.newproduct,
      this.notreceive,
      this.favorite,
      this.stock,
      this.cateID,
      this.cateName,
      this.youtube,
      this.tiktok,
      this.pricelabel,
      this.pricesale,
      this.id});

  ProductAllModel2.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    hilight = json['hilight'];
    extrapoint = json['extrapoint'];
    productCode = json['product_code'];
    photo = json['photo'];
    priceList = json['price_list'] != null
        ? new PriceList.fromJson(json['price_list'])
        : null;
    expire = json['expire'];
    expireColor = json['expire_color'];
    detail = json['detail'];
    usefor = json['usefor'];
    method = json['method'];
    itemincartSunit = json['itemincartSunit'];
    itemincartMunit = json['itemincartMunit'];
    itemincartLunit = json['itemincartLunit'];
    limitS = json['limitS'];
    limitM = json['limitM'];
    limitL = json['limitL'];
    subtractS = json['subtract_s'];
    subtractM = json['subtract_m'];
    subtractL = json['subtract_l'];
    btnAdd1 = json['btnAdd1'];
    btnAdd2 = json['btnAdd2'];
    recommend = json['recommend'];
    promotion = json['promotion'];
    updateprice = json['updateprice'];
    newproduct = json['newproduct'];
    notreceive = json['notreceive'];
    favorite = json['favorite'];
    stock = json['stock'];
    cateID = json['cateID'];
    cateName = json['cateName'];
    youtube = json['youtube'];
    tiktok = json['tiktok'];
    pricelabel = json['pricelabel'];
    pricesale = json['pricesale'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['hilight'] = this.hilight;
    data['extrapoint'] = this.extrapoint;
    data['product_code'] = this.productCode;
    data['photo'] = this.photo;
    if (this.priceList != null) {
      data['price_list'] = this.priceList!.toJson();
    }
    data['expire'] = this.expire;
    data['expire_color'] = this.expireColor;
    data['detail'] = this.detail;
    data['usefor'] = this.usefor;
    data['method'] = this.method;
    data['itemincartSunit'] = this.itemincartSunit;
    data['itemincartMunit'] = this.itemincartMunit;
    data['itemincartLunit'] = this.itemincartLunit;
    data['limitS'] = this.limitS;
    data['limitM'] = this.limitM;
    data['limitL'] = this.limitL;
    data['subtract_s'] = this.subtractS;
    data['subtract_m'] = this.subtractM;
    data['subtract_l'] = this.subtractL;
    data['btnAdd1'] = this.btnAdd1;
    data['btnAdd2'] = this.btnAdd2;
    data['recommend'] = this.recommend;
    data['promotion'] = this.promotion;
    data['updateprice'] = this.updateprice;
    data['newproduct'] = this.newproduct;
    data['notreceive'] = this.notreceive;
    data['favorite'] = this.favorite;
    data['stock'] = this.stock;
    data['id'] = this.id;
    data['cateID'] = this.cateID;
    data['cateName'] = this.cateName;
    data['youtube'] = this.youtube;
    data['tiktok'] = this.tiktok;
    data['pricelabel'] = this.pricelabel;
    data['pricesale'] = this.pricesale;
    return data;
  }
}

class PriceList {
  S? s;

  PriceList({this.s});

  PriceList.fromJson(Map<String, dynamic> json) {
    s = json['s'] != null ? new S.fromJson(json['s']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.s != null) {
      data['s'] = this.s!.toJson();
    }
    return data;
  }
}

class S {
  String? lable;
  String? price;
  String? unit;
  String? limitorder;

  S({this.lable, this.price, this.unit});

  S.fromJson(Map<String, dynamic> json) {
    lable = json['lable'];
    price = json['price'];
    unit = json['unit'];
    limitorder = json['limitorder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lable'] = this.lable;
    data['price'] = this.price;
    data['unit'] = this.unit;
    data['limitorder'] = this.limitorder;
    return data;
  }
}
