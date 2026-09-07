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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['med_id'] = medId;
    data['med_name'] = medName;
    data['subject'] = subject;
    data['size'] = size;
    data['qty'] = qty;
    data['point'] = point;
    return data;
  }
}
