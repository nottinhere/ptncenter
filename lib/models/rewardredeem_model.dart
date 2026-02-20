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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rw_id'] = this.rwId;
    data['customer_code'] = this.customerCode;
    data['rw_code'] = this.rwCode;
    data['rw_subject'] = this.rwSubject;
    data['barcode'] = this.barcode;
    data['point'] = this.point;
    data['qty'] = this.qty;
    data['unit'] = this.unit;
    data['warehouse'] = this.warehouse;
    data['note'] = this.note;
    data['photo'] = this.photo;
    return data;
  }
}
