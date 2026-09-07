class PopupModel {
  int? id;
  String? subject;
  String? detail;
  String? txtBTN;
  String? url;
  String? postdate;
  String? diffdate;
  int? absdiffdate;
  String? photo;
  String? document;
  String? popstatus;

  PopupModel(
      {this.id,
      this.subject,
      this.detail,
      this.txtBTN,
      this.url,
      this.postdate,
      this.diffdate,
      this.absdiffdate,
      this.photo,
      this.document,
      this.popstatus});

  PopupModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subject = json['subject'];
    detail = json['detail'];
    txtBTN = json['txtBTN'];
    url = json['url'];
    postdate = json['postdate'];
    diffdate = json['diffdate'];
    absdiffdate = json['absdiffdate'];
    photo = json['photo'];
    document = json['document'];
    popstatus = json['popstatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['subject'] = subject;
    data['detail'] = detail;
    data['txtBTN'] = txtBTN;
    data['url'] = url;
    data['postdate'] = postdate;
    data['diffdate'] = diffdate;
    data['absdiffdate'] = absdiffdate;
    data['photo'] = photo;
    data['document'] = document;
    data['popstatus'] = popstatus;
    return data;
  }
}
