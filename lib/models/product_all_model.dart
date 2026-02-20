class ProductAllModel {
  String? title;
  String? hilight;
  String? extrapoint;
  String? productCode;
  String? photo;
  String? selectUnit;
  String? priceList;
  String? itemSprice;
  String? itemSunit;
  String? itemincartSunit;
  String? itemMprice;
  String? itemMunit;
  String? itemincartMunit;
  String? itemLprice;
  String? itemLunit;
  String? itemincartLunit;
  String? itemFeqSunit;
  String? itemFeqMunit;
  String? itemFeqLunit;
  String? detail;
  String? usefor;
  String? method;
  int? stock;
  int? id;

  ProductAllModel(
      {this.title,
      this.hilight,
      this.extrapoint,
      this.productCode,
      this.photo,
      this.priceList,
      this.selectUnit,
      this.itemSprice,
      this.itemSunit,
      this.itemincartSunit,
      this.itemMprice,
      this.itemMunit,
      this.itemincartMunit,
      this.itemLprice,
      this.itemLunit,
      this.itemincartLunit,
      this.itemFeqSunit,
      this.itemFeqMunit,
      this.itemFeqLunit,
      this.detail,
      this.usefor,
      this.method,
      this.stock,
      this.id});

  ProductAllModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    hilight = json['hilight'];
    extrapoint = json['extrapoint'];
    productCode = json['product_code'];
    photo = json['photo'];
    priceList = json['price_list'];
    selectUnit = json['selectUnit'];
    itemSprice = json['itemSprice'];
    itemSunit = json['itemSunit'];
    itemincartSunit = json['itemincartSunit'];
    itemMprice = json['itemMprice'];
    itemMunit = json['itemMunit'];
    itemincartMunit = json['itemincartMunit'];
    itemLprice = json['itemLprice'];
    itemLunit = json['itemLunit'];
    itemincartLunit = json['itemincartLunit'];
    itemFeqSunit = json['itemFeqSunit'];
    itemFeqMunit = json['itemFeqMunit'];
    itemFeqLunit = json['itemFeqLunit'];
    detail = json['detail'];
    usefor = json['usefor'];
    method = json['method'];
    stock = json['stock'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['hilight'] = this.hilight;
    data['extrapoint'] = this.extrapoint;
    data['product_code'] = this.productCode;
    data['photo'] = this.photo;
    data['price_list'] = this.priceList;
    data['selectUnit'] = this.selectUnit;
    data['itemSprice'] = this.itemSprice;
    data['itemSunit'] = this.itemSunit;
    data['itemincartSunit'] = this.itemincartSunit;
    data['itemMprice'] = this.itemMprice;
    data['itemMunit'] = this.itemMunit;
    data['itemincartMunit'] = this.itemincartMunit;
    data['itemLprice'] = this.itemLprice;
    data['itemLunit'] = this.itemLunit;
    data['itemincartLunit'] = this.itemincartLunit;
    data['itemFeqSunit'] = this.itemFeqSunit;
    data['itemFeqMunit'] = this.itemFeqMunit;
    data['itemFeqLunit'] = this.itemFeqLunit;
    data['detail'] = this.detail;
    data['usefor'] = this.usefor;
    data['method'] = this.method;
    data['stock'] = this.stock;
    data['id'] = this.id;
    return data;
  }
}
