import 'package:moblesales/helpers/constants.dart';

class OtherParam {
  final double DISCRGVAL1;
  final double DISCRGVAL2;
  final double DISCRGVAL3;
  final double DISCRGVAL4;
  final double DISCRGVAL5;
  final double DISCRGVAL6;

  OtherParam({
    this.DISCRGVAL1,
    this.DISCRGVAL2,
    this.DISCRGVAL3,
    this.DISCRGVAL4,
    this.DISCRGVAL5,
    this.DISCRGVAL6
  });

  factory OtherParam.fromJson(Map<String, dynamic> json) {
    return OtherParam(
      DISCRGVAL1: json['DISCRGVAL1'] as double,
      DISCRGVAL2: json['DISCRGVAL2'] as double,
      DISCRGVAL3: json['DISCRGVAL3'] as double,
      DISCRGVAL4: json['DISCRGVAL4'] as double,
      DISCRGVAL5: json['DISCRGVAL5'] as double,
      DISCRGVAL6: json['DISCRGVAL6'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DISCRGVAL1': DISCRGVAL1,
      'DISCRGVAL2': DISCRGVAL2,
      'DISCRGVAL3': DISCRGVAL3,
      'DISCRGVAL4': DISCRGVAL4,
      'DISCRGVAL5': DISCRGVAL5,
      'DISCRGVAL6': DISCRGVAL6,
    };
  }

//  Map<String, dynamic> toStringify() {
//
//    return {
//      '\\"DISCRGVAL1\\"': DISCRGVAL1,
//      '\\"DISCRGVAL2\\"': DISCRGVAL2,
//      '\\"DISCRGVAL3\\"': DISCRGVAL3,
//      '\\"DISCRGVAL4\\"': DISCRGVAL4,
//      '\\"DISCRGVAL5\\"': DISCRGVAL5,
//      '\\"DISCRGVAL6\\"': DISCRGVAL6,
//    };
//  }

  Map<String, dynamic> toStringify() {
    return {
      '*DISCRGVAL1*': DISCRGVAL1,
      '*DISCRGVAL2*': DISCRGVAL2,
      '*DISCRGVAL3*': DISCRGVAL3,
      '*DISCRGVAL4*': DISCRGVAL4,
      '*DISCRGVAL5*': DISCRGVAL5,
      '*DISCRGVAL6*': DISCRGVAL6,
    };
  }

}
