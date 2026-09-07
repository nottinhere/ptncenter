class LicenseAlertModel {
  int? id;
  String? subject;
  String? detail;
  String? postdate;
  String? popstatus;

  LicenseAlertModel(
      {this.id, this.subject, this.detail, this.postdate, this.popstatus});

  LicenseAlertModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subject = json['subject'];
    detail = json['detail'];
    postdate = json['postdate'];
    popstatus = json['popstatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['subject'] = subject;
    data['detail'] = detail;
    data['postdate'] = postdate;
    data['popstatus'] = popstatus;
    return data;
  }
}
