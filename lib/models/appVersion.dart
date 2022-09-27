class AppVersion{
  int Id;
  String App;
  String Version;

  AppVersion({
    this.Id,
    this.App,
    this.Version,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      Id: json['Id'] as int,
      App: json['App'] as String,
      Version: json['Version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'App':App,
      'Version':Version,
    };
  }
}

