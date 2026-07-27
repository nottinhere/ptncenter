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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cate_id'] = this.cateId;
    data['cate_name'] = this.cateName;
    data['status'] = this.status;
    return data;
  }
}
