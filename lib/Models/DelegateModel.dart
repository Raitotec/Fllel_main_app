class DelegateModel {
  int? id;
  String? name;


  DelegateModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];

  }

  DelegateModel(this.id, this.name, );
}