

class ChartsModel {
  List<PieChartModel>? chart;
  int? touchedIndex;

  ChartsModel({this.chart,this.touchedIndex});

  ChartsModel.fromJson(Map<String, dynamic> json) {
    try {
      if (json['chart'] != null) {
        chart = <PieChartModel>[];
        json['chart'].forEach((v) {
          chart!.add(new PieChartModel.fromJson(v));
        });
      }
    }
    catch(e){}
    try {
    if (json['chart_data'] != null) {
      chart = <PieChartModel>[];
      json['chart_data'].forEach((v) {
        chart!.add(new PieChartModel.fromJson(v));
      });
    }
  }
  catch(e){}
    touchedIndex=-1;
  }


}

class PieChartModel {
  int? Id;
  String? name;
  double? value;
  double? percentage;
  String? hex_color;



  PieChartModel({this.Id, this.name, this.value, this.percentage,this.hex_color});

  PieChartModel.fromJson(Map<String, dynamic> json) {

   // Id = json['Id'];
    name = json['name'];
    hex_color = json['hex_color'];
    value = (json['value'] as num).toDouble();
    percentage = (json['percentage']as num).toDouble();
  }


}