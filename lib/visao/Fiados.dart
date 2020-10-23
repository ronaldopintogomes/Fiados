import 'package:fiados/Servico/Servico.dart';
import 'package:fiados/modelo/Conta.dart';
import 'package:fiados/modelo/Fiado.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class Fiados extends StatefulWidget {
  Conta conta;

  Fiados(this.conta);

  @override
  _FiadosState createState() => _FiadosState();
}

class _FiadosState extends State<Fiados> {
  TextEditingController _textFieldControleValor = TextEditingController();
  List<Fiado> _listaFiadosVisao = List<Fiado>();
  BehaviorSubject<List<Fiado>> _controleStream = BehaviorSubject<List<Fiado>>();
  Sink<List<Fiado>> _inputStream;

  @override
  void initState() {
    super.initState();
    _inputStream = _controleStream.sink;
    _inputStream.add(_listaFiadosVisao);
    Servico().contas.then((listaContas) {
      for(Conta conta in listaContas) {
        if(conta.nome == widget.conta.nome) {
          if(conta.fiados != null) {
            setState(() {
              _listaFiadosVisao.addAll(conta.fiados);
            });
          }
          break;
        }
      }
    });
  }

  novoFiado() {
    final DateTime dateTime = DateTime.now();
    String data = DateFormat('dd/MM/yyyy').format(dateTime);
    String hora = DateFormat(DateFormat.HOUR24_MINUTE).format(dateTime);
    double valor = double.parse(_textFieldControleValor.text.trim().isEmpty ? '0.0' : _textFieldControleValor.text.trim());

    Fiado novoFiado = Fiado(data: data, hora: hora, valor: valor);

    Servico().novoFiado(widget.conta, novoFiado);

    _inputStream.add(_listaFiadosVisao);
    setState(() {
      _listaFiadosVisao.add(novoFiado);
    });
    _textFieldControleValor.clear();
  }

  deletarFiado(String hora) {
    setState(() {
      _listaFiadosVisao.removeWhere((element) => element.hora == hora);
    });
    Servico().removerFiado(widget.conta.nome, hora);
  }

  Widget valorTotal() {
    Servico().valorTotalFiado(widget.conta.nome).then((valorTotal) {
      return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
          title: Text('Valor total:'),
          backgroundColor: Colors.greenAccent,
          content: Container(
            height: 50,
            child: Center(
              child: Text('$valorTotal',
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
        title: Text('Fiados - '+widget.conta.nome),
        centerTitle: true,
      ),body: Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          StreamBuilder<List<Fiado>>(
              stream: _controleStream.stream,
              builder: (context, AsyncSnapshot<List<Fiado>> snapshot) {
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
                          return Container(
                            height: 80,
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(left: 8, right: 8, top: 3),
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Data     '+ snapshot.data.elementAt(index).data,
                                        style: TextStyle(
                                          fontSize: 18,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Divider(height: 5, color: Colors.greenAccent),
                                      Text('Hora     '+snapshot.data.elementAt(index).hora,
                                        style: TextStyle(
                                          fontSize: 18,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Divider(height: 5, color: Colors.greenAccent),
                                      Text('Valor  R\$'+ snapshot.data.elementAt(index).valor.toString(),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                GestureDetector(
                                  child: Container(
                                    width: 70,
                                    padding: EdgeInsets.only(right: 20),
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.delete_forever,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
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
                                              deletarFiado(snapshot.data.elementAt(index).hora);
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

                              ],
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.greenAccent,
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
                          );
                        }
                    ),
                  );
                }
              }
          ),
        ],
      ),
    ),
      bottomNavigationBar: BottomNavigationBar (
        type: BottomNavigationBarType.fixed,
        elevation: 10.0,
        backgroundColor: Colors.deepOrange[500],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.white),
            title: Text('Novo fiado',
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
                  title: Text('Novo fiado'),
                  content: TextFormField(
                    controller: _textFieldControleValor,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Informe o valor',
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Ok'),
                      onPressed: () {
                        novoFiado();
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
              valorTotal();
              break;
          }
        },
      ),
    );
  }
}