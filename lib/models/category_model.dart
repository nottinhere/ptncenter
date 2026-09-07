class CategoryModel {
  int? cateId;
  String? cateName;
  int? retail;

  CategoryModel({this.cateId, this.cateName, this.retail});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    cateId = json['cate_id'] is String
        ? int.tryParse(json['cate_id'])
        : json['cate_id'];
    cateName = json['cate_name'];
    retail = json['retail'] is String
        ? int.tryParse(json['retail'])
        : json['retail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cate_id'] = cateId;
    data['cate_name'] = cateName;
    data['retail'] = retail;
    return data;
  }
}
