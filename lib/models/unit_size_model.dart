class UnitSizeModel {
  String? lable;
  String? price;
  String? unit;

  UnitSizeModel({this.lable, this.price, this.unit});

  UnitSizeModel.fromJson(Map<String, dynamic> json) {
    lable = json['lable'];
    price = json['price'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lable'] = lable;
    data['price'] = price;
    data['unit'] = unit;
    return data;
  }
}
