import 'package:moblesales/helpers/index.dart';

class NotificationPOJO {
  String notificationType;
  String message;
  String createDate;
  String className;

  NotificationPOJO({
    this.notificationType,
    this.message,
    this.createDate,
    this.className,
  });

  factory NotificationPOJO.fromJson(Map<String, dynamic> json) {
    String _createDate = json['createDate'] as String;
    _createDate = Other().DisplayDateTime(_createDate);
    print(_createDate);

    return NotificationPOJO(
      notificationType: json['notificationType'] as String,
      message: json['message'] as String,
      createDate: _createDate,
      className: json['className'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    print(Other().DisplayDate(createDate));
    return {
      'notificationType': notificationType,
      'message': message,
      'createDate': createDate,
      'className': className,
    };
  }
}
