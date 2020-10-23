import 'package:fiados/Servico/Servico.dart';
import 'package:fiados/modelo/Conta.dart';
import 'package:fiados/visao/Fiados.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class Contas extends StatefulWidget {
  @override
  _ContasState createState() => _ContasState();
}

class _ContasState extends State<Contas> {
  List<Conta> _listaDeContasServico = List<Conta>();
  List<Conta> _listaDeContasVisao = List<Conta>();
  List<Conta> _listaPesquisa = List<Conta>();
  TextEditingController _textFieldControlePesquisaConta = TextEditingController();
  TextEditingController _textFieldControleNovaConta = TextEditingController();
  BehaviorSubject<List<Conta>> _controleStream = BehaviorSubject<List<Conta>>();
  Sink<List<Conta>> _inputStream;

  @override
  void initState() {
    super.initState();
    _inputStream = _controleStream.sink;
    _inputStream.add(_listaDeContasVisao);
    Servico().contas.then((lista) {
      if(lista != null) {
        setState(() {
          lista.sort((a, b) => a.nome.compareTo(b.nome));
          _listaDeContasServico.addAll(lista);
          _listaDeContasVisao.addAll(lista);
        });
      }
    });
  }

  novaConta() {
    String nome = _textFieldControleNovaConta.text.toUpperCase().trim();
    bool hasNome = false;
    if(nome.isNotEmpty) {
      _listaDeContasVisao.forEach((conta) {
        if(nome == conta.nome) {
          hasNome = true;
        }
      });
      if(!hasNome) {
        Servico().novaConta(nome);
        Conta novaConta = Conta(nome: nome, fiados: null);
        _inputStream.add(_listaDeContasVisao);
        setState(() {
          _listaDeContasVisao.add(novaConta);
          _listaDeContasVisao.sort((a, b) => a.nome.compareTo(b.nome));
        });
        _textFieldControleNovaConta.clear();
      }
    }
  }

  deletarConta(String nome) {
    setState(() {
      _listaDeContasVisao.removeWhere((element) => element.nome == nome);
    });
    Servico().removerConta(nome);
  }

  pequisar() {
    String pesquisa = _textFieldControlePesquisaConta.text.toUpperCase().trim();
    _inputStream.add(_listaPesquisa);
    _listaPesquisa.clear();
    if(pesquisa.isEmpty) {
      setState(() {
        _listaPesquisa.addAll(_listaDeContasVisao);
      });
    } else {
      for(Conta conta in _listaDeContasVisao) {
        if(conta.nome.startsWith(pesquisa)) {
          _listaPesquisa.add(conta);
        }
      }
      setState(() {
        _listaPesquisa.sort((a, b) => a.nome.compareTo(b.nome));
      });
    }
  }

  Widget getValorTotalDasContas() {
    Servico().valorTotalDasConta.then((valor){
      return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
          title: Text('Valor total:'),
          backgroundColor: Colors.greenAccent,
          content: Container(
            height: 50,
            child: Center(
              child: Text('$valor',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contas'),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 7, right: 7, top: 10),
              child: TextFormField(
                autofocus: false,
                style: TextStyle(
                  fontSize: 20,
                ),
                controller: _textFieldControlePesquisaConta,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Pesquisar',
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (_) {
                  pequisar();
                },
              ),
            ),
            StreamBuilder<List<Conta>>(
              stream: _controleStream.stream,
              builder: (context, AsyncSnapshot<List<Conta>> snapshot) {
                if((snapshot.data == null) || (snapshot.data.length == 0)) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 200),
                      child: Text('Lista Vazia'),
                    ),
                  );
                } else {
                  return Flexible(
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          child: Container (
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(left: 8, right: 8, top: 3),
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    alignment: Alignment.centerLeft,
                                    child:Text(
                                      snapshot.data.elementAt(index).nome,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    alignment: Alignment.centerLeft,
                                    child:Text(''),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    child: Container(
                                      height: 50,
                                      padding: EdgeInsets.only(right: 20),
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        Icons.delete_forever,
                                      ),
                                      decoration: BoxDecoration(
                                        border: new Border(
                                          left: new BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => AlertDialog(
                                          title: Text('Confirmar'),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('Ok'),
                                              onPressed: () {
                                                deletarConta(snapshot.data.elementAt(index).nome);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('Cancelar'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white,
                                    blurRadius: 0.0,
                                  ),
                                ]
                            ),
                          ),
                          onTap: () {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context){
                                return Fiados(snapshot.data.elementAt(index));
                              }),
                            );
                          },
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar (
        type: BottomNavigationBarType.fixed,
        elevation: 9.0,
        backgroundColor: Colors.deepOrange[500],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add,color: Colors.white,),
            title: Text('Nova conta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money, color: Colors.white),
            title: Text('Valor total',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
        onTap: (index) {
          switch(index) {
            case 0:
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  title: Text('Nova conta'),
                  content: TextFormField(
                    controller: _textFieldControleNovaConta,
                    decoration: InputDecoration(
                      hintText: 'Digite aqui',
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Ok'),
                      onPressed: () {
                        novaConta();
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Cancelar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
              break;
            case 1:
              getValorTotalDasContas();
              break;
          }
        },
      ),
    );
  }
}