class Model {
  Hello hello;

  Model({this.hello});

  Model.fromJson(Map<String, dynamic> json) {
    hello = json['hello'] != null ? Hello.fromJson(json['hello']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.hello != null) {
      data['hello'] = this.hello.toJson();
    }
    return data;
  }
}

class Hello {
  String helloIam1;

  Hello({this.helloIam1});

  Hello.fromJson(Map<String, dynamic> json) {
    helloIam1 = json['helloIam1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['helloIam1'] = this.helloIam1;
    return data;
  }
}
