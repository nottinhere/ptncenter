class RewardredeemModel {
  int? rwId;
  String? customerCode;
  String? rwCode;
  String? rwSubject;
  String? barcode;
  String? point;
  String? qty;
  String? unit;
  String? warehouse;
  String? note;
  String? photo;

  RewardredeemModel(
      {this.rwId,
      this.customerCode,
      this.rwCode,
      this.rwSubject,
      this.barcode,
      this.point,
      this.qty,
      this.unit,
      this.warehouse,
      this.note,
      this.photo});

  RewardredeemModel.fromJson(Map<String, dynamic> json) {
    rwId = json['rw_id'];
    customerCode = json['customer_code'];
    rwCode = json['rw_code'];
    rwSubject = json['rw_subject'];
    barcode = json['barcode'];
    point = json['point'];
    qty = json['qty'];
    unit = json['unit'];
    warehouse = json['warehouse'];
    note = json['note'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rw_id'] = rwId;
    data['customer_code'] = customerCode;
    data['rw_code'] = rwCode;
    data['rw_subject'] = rwSubject;
    data['barcode'] = barcode;
    data['point'] = point;
    data['qty'] = qty;
    data['unit'] = unit;
    data['warehouse'] = warehouse;
    data['note'] = note;
    data['photo'] = photo;
    return data;
  }
}
