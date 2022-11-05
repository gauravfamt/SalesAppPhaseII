import 'package:moblesales/helpers/index.dart';
import 'package:moblesales/models/index.dart';

class Invoices {
  final String DocumentNo;
  final String DocumentType;
  final String CustomerNo;
  final String DocumentDate;
  final double PaidAmount;
  final double DocumentTotal;
  final double AmountDue;
  final String Status;
  final bool IsReportAvailable;
  final List<InvoiceDetails> invoiceDetails;
  bool IsSelected;
  List<QuoteInvoicingElement> quoteInvoicingElement;

  Invoices({
    this.DocumentNo,
    this.DocumentType,
    this.CustomerNo,
    this.DocumentDate,
    this.PaidAmount,
    this.DocumentTotal,
    this.AmountDue,
    this.Status,
    this.IsReportAvailable,
    this.invoiceDetails,
    this.IsSelected = false,
    this.quoteInvoicingElement
  });

  factory Invoices.fromJson(Map<String, dynamic> json) {
    String _documentDate = json['DocumentDate'] as String;
    _documentDate = Other().DisplayDate(_documentDate);

    var invoiceDetailsListFromJson = json['InvoiceDetails'] as List;var
    quoteInvoicingListFromJson = json['InvoiceInvoicingElement'] as List;

    List<InvoiceDetails> InvoiceDetailsList = invoiceDetailsListFromJson
        .map((i) => InvoiceDetails.fromJson(i))
        .toList();

    List<QuoteInvoicingElement> invoicingElementList =
    quoteInvoicingListFromJson.map((i) => QuoteInvoicingElement.fromJson(i)).toList();

    return Invoices(
      DocumentNo: json['DocumentNo'] as String,
      DocumentType: json['DocumentType'] as String,
      CustomerNo: json['CustomerNo'] as String,
      DocumentDate: _documentDate,
      PaidAmount: json['PaidAmount'] as double,
      DocumentTotal: json['DocumentTotal'] as double,
      AmountDue: json['AmountDue'] as double,
      Status: json['Status'] as String,
      IsReportAvailable: json['IsReportAvailable'] as bool,
      invoiceDetails: InvoiceDetailsList,
      IsSelected: false,
      quoteInvoicingElement: invoicingElementList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DocumentNo': DocumentNo,
      'DocumentType': DocumentType,
      'CustomerNo': CustomerNo,
      'DocumentDate': DocumentDate,
      'PaidAmount': PaidAmount.toStringAsFixed(2),
      'DocumentTotal': DocumentTotal.toStringAsFixed(2),
      'AmountDue': AmountDue.toStringAsFixed(2),
      'Status': Status,
      'IsReportAvailable': IsReportAvailable,
      'invoiceDetails': invoiceDetails,
      'IsSelected': IsSelected,
      'quoteInvoicingElement': quoteInvoicingElement,
    };
  }
}
