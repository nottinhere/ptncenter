class UserModel {
  String? id;
  String? customerCode;
  String? user;
  String? pass;
  String? level;
  String? type;
  String? name;
  String? address;
  String? province;
  String? zipcode;
  String? phone;
  String? email;
  String? cart;
  String? status;
  String? proId;
  String? telecart;
  String? contactPerson;
  String? idcart;
  String? payment;
  String? area;
  String? note;
  String? licenseID;
  String? licenseType;
  String? number;
  String? discount;
  String? financialAmount;
  String? cartJson;
  String? lineID;
  String? facebook;
  int? lastNewsOpen;
  int? lastNotifyOpen;
  int? point;
  int? lastNewsId;
  int? lastNotifyId;
  int? unpaidorn;
  int? unpaidorder;
  double? totalIncart;
  String? firsunpaiddate;
  String? credittermAlert;
  String? financialamountAlert;
  String? contactAdminAlert;
  int? countpricechange;
  String? promotionalert;
  String? promotionsuccess;
  String? lastupdateLicense;
  int? lastupdateLicenseYear;
  String? lastupdateLicenseStatus;
  String? lastupdateLicenseReason;
  String? msg;

  UserModel(
      {this.id,
      this.customerCode,
      this.user,
      this.pass,
      this.level,
      this.type,
      this.name,
      this.address,
      this.province,
      this.zipcode,
      this.phone,
      this.email,
      this.cart,
      this.status,
      this.proId,
      this.telecart,
      this.contactPerson,
      this.idcart,
      this.payment,
      this.area,
      this.note,
      this.licenseID,
      this.licenseType,
      this.number,
      this.discount,
      this.financialAmount,
      this.cartJson,
      this.lineID,
      this.facebook,
      this.lastNewsOpen,
      this.lastNotifyOpen,
      this.point,
      this.lastNewsId,
      this.lastNotifyId,
      this.unpaidorn,
      this.unpaidorder,
      this.totalIncart,
      this.firsunpaiddate,
      this.credittermAlert,
      this.financialamountAlert,
      this.contactAdminAlert,
      this.countpricechange,
      this.promotionalert,
      this.promotionsuccess,
      this.lastupdateLicense,
      this.lastupdateLicenseYear,
      this.lastupdateLicenseStatus,
      this.lastupdateLicenseReason,
      this.msg});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerCode = json['customer_code'];
    user = json['user'];
    pass = json['pass'];
    level = json['level'];
    type = json['type'];
    name = json['name'];
    address = json['address'];
    province = json['province'];
    zipcode = json['zipcode'];
    phone = json['phone'];
    email = json['email'];
    cart = json['cart'];
    status = json['status'];
    proId = json['pro_id'];
    telecart = json['telecart'];
    contactPerson = json['contact_person'];
    idcart = json['idcart'];
    payment = json['payment'];
    area = json['area'];
    note = json['note'];
    licenseID = json['licenseID'];
    licenseType = json['licenseType'];
    number = json['number'];
    discount = json['discount'];
    financialAmount = json['financial_amount'];
    cartJson = json['cart_json'];
    lineID = json['lineID'];
    facebook = json['facebook'];
    lastNewsOpen = json['last_news_open'];
    lastNotifyOpen = json['last_notify_open'];
    point = json['point'];
    lastNewsId = json['last_news_id'];
    lastNotifyId = json['last_notify_id'];
    unpaidorn = json['unpaidorn'];
    unpaidorder = json['unpaidorder'];
    totalIncart = json['totalIncart'];
    firsunpaiddate = json['firsunpaiddate'];
    credittermAlert = json['credittermAlert'];
    financialamountAlert = json['financialamountAlert'];
    contactAdminAlert = json['contactAdminAlert'];
    countpricechange = json['countpricechange'];
    promotionalert = json['promotionalert'];
    promotionsuccess = json['promotionsuccess'];
    lastupdateLicense = json['lastupdateLicense'];
    lastupdateLicenseYear = json['lastupdateLicenseYear'];
    lastupdateLicenseStatus = json['lastupdateLicenseStatus'];
    lastupdateLicenseReason = json['lastupdateLicenseReason'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customer_code'] = customerCode;
    data['user'] = user;
    data['pass'] = pass;
    data['level'] = level;
    data['type'] = type;
    data['name'] = name;
    data['address'] = address;
    data['province'] = province;
    data['zipcode'] = zipcode;
    data['phone'] = phone;
    data['email'] = email;
    data['cart'] = cart;
    data['status'] = status;
    data['pro_id'] = proId;
    data['telecart'] = telecart;
    data['contact_person'] = contactPerson;
    data['idcart'] = idcart;
    data['payment'] = payment;
    data['area'] = area;
    data['note'] = note;
    data['licenseID'] = licenseID;
    data['licenseType'] = licenseType;
    data['number'] = number;
    data['discount'] = discount;
    data['financial_amount'] = financialAmount;
    data['cart_json'] = cartJson;
    data['lineID'] = lineID;
    data['facebook'] = facebook;
    data['last_news_open'] = lastNewsOpen;
    data['last_notify_open'] = lastNotifyOpen;
    data['point'] = point;
    data['last_news_id'] = lastNewsId;
    data['last_notify_id'] = lastNotifyId;
    data['unpaidorn'] = unpaidorn;
    data['unpaidorder'] = unpaidorder;
    data['totalIncart'] = totalIncart;
    data['firsunpaiddate'] = firsunpaiddate;
    data['credittermAlert'] = credittermAlert;
    data['financialamountAlert'] = financialamountAlert;
    data['contactAdminAlert'] = contactAdminAlert;
    data['countpricechange'] = countpricechange;
    data['promotionalert'] = promotionalert;
    data['promotionsuccess'] = promotionsuccess;
    data['lastupdateLicense'] = lastupdateLicense;
    data['lastupdateLicenseYear'] = lastupdateLicenseYear;
    data['lastupdateLicenseStatus'] = lastupdateLicenseStatus;
    data['lastupdateLicenseReason'] = lastupdateLicenseReason;
    data['msg'] = msg;
    return data;
  }
}
