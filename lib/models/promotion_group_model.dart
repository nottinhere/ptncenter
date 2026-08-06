class PromotionGroupModel {
  String? id;
  String? code;
  String? name;
  String? hilight;
  String? med;
  String? target;
  String? gift;
  String? limitgift;

  PromotionGroupModel(
      {this.id,
      this.code,
      this.name,
      this.hilight,
      this.med,
      this.target,
      this.gift,
      this.limitgift});

  PromotionGroupModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    hilight = json['hilight'];
    med = json['med'];
    target = json['target'];
    gift = json['gift'];
    limitgift = json['limitgift'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['hilight'] = this.hilight;
    data['med'] = this.med;
    data['target'] = this.target;
    data['gift'] = this.gift;
    data['limitgift'] = this.limitgift;
    return data;
  }

  List<String> get medIds =>
      (med ?? '').split(',').where((s) => s.trim().isNotEmpty).toList();
}
