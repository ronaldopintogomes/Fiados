import 'dart:convert';
import 'dart:io';

import 'package:fiados/modelo/Conta.dart';
import 'package:fiados/modelo/Fiado.dart';
import 'package:path_provider/path_provider.dart';

class Servico {

  Future<File> get file async {
    final diretorio = await getApplicationDocumentsDirectory();
    File arquivo = File(diretorio.path+'/contas.json');
    await arquivo.exists().then((value){
      if(!value) {
        arquivo.createSync();
        arquivo.writeAsStringSync('[]');
      }
    });
    return arquivo;
  }

  salvarDados(String dados) async {
    await file.then((f) {
      f.writeAsStringSync(dados);
    });
  }


  Future<List<Conta>> get contas async {
    List<Conta> contas;
    await file.then((value) async {
      String conteudo = await value.readAsStringSync();
      Iterable lista = json.decode(conteudo);
      contas = lista.map((model) => Conta.fromJson(model)).toList();
    });
    return contas;
  }

  novaConta(String nome) async {
    bool hasNome = false;

    await contas.then((listaContas) {
      if(listaContas == null) {
        listaContas = new List<Conta>();
        Conta novaConta = new Conta(nome: nome, fiados: null);
        listaContas.add(novaConta);
      } else {
        if(listaContas.isEmpty) {
          Conta novaConta = new Conta(nome: nome, fiados: null);
          listaContas.add(novaConta);
        } else {
          for(Conta conta in listaContas) {
            if(conta.nome == nome) {
              hasNome = true;
              break;
            }
          }
          if(!hasNome) {
            Conta novaConta = new Conta(nome: nome, fiados: null);
            listaContas.add(novaConta);
          }
        }
      }
      salvarDados(json.encode(listaContas));
    });
  }

  removerConta(String nome) async {
    await contas.then((listaContas){
      listaContas.removeWhere((element) => element.nome == nome);
      salvarDados(json.encode(listaContas));
    });
  }

  novoFiado(Conta contaVisao, Fiado novoFiado) async {
    await contas.then((listaContas) {
      for(Conta conta in listaContas) {
        if(conta.nome == contaVisao.nome) {
          if(conta.fiados == null) {
            conta.fiados = new List<Fiado>();
            conta.fiados.add(novoFiado);
          } else {
            conta.fiados.add(novoFiado);
          }
          break;
        }
      }
      salvarDados(json.encode(listaContas));
    });
  }

  removerFiado(String nome, String hora) async {
    await contas.then((listaContas){
      for(Conta conta in listaContas) {
        if(conta.nome == nome) {
          conta.fiados.removeWhere((element) => element.hora == hora);
          break;
        }
      }
      salvarDados(json.encode(listaContas));
    });
  }

  Future<double> get valorTotalDasConta async {
    double valorTotal = 0.0;
    await contas.then((listaContas) {
      if(listaContas.isNotEmpty) {
        listaContas.forEach((conta) {
          if(conta.fiados != null && conta.fiados.isNotEmpty) {
            conta.fiados.forEach((fiado) {
              valorTotal += fiado.valor;
            });
          }
        });
      }
    });
    return valorTotal;
  }

  Future<double> valorTotalFiado(String nome) async {
    double valorTotal = 0.0;
    await contas.then((listaContas) {
      for(Conta conta in listaContas) {
        if(conta.nome == nome) {
          if(conta.fiados != null) {
            if(conta.fiados.isNotEmpty) {
              for(Fiado fiado in conta.fiados) {
                valorTotal += fiado.valor;
              }
            }
          }
          break;
        }
      }
    });
    return valorTotal;
  }
}