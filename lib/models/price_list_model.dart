class PriceListModel {
  String lable;
  String price;
  String unit;
  String quantity;
  String pricechange;

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lable'] = this.lable;
    data['price'] = this.price;
    data['unit'] = this.unit;
    data['quantity'] = this.quantity;
    data['pricechange'] = this.pricechange;
    return data;
  }
}
