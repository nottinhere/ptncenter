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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['barcode'] = this.barcode;
    data['subject'] = this.subject;
    data['detail'] = this.detail;
    data['point'] = this.point;
    data['stock'] = this.stock;
    data['maxqty'] = this.maxqty;
    data['unit'] = this.unit;
    data['cate_id'] = this.cateId;
    data['warehouse'] = this.warehouse;
    data['status'] = this.status;
    data['photo'] = this.photo;
    return data;
  }
}
