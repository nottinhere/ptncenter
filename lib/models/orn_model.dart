class OrnModel {
  int? id;
  String? customerCode;
  String? shopname;
  String? ornNo;
  String? box;
  String? note;
  String? total;
  String? amount;
  String? shipping;
  String? cn;
  String? cnRef;
  String? datepost;
  String? datemodify;
  String? paytype;
  String? paydate;
  String? ref;
  String? shipId;
  String? shippingBox;
  String? shippingOrndate;
  String? deliveryBox;
  String? deliveryDate;
  String? deliveryNote;
  String? deliveryReply;
  String? billingBalance;
  String? billingStatus;
  String? billingDate;
  String? status;
  String? billNo;

  OrnModel(
      {this.id,
      this.customerCode,
      this.shopname,
      this.ornNo,
      this.box,
      this.note,
      this.total,
      this.amount,
      this.shipping,
      this.cn,
      this.cnRef,
      this.datepost,
      this.datemodify,
      this.paytype,
      this.paydate,
      this.ref,
      this.shipId,
      this.shippingBox,
      this.shippingOrndate,
      this.deliveryBox,
      this.deliveryDate,
      this.deliveryNote,
      this.deliveryReply,
      this.billingBalance,
      this.billingStatus,
      this.billingDate,
      this.status,
      this.billNo});

  OrnModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerCode = json['customer_code'];
    shopname = json['shopname'];
    ornNo = json['orn_no'];
    box = json['box'];
    note = json['note'];
    total = json['total'];
    amount = json['amount'];
    shipping = json['shipping'];
    cn = json['cn'];
    cnRef = json['cn_ref'];
    datepost = json['datepost'];
    datemodify = json['datemodify'];
    paytype = json['paytype'];
    paydate = json['paydate'];
    ref = json['ref'];
    shipId = json['ship_id'];
    shippingBox = json['shipping_box'];
    shippingOrndate = json['shipping_orndate'];
    deliveryBox = json['delivery_box'];
    deliveryDate = json['delivery_date'];
    deliveryNote = json['delivery_note'];
    deliveryReply = json['delivery_reply'];
    billingBalance = json['billing_balance'];
    billingStatus = json['billing_status'];
    billingDate = json['billing_date'];
    status = json['status'];
    billNo = json['bill_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customer_code'] = this.customerCode;
    data['shopname'] = this.shopname;
    data['orn_no'] = this.ornNo;
    data['box'] = this.box;
    data['note'] = this.note;
    data['total'] = this.total;
    data['amount'] = this.amount;
    data['shipping'] = this.shipping;
    data['cn'] = this.cn;
    data['cn_ref'] = this.cnRef;
    data['datepost'] = this.datepost;
    data['datemodify'] = this.datemodify;
    data['paytype'] = this.paytype;
    data['paydate'] = this.paydate;
    data['ref'] = this.ref;
    data['ship_id'] = this.shipId;
    data['shipping_box'] = this.shippingBox;
    data['shipping_orndate'] = this.shippingOrndate;    
    data['delivery_box'] = this.deliveryBox;
    data['delivery_date'] = this.deliveryDate;
    data['delivery_note'] = this.deliveryNote;
    data['delivery_reply'] = this.deliveryReply;
    data['billing_balance'] = this.billingBalance;
    data['billing_status'] = this.billingStatus;
    data['billing_date'] = this.billingDate;
    data['status'] = this.status;
    data['bill_no'] = this.billNo;
    return data;
  }
}
