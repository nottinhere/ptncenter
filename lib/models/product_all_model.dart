class ProductAllModel {
  String title;
  String productCode;
  String photo;
  String priceList;
  String itemSprice;
  String itemSunit;
  String itemincartSunit;
  String itemMprice;
  String itemMunit;
  String itemincartMunit;
  String itemLprice;
  String itemLunit;
  String itemincartLunit;
  String detail;
  int stock;
  int id;

  ProductAllModel(
      {this.title,
      this.productCode,
      this.photo,
      this.priceList,
      this.itemSprice,
      this.itemSunit,
      this.itemincartSunit,
      this.itemMprice,
      this.itemMunit,
      this.itemincartMunit,
      this.itemLprice,
      this.itemLunit,
      this.itemincartLunit,
      this.detail,
      this.stock,
      this.id});

  ProductAllModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    productCode = json['product_code'];
    photo = json['photo'];
    priceList = json['price_list'];
    itemSprice = json['itemSprice'];
    itemSunit = json['itemSunit'];
    itemincartSunit = json['itemincartSunit'];
    itemMprice = json['itemMprice'];
    itemMunit = json['itemMunit'];
    itemincartMunit = json['itemincartMunit'];
    itemLprice = json['itemLprice'];
    itemLunit = json['itemLunit'];
    itemincartLunit = json['itemincartLunit'];
    detail = json['detail'];
    stock = json['stock'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['product_code'] = this.productCode;
    data['photo'] = this.photo;
    data['price_list'] = this.priceList;
    data['itemSprice'] = this.itemSprice;
    data['itemSunit'] = this.itemSunit;
    data['itemincartSunit'] = this.itemincartSunit;
    data['itemMprice'] = this.itemMprice;
    data['itemMunit'] = this.itemMunit;
    data['itemincartMunit'] = this.itemincartMunit;
    data['itemLprice'] = this.itemLprice;
    data['itemLunit'] = this.itemLunit;
    data['itemincartLunit'] = this.itemincartLunit;
    data['detail'] = this.detail;
    data['stock'] = this.stock;
    data['id'] = this.id;
    return data;
  }
}
