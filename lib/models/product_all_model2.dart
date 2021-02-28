class ProductAllModel2 {
  String title;
  String productCode;
  String photo;
  PriceList priceList;
  String expire;
  String expireColor;
  String detail;
  int itemincartSunit;
  int itemincartMunit;
  int itemincartLunit;
  int recommend;
  int promotion;
  int updateprice;
  int newproduct;
  int notreceive;
  int stock;
  int id;

  ProductAllModel2(
      {this.title,
      this.productCode,
      this.photo,
      this.priceList,
      this.expire,
      this.expireColor,
      this.detail,
      this.itemincartSunit,
      this.itemincartMunit,
      this.itemincartLunit,
      this.recommend,
      this.promotion,
      this.updateprice,
      this.newproduct,
      this.notreceive,
      this.stock,
      this.id});

  ProductAllModel2.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    productCode = json['product_code'];
    photo = json['photo'];
    priceList = json['price_list'] != null
        ? new PriceList.fromJson(json['price_list'])
        : null;
    expire = json['expire'];
    expireColor = json['expire_color'];
    detail = json['detail'];
    itemincartSunit = json['itemincartSunit'];
    itemincartMunit = json['itemincartMunit'];
    itemincartLunit = json['itemincartLunit'];
    recommend = json['recommend'];
    promotion = json['promotion'];
    updateprice = json['updateprice'];
    newproduct = json['newproduct'];
    notreceive = json['notreceive'];
    stock = json['stock'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['product_code'] = this.productCode;
    data['photo'] = this.photo;
    if (this.priceList != null) {
      data['price_list'] = this.priceList.toJson();
    }
    data['expire'] = this.expire;
    data['expire_color'] = this.expireColor;
    data['detail'] = this.detail;
    data['itemincartSunit'] = this.itemincartSunit;
    data['itemincartMunit'] = this.itemincartMunit;
    data['itemincartLunit'] = this.itemincartLunit;
    data['recommend'] = this.recommend;
    data['promotion'] = this.promotion;
    data['updateprice'] = this.updateprice;
    data['newproduct'] = this.newproduct;
    data['notreceive'] = this.notreceive;
    data['stock'] = this.stock;
    data['id'] = this.id;
    return data;
  }
}

class PriceList {
  S s;

  PriceList({this.s});

  PriceList.fromJson(Map<String, dynamic> json) {
    s = json['s'] != null ? new S.fromJson(json['s']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.s != null) {
      data['s'] = this.s.toJson();
    }
    return data;
  }
}

class S {
  String lable;
  String price;
  String unit;

  S({this.lable, this.price, this.unit});

  S.fromJson(Map<String, dynamic> json) {
    lable = json['lable'];
    price = json['price'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lable'] = this.lable;
    data['price'] = this.price;
    data['unit'] = this.unit;
    return data;
  }
}
