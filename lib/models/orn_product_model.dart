class OrnProductModel {
  int? odId;
  int? oId;
  String? medId;
  String? productCode;
  String? title;
  String? warehouse;
  String? hilight;
  String? station;
  int? medStock;
  int? medStockTop;
  int? qty;
  int? receive;
  String? unit;
  String? size;
  String? photo;

  OrnProductModel(
      {this.odId,
      this.oId,
      this.medId,
      this.productCode,
      this.title,
      this.warehouse,
      this.hilight,
      this.station,
      this.medStock,
      this.medStockTop,
      this.qty,
      this.receive,
      this.unit,
      this.size,
      this.photo});

  OrnProductModel.fromJson(Map<String, dynamic> json) {
    odId = json['od_id'];
    oId = json['o_id'];
    medId = json['med_id'];
    productCode = json['product_code'];
    title = json['title'];
    warehouse = json['warehouse'];
    hilight = json['hilight'];
    station = json['station'];
    medStock = json['medStock'];
    medStockTop = json['medStockTop'];
    qty = json['qty'];
    receive = json['receive'];
    unit = json['unit'];
    size = json['size'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['od_id'] = this.odId;
    data['o_id'] = this.oId;
    data['med_id'] = this.medId;
    data['product_code'] = this.productCode;
    data['title'] = this.title;
    data['warehouse'] = this.warehouse;
    data['hilight'] = this.hilight;
    data['station'] = this.station;
    data['medStock'] = this.medStock;
    data['medStockTop'] = this.medStockTop;
    data['qty'] = this.qty;
    data['receive'] = this.receive;
    data['unit'] = this.unit;
    data['size'] = this.size;
    data['photo'] = this.photo;
    return data;
  }
}
