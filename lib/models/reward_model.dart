class RewardModel {
  int? id;
  String? code;
  String? barcode;
  String? subject;
  String? detail;
  String? point;
  String? stock;
  String? maxqty;
  String? unit;
  String? cateId;
  String? warehouse;
  String? status;
  String? photo;

  RewardModel(
      {this.id,
      this.code,
      this.barcode,
      this.subject,
      this.detail,
      this.point,
      this.stock,
      this.maxqty,
      this.unit,
      this.cateId,
      this.warehouse,
      this.status,
      this.photo});

  RewardModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    barcode = json['barcode'];
    subject = json['subject'];
    detail = json['detail'];
    point = json['point'];
    stock = json['stock'];
    maxqty = json['maxqty'];
    unit = json['unit'];
    cateId = json['cate_id'];
    warehouse = json['warehouse'];
    status = json['status'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['barcode'] = barcode;
    data['subject'] = subject;
    data['detail'] = detail;
    data['point'] = point;
    data['stock'] = stock;
    data['maxqty'] = maxqty;
    data['unit'] = unit;
    data['cate_id'] = cateId;
    data['warehouse'] = warehouse;
    data['status'] = status;
    data['photo'] = photo;
    return data;
  }
}
