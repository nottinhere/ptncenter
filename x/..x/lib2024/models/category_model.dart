class CategoryModel {
  int? cateId;
  String? cateName;
  int? retail;

  CategoryModel({this.cateId, this.cateName, this.retail});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    cateId = json['cate_id'];
    cateName = json['cate_name'];
    retail = json['retail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cate_id'] = this.cateId;
    data['cate_name'] = this.cateName;
    data['retail'] = this.retail;
    return data;
  }
}
