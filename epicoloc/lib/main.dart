import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'menu.dart';
import 'new.dart';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//
// Fonction qui effectue la requete pour obtenir toutes les transactions du groupe
// Elle retourne une Future liste de Transaction.
// Future obligatoire pour une fonction async
//
Future<List<Transaction>> getTransactions(token) async {
  final response = await http
      .get(Uri.parse('https://finance.core2duo.fr/api.php?request=get_all_transactions&token=$token'));
  if (response.statusCode == 200) {
    var tmp = jsonDecode(response.body) as List;
    List<Transaction> listTransactions = tmp.map((transJson) => Transaction.fromJson(transJson)).toList();
    return listTransactions;
  } else {
    throw Exception('Failed to load Transaction');
  }
}

//
// Classe créée pour la requete
//
class Transaction {
  final String author;
  final String id;
  final String description;
  final String amount;
  final String date;

  Transaction({
    required this.author,
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      author: json['author'],
      id: json['id'],
      description: json['description'],
      amount: json['amount'],
      date: json['date'],

    );
  }

  String toString()
  {
    return "Ceci est un test : {${this.author}}";
  }
}

//
// Classe qui permet l'affichage d'une transaction en tant qu'élément
// Elle est appellée pour l'affichage de chaque élément Transaction
//
class TransactionView extends StatelessWidget {
  final Transaction transaction;

  TransactionView(this.transaction);
  @override
  Widget build(BuildContext context) {
    return Container
    (
      //
      // Premier Conteneur. Permet de gérer les marges et le padding
      // Le conteneur est équivalent à UNE Transaction
      //
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      margin: EdgeInsets.only(top:10, bottom:0, left:0, right:0),
      decoration: BoxDecoration
      (
        //
        // Gère les bordures du conteneur
        //
        border: Border
          (
            bottom: BorderSide
            (
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: 
        [
          Expanded
          (
            //
            // Expanded : Permet de mettre des widgets de taille variable en child
            //
            child: Column
            (
              //
              // Affichage en colone de la date, de l'auteur etc
              //
              crossAxisAlignment: CrossAxisAlignment.start,
              children: 
              [
                Text
                (
                  '${transaction.date}',
                  style: TextStyle
                  (
                    fontStyle: FontStyle.italic,
                    fontSize: 10,
                    color: Color(0xFFBBBBBB)
                  ),
                ),
                Text
                (
                  '${transaction.author}',
                  style: TextStyle
                  (
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text
                (
                  '${transaction.description}',
                  style: TextStyle
                  (
                    fontStyle: FontStyle.italic,
                    fontSize: 17,
                    color: Color(0xFFBBBBBB)
                  ),
                ),
              ],
            ),
          ),
          Row
          (
            //
            // Affichage du prix sur une seule ligne sur le conteneur
            //
            mainAxisSize: MainAxisSize.min,
            children: 
            [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Text
                (
                  '${transaction.amount}€',
                  style: TextStyle
                  (
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                    color: createMaterialColor(Color(0xFF40C8E0))
                  ),
                )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
void main() {
  runApp(MyApp());
}

//
// Récupère le token stocké dans le flutter_secure_storage
//
Future<String> _getToken() async
{
  final storage = new FlutterSecureStorage();
  // ignore: non_constant_identifier_names
  Future<String> storage_token = storage.read(key: "token");
  return storage_token;
}

//
// Classe principale de l'application
//
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp
    (
      title: 'EpiColoc',
      theme: ThemeData
      (
        //
        // Thême global de l'application
        //
        primarySwatch: createMaterialColor(Color(0xFF40C8E0)),
        secondaryHeaderColor: createMaterialColor(Color(0xFF2C2C2E)),
        //scaffoldBackgroundColor: const Color(0xFFEEEEEE),
        brightness: Brightness.dark,
        textTheme: TextTheme
        (
          bodyText1: TextStyle(),
          bodyText2: TextStyle(),
        ).apply
        (
          bodyColor: Color(0xFFffffff), 
          displayColor: Color(0xFFFFFFFF), 
        ),
      ),
      home: MyHomePage(title: 'EPICOLOC'),
      debugShowCheckedModeBanner: false,

    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//
// Sous classe principale de l'application
//
class _MyHomePageState extends State<MyHomePage> {
    late Future<List<Transaction>> transactionsList;
    late String token;
    @override
    //
    // S'effectue au lancement de l'application : effectue la requête get_all_transactions en récupérant le token
    //
    void initState() {
      setState(() {

        super.initState();
        //
        // Cast d'une Future<String> en <String> avec un SetState. Pas possible autrement
        //
        // ignore: non_constant_identifier_names
        _getToken().then((String storage_token)
                    {
                      setState(() {
                        token = storage_token;
                        transactionsList = getTransactions(token);
                      });
                    });
      });}

    //
    // S'effectue au click du bouton Actualiser : effectue la requête get_all_transactions en récupérant le token
    //
    void _refresh() {
      setState(() {
      //
      // Cast d'une Future<String> en <String> avec un SetState. Pas possible autrement
      //
      // ignore: non_constant_identifier_names
      _getToken().then((String storage_token)
                      {
                        setState(() {
                          token = storage_token;
                          transactionsList = getTransactions(token);
                        });
                      });
      });}
    //
    // Widget principal
    // De type Future car la variable transactionsList est de type Future (Cf fonction requête)
    //
      @override
  Widget build(BuildContext context)  {
            //_refresh();

    return FutureBuilder<List<Transaction>>(
      future:transactionsList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //
          // Cast d'une Future<List> en <List> sinon pas traitable pour les widgets
          //
          List<Transaction> data = snapshot.data as List<Transaction>;
          return Scaffold
          (
            appBar: AppBar
            (
              title: Text
              (
                widget.title,
                style: TextStyle
                (
                  fontWeight: FontWeight.normal,
                  fontSize: 30,
                ),
              ),
              actions: <Widget>
              [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Actualiser',
                  onPressed: () {
                    _refresh();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Actualisation en cours...')));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: 'Menu',
                  onPressed: () 
                  {
                    Navigator.push
                    (
                      context,
                      MaterialPageRoute(builder: (context) => MyMenu()),
                    );
                  },
                ),
              ]
            ),
            body: Center
              (
                //
                // Liste des transactions
                //
                child: _buildListView(data),
              ),
              floatingActionButton: FloatingActionButton
              (
                //
                // Bouton permettant d'ajouter une nouvelle transaction
                //
                  onPressed: ()
                  {
                    //
                    // Ouvre une nouvelle page pour ajouter une nouvelle transaction
                    //
                    Navigator.push
                    (
                      context,
                      MaterialPageRoute(builder: (context) => MyNewTransaction()),
                    );
                  },
                  tooltip: 'Ajouter',
                  child: Icon(Icons.add, color:Colors.white),
                  backgroundColor: Theme.of(context).primaryColor,
              ),
          );          
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        //
        // Indicateur de progression
        // Possible de mettre Circular...()
        //
        return LinearProgressIndicator();
      },
    );
  }

  //
  // Génération de la liste des transactions
  // Entrée : La liste provenant de la requête
  // Sortie : une liste de widgets
  //
    Widget _buildListView(List<Transaction> transaction) 
    {
      return ListView.builder
      (
        itemBuilder: (ctx, idx) 
        {
          return TransactionView(transaction[idx]);
        },
        itemCount: transaction.length,
      );
  }
}

//
// Fonction qui transforme une couleur Hexadécimale en MaterialColor
//
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}