class PriceListModel {
  String? lable;
  String? price;
  String? unit;
  String? quantity;
  String? pricechange;

  PriceListModel(
      {this.lable, this.price, this.unit, this.quantity, this.pricechange});

  PriceListModel.fromJson(Map<String, dynamic> json) {
    lable = json['lable'];
    price = json['price'];
    unit = json['unit'];
    quantity = json['quantity'];
    pricechange = json['pricechange'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lable'] = lable;
    data['price'] = price;
    data['unit'] = unit;
    data['quantity'] = quantity;
    data['pricechange'] = pricechange;
    return data;
  }
}
