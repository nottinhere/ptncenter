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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['subject'] = this.subject;
    data['detail'] = this.detail;
    data['postdate'] = this.postdate;
    data['popstatus'] = this.popstatus;
    return data;
  }
}
