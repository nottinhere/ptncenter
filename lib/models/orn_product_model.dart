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
  int? sale;

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
      this.photo,
      this.sale});

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
    sale = json['sale'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['od_id'] = odId;
    data['o_id'] = oId;
    data['med_id'] = medId;
    data['product_code'] = productCode;
    data['title'] = title;
    data['warehouse'] = warehouse;
    data['hilight'] = hilight;
    data['station'] = station;
    data['medStock'] = medStock;
    data['medStockTop'] = medStockTop;
    data['qty'] = qty;
    data['receive'] = receive;
    data['unit'] = unit;
    data['size'] = size;
    data['photo'] = photo;
    data['sale'] = sale;
    return data;
  }
}
