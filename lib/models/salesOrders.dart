import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';

class SalesOrders {
  final String DocumentNo;
  final String DocumentDate;
  final String DocumentType;
  final String CustomerNo;
  final String Description;
  final String PONumber;
  final double DocumentTotal;
  final String DeliveryStatus;
  final String CurrencyCode;
  final String CreatedDate;
  final String UpdatedDate;
  final String OrderEntryType;
  final int TenantId;
  final String SalesSite;
  final List<OrderDetails> orderdetails;
  bool isSelected; //USED FOR CHECKBOX SELECTION IN LISTING

  SalesOrders({
    this.DocumentNo,
    this.DocumentDate,
    this.DocumentType,
    this.CustomerNo,
    this.Description,
    this.PONumber,
    this.DocumentTotal,
    this.DeliveryStatus,
    this.CurrencyCode,
    this.CreatedDate,
    this.UpdatedDate,
    this.OrderEntryType,
    this.TenantId,
    this.SalesSite,
    this.orderdetails,
    this.isSelected = false,
  });

  factory SalesOrders.fromJson(Map<String, dynamic> json) {
    var orderDetailsListFromJson = json['Orderdetails'] as List;

    List<OrderDetails> ordersList =
        orderDetailsListFromJson.map((i) => OrderDetails.fromJson(i)).toList();

    String _documentDate = json['DocumentDate'] as String;
    //_documentDate = transformDate(dateValue: _documentDate);
    _documentDate = Other().DisplayDate(_documentDate);

    return SalesOrders(
      DocumentNo: json['DocumentNo'] as String,
      DocumentDate: _documentDate,
      DocumentType: json['DocumentType'] as String,
      CustomerNo: json['CustomerNo'] as String,
      Description: json['Description'] as String,
      PONumber: json['PONumber'] as String,
      DocumentTotal: json['DocumentTotal'] as double,
      DeliveryStatus: json['DeliveryStatus'] as String,
      CurrencyCode: json['CurrencyCode'] as String,
      CreatedDate: json['CreatedDate'] as String,
      UpdatedDate: json['UpdatedDate'] as String,
      OrderEntryType: json['OrderEntryType'] as String,
      TenantId: json['TenantId'] as int,
      SalesSite: json['SalesSite'] as String,
      orderdetails: ordersList,
      isSelected: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DocumentNo': DocumentNo,
      'DocumentDate': DocumentDate,
      'DocumentType': DocumentType,
      'CustomerNo': CustomerNo,
      'Description': Other().parseHtmlString(
          Description), //to remove html characters like &amp; amp; &nbsp:
      'PONumber': PONumber,
      'DocumentTotal': DocumentTotal.toStringAsFixed(2),
      'DeliveryStatus': DeliveryStatus,
      'CurrencyCode': CurrencyCode,
      'CreatedDate': CreatedDate,
      'UpdatedDate': UpdatedDate,
      'OrderEntryType': OrderEntryType,
      'TenantId': TenantId,
      'SalesSite': SalesSite,
      'orderdetails': orderdetails,
      'isSelected': isSelected,
    };
  }
}
