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
        ? PriceList.fromJson(json['price_list'])
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['hilight'] = hilight;
    data['extrapoint'] = extrapoint;
    data['product_code'] = productCode;
    data['photo'] = photo;
    if (priceList != null) {
      data['price_list'] = priceList!.toJson();
    }
    data['expire'] = expire;
    data['expire_color'] = expireColor;
    data['detail'] = detail;
    data['usefor'] = usefor;
    data['method'] = method;
    data['itemincartSunit'] = itemincartSunit;
    data['itemincartMunit'] = itemincartMunit;
    data['itemincartLunit'] = itemincartLunit;
    data['limitS'] = limitS;
    data['limitM'] = limitM;
    data['limitL'] = limitL;
    data['subtract_s'] = subtractS;
    data['subtract_m'] = subtractM;
    data['subtract_l'] = subtractL;
    data['btnAdd1'] = btnAdd1;
    data['btnAdd2'] = btnAdd2;
    data['recommend'] = recommend;
    data['promotion'] = promotion;
    data['updateprice'] = updateprice;
    data['newproduct'] = newproduct;
    data['notreceive'] = notreceive;
    data['favorite'] = favorite;
    data['stock'] = stock;
    data['id'] = id;
    data['cateID'] = cateID;
    data['cateName'] = cateName;
    data['youtube'] = youtube;
    data['tiktok'] = tiktok;
    data['pricelabel'] = pricelabel;
    data['pricesale'] = pricesale;
    return data;
  }
}

class PriceList {
  S? s;

  PriceList({this.s});

  PriceList.fromJson(Map<String, dynamic> json) {
    s = json['s'] != null ? S.fromJson(json['s']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (s != null) {
      data['s'] = s!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lable'] = lable;
    data['price'] = price;
    data['unit'] = unit;
    data['limitorder'] = limitorder;
    return data;
  }
}
