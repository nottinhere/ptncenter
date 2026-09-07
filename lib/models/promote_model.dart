class PromoteModel {
  String? title;
  String? productCode;
  String? photo;
  String? price;
  String? unit;
  int? stock;
  int? id;

  PromoteModel(
      {this.title,
      this.productCode,
      this.photo,
      this.price,
      this.unit,
      this.stock,
      this.id});

  PromoteModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    productCode = json['product_code'];
    photo = json['photo'];
    price = json['price'];
    unit = json['unit'];
    stock = json['stock'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['product_code'] = productCode;
    data['photo'] = photo;
    data['price'] = price;
    data['unit'] = unit;
    data['stock'] = stock;
    data['id'] = id;
    return data;
  }
}
