class ModelHelper {
  String val;
  String type;

  ModelHelper({
    this.val,
    this.type,
  });

//fromJson
  ModelHelper.fromJson(Map<String, dynamic> json) {
    val = json['val'];
    type = json['type'];
  }

//toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['val'] = this.val;
    data['type'] = this.type;
    return data;
  }
}
