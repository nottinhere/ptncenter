class GiftModel {
  String? id;
  String? code;
  String? name;
  String? warehouse;
  String? station;
  String? cateId;
  String? stock;
  String? unit;
  String? status;
  String? cMin;
  String? cMax;

  GiftModel(
      {this.id,
      this.code,
      this.name,
      this.warehouse,
      this.station,
      this.cateId,
      this.stock,
      this.unit,
      this.status,
      this.cMin,
      this.cMax});

  GiftModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    warehouse = json['warehouse'];
    station = json['station'];
    cateId = json['cate_id'];
    stock = json['stock'];
    unit = json['unit'];
    status = json['status'];
    cMin = json['c_min'];
    cMax = json['c_max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['warehouse'] = this.warehouse;
    data['station'] = this.station;
    data['cate_id'] = this.cateId;
    data['stock'] = this.stock;
    data['unit'] = this.unit;
    data['status'] = this.status;
    data['c_min'] = this.cMin;
    data['c_max'] = this.cMax;
    return data;
  }
}
