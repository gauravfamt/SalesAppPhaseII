class LoginResponse {
  final String AccessToken;

  LoginResponse({this.AccessToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      AccessToken: json['AccessToken'] as String
    );
  }
}