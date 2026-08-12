class RewardExtrapointModel {
  String? id;
  String? medId;
  String? medName;
  String? subject;
  String? size;
  String? qty;
  String? point;

  RewardExtrapointModel(
      {this.id,
      this.medId,
      this.medName,
      this.subject,
      this.size,
      this.qty,
      this.point});

  RewardExtrapointModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    medId = json['med_id'];
    medName = json['med_name'];
    subject = json['subject'];
    size = json['size'];
    qty = json['qty'];
    point = json['point'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['med_id'] = this.medId;
    data['med_name'] = this.medName;
    data['subject'] = this.subject;
    data['size'] = this.size;
    data['qty'] = this.qty;
    data['point'] = this.point;
    return data;
  }
}
