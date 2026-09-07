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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customer_code'] = customerCode;
    data['shopname'] = shopname;
    data['orn_no'] = ornNo;
    data['box'] = box;
    data['note'] = note;
    data['total'] = total;
    data['amount'] = amount;
    data['shipping'] = shipping;
    data['cn'] = cn;
    data['cn_ref'] = cnRef;
    data['datepost'] = datepost;
    data['datemodify'] = datemodify;
    data['paytype'] = paytype;
    data['paydate'] = paydate;
    data['ref'] = ref;
    data['ship_id'] = shipId;
    data['shipping_box'] = shippingBox;
    data['shipping_orndate'] = shippingOrndate;    
    data['delivery_box'] = deliveryBox;
    data['delivery_date'] = deliveryDate;
    data['delivery_note'] = deliveryNote;
    data['delivery_reply'] = deliveryReply;
    data['billing_balance'] = billingBalance;
    data['billing_status'] = billingStatus;
    data['billing_date'] = billingDate;
    data['status'] = status;
    data['bill_no'] = billNo;
    return data;
  }
}
