import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

_recuperarBancoDados() async {
  final caminhoBancoDados = await getDatabasesPath();
  final localBancoDados = join(caminhoBancoDados, "banco.bd");

  List _contas = [];

  var bd = await openDatabase(
      localBancoDados,
      version: 2,
      onCreate: (db, dbVersaoRecente) {
        db.execute("CREATE TABLE usuarios (id INTEGER PRIMARY KEY AUTOINCREMENT, nome VARCHAR, senha VARCHAR) ");
        db.execute("CREATE TABLE contas (id INTEGER PRIMARY KEY AUTOINCREMENT, nome VARCHAR, preco FLOAT, idUsuario INTEGER) ");
      },
      onOpen: (Database db) async {
        // Database is open, print its version
        print('db version ${await db.getVersion()}');
      }
  );
  return bd;
}

_adicionarConta(String nome, Float preco, String validade) async {
  Database bd = await _recuperarBancoDados();
  Map<String, dynamic> contas = {
    "nome" : nome,
    "preco" : preco,
    "validade": validade
  };
  int id = await bd.insert("contas", contas);
  print("Conta Salva: $id " );
}

_listarContas() async{
  Database bd = await _recuperarBancoDados();
  String sql = "SELECT * FROM contas";
  List contas = await bd.rawQuery(sql); //conseguimos escrever a query que quisermos
  _contas = [];
  for(var usu in contas){
    _contas.add(usu['nome']+"\t"+usu['validade']+"\t"+usu['preco'].toString())
  }
}

_atualizarContas(String nome, Float preco, String validade){
  Database bd = await _recuperarBancoDados();
  await bd.rawQuery('UPDATE contas SET name = (?), preco = (?), validade=(?) WHERE name = (?)', [nome,preco,validade,nome]);
  _listarContas();
}

_deletarContas(String nome){
  Database bd = await _recuperarBancoDados();
  await db.rawQuery('DELETE FROM contas WHERE name = (?)', [nome]);
  _listarContas();
}

class PaginaListaDeContas extends StatefulWidget {
  @override
  _PaginaListaDeContasState createState() => _PaginaListaDeContasState();

}

class _PaginaListaDeContasState extends State<PaginaListaDeContas> {
  List _listaCompras = ["SANTANDER  10/01/2021  RS 100,00", "Conta de Luz 15/02/2021  RS 98,90", "Internet  03/02/2021  RS 119,90"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LISTA DE CONTAS"),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.endDocked, //usar com o BottomNavigationBar
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightGreen,
          elevation: 6,
          child: Icon(Icons.add),
          onPressed: (){
            print("Botão pressionado!");
            showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    title: Text("Adicionar conta: "),
                    content: TextField(
                      decoration: InputDecoration(
                          labelText: "Digite a descrição da conta"
                      ),
                      onChanged: (text){

                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Text("Cancelar")
                      ),
                      TextButton(
                          onPressed: (){

                          },
                          child: Text("Salvar")
                      ),
                      TextButton(
                          onPressed: (){

                          },
                          child: Text("Pagar")
                      ),
                    ],
                  );
                }
            );
          }
      ),

      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: _listaCompras.length,
                itemBuilder: (context, index){
                  return ListTile(
                    title: Text(_listaCompras[index]),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}
