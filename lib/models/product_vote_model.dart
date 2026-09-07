class ProductVoteModel {
  String? title;
  String? genericname;
  String? usefor;
  String? method;
  String? company;
  String? pricelabel;
  String? pricesale;
  String? votescore;
  bool? yourvote;
  String? photo;
  String? detail;
  int? id;

  ProductVoteModel(
      {this.title,
      this.genericname,
      this.usefor,
      this.method,
      this.company,
      this.pricelabel,
      this.pricesale,
      this.votescore,
      this.yourvote,
      this.photo,
      this.detail,
      this.id});

  ProductVoteModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    genericname = json['genericname'];
    usefor = json['usefor'];
    method = json['method'];
    company = json['company'];
    pricelabel = json['pricelabel'];
    pricesale = json['pricesale'];
    votescore = json['votescore'];
    yourvote = json['yourvote'];
    photo = json['photo'];
    detail = json['detail'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['genericname'] = genericname;
    data['usefor'] = usefor;
    data['method'] = method;
    data['company'] = company;
    data['pricelabel'] = pricelabel;
    data['pricesale'] = pricesale;
    data['votescore'] = votescore;
    data['yourvote'] = yourvote;
    data['photo'] = photo;
    data['detail'] = detail;
    data['id'] = id;
    return data;
  }
}
