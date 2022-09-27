import 'package:moblesales/helpers/index.dart';

class Product {
  int Id;
  String ProductCode;
  String Description;
  String Status;
  String ProductCategory;
  String ProductKey;
  double BasePrice;
  String BaseUnit;
  double Weight;
  String IsTaxable;
  String UPCCode;
  DateTime CreatedDate;
  DateTime UpdatedDate;
  String WeightUOM;
  String Image;
  bool isSelected; //USED FOR CHECKBOX SELECTION IN LISTING
  //Added by Gaurav Gurav, 21-sep-2022
  String Description2;
  String Description3;

  Product({
    this.Id,
    this.ProductCode,
    this.Description,
    this.Status,
    this.ProductCategory,
    this.ProductKey,
    this.BasePrice,
    this.BaseUnit,
    this.Weight,
    this.IsTaxable,
    this.UPCCode,
    this.CreatedDate,
    this.UpdatedDate,
    this.WeightUOM,
    this.Image,
    this.isSelected = false,
    this.Description2='',
    this.Description3='',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    DateTime _createdDate = DateTime.parse(json['CreatedDate'] as String);
    DateTime _updatedDate = DateTime.parse(json['UpdatedDate'] as String);
    return Product(
      Id: json['Id'] as int,
      ProductCode: json['ProductCode'] as String,
      Description: json['Description'] as String,
      Status: json['Status'] as String,
      ProductCategory: json['ProductCategory'] as String,
      ProductKey: json['ProductKey'] as String,
      BasePrice: json['BasePrice'] as double,
      BaseUnit: json['BaseUnit'] as String,
      Weight: json['Weight'] as double,
      IsTaxable: json['IsTaxable'] as String,
      UPCCode: json['UPCCode'] as String,
      CreatedDate: _createdDate,
      UpdatedDate: _updatedDate,
      WeightUOM: json['WeightUOM'] as String,
      Image: json['Image'] as String,
      isSelected: false,
      Description2: json['Description2'] as String,
      Description3: json['Description3'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'ProductCode': ProductCode,
      'Description': Other().parseHtmlString(
          Description), //to remove html characters like &amp; amp; &nbsp: ,
      'Status': Status,
      'ProductCategory': ProductCategory,
      'ProductKey': ProductKey,
      'BasePrice':
          BasePrice.toStringAsFixed(2), //<<-- to display value as 20.00,
      'BaseUnit': BaseUnit,
      'Weight': Weight,
      'IsTaxable': IsTaxable,
      'UPCCode': UPCCode,
      'CreatedDate': CreatedDate,
      'UpdatedDate': UpdatedDate,
      'WeightUOM': Weight.toString()+' '+ WeightUOM,
      'Image': Image,
      'isSelected': isSelected,
      'Description2': Other().parseHtmlString(
          Description2), //to remove html characters like &amp; amp; &nbsp: ,
      'Description3': Other().parseHtmlString(
          Description3), //to remove html characters like &amp; amp; &nbsp: ,
    };
  }
}
