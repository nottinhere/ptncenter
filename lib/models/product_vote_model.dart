class ProductVoteModel {
  String title;
  String genericname;
  String usefor;
  String method;
  String company;
  String pricelabel;
  String pricesale;
  String votescore;
  bool yourvote;
  String photo;
  String detail;
  int id;

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['genericname'] = this.genericname;
    data['usefor'] = this.usefor;
    data['method'] = this.method;
    data['company'] = this.company;
    data['pricelabel'] = this.pricelabel;
    data['pricesale'] = this.pricesale;
    data['votescore'] = this.votescore;
    data['yourvote'] = this.yourvote;
    data['photo'] = this.photo;
    data['detail'] = this.detail;
    data['id'] = this.id;
    return data;
  }
}
