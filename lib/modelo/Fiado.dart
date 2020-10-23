class Fiado {
  String data;
  String hora;
  double valor;

  Fiado({this.data, this.hora, this.valor});

  Fiado.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    hora = json['hora'];
    valor = json['valor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = this.data;
    data['hora'] = this.hora;
    data['valor'] = this.valor;
    return data;
  }
}