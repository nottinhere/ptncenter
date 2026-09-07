class RewardCategoryModel {
  String? cateId;
  String? cateName;
  String? status;

  RewardCategoryModel({this.cateId, this.cateName, this.status});

  RewardCategoryModel.fromJson(Map<String, dynamic> json) {
    cateId = json['cate_id']?.toString();
    cateName = json['cate_name']?.toString();
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cate_id'] = cateId;
    data['cate_name'] = cateName;
    data['status'] = status;
    return data;
  }
}
