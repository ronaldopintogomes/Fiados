import 'package:fiados/modelo/Fiado.dart';

class Conta {
  String nome;
  List<Fiado> fiados;

  Conta({this.nome, this.fiados});

  Conta.fromJson(Map<String, dynamic> json) {
    nome = json['nome'];
    if (json['fiados'] != null) {
      fiados = new List<Fiado>();
      json['fiados'].forEach((v) {
        fiados.add(new Fiado.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nome'] = this.nome;
    if (this.fiados != null) {
      data['fiados'] = this.fiados.map((v) => v.toJson()).toList();
    }
    return data;
  }
}