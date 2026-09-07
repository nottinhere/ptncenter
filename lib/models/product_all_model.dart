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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['hilight'] = hilight;
    data['extrapoint'] = extrapoint;
    data['product_code'] = productCode;
    data['photo'] = photo;
    data['price_list'] = priceList;
    data['selectUnit'] = selectUnit;
    data['itemSprice'] = itemSprice;
    data['itemSunit'] = itemSunit;
    data['itemincartSunit'] = itemincartSunit;
    data['itemMprice'] = itemMprice;
    data['itemMunit'] = itemMunit;
    data['itemincartMunit'] = itemincartMunit;
    data['itemLprice'] = itemLprice;
    data['itemLunit'] = itemLunit;
    data['itemincartLunit'] = itemincartLunit;
    data['itemFeqSunit'] = itemFeqSunit;
    data['itemFeqMunit'] = itemFeqMunit;
    data['itemFeqLunit'] = itemFeqLunit;
    data['detail'] = detail;
    data['usefor'] = usefor;
    data['method'] = method;
    data['stock'] = stock;
    data['id'] = id;
    return data;
  }
}
