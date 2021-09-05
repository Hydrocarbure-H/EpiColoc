import 'package:epicoloc/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'main.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

//
// Fonction qui effectue la requête GET get_all_transactions_to_pay
// Renvoie une liste d'Item
//
Future<List<Item>> getTransactions(token) async {
  //Authentificator token_auth = Authentificator();
  final response = await http
      .get(Uri.parse('https://finance.core2duo.fr/api.php?request=get_transactions_to_pay&token=$token'));
  if (response.statusCode == 200) {
    var tmp = jsonDecode(response.body) as List;
    List<Item> listItems = tmp.map((transJson) => Item.fromJson(transJson)).toList();
    return listItems;
  } else {
    throw Exception('Failed to load Transaction');
  }
}

//
// Fonction qui effectue une requête POST pour le remboursement d'une personne
//
void _payback(String author) {
  http.post
  (
    Uri.parse('https://finance.core2duo.fr/api.php?request=payback'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'author': author,
    }),
  );
}

//
// Classe Item : Permet de récupérer le Nom : Montant à rembourser facilement
//
class Item {
  final String author;
  final String id;
  final String amount;

  Item({
    required this.author,
    required this.id,
    required this.amount,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      author: json['author'],
      id: json['id'].toString(),
      amount: json['amount'].toString(),

    );
  }

  String toString()
  {
    return "Ceci est un test : {${this.author}}";
  }
}

//
// Affichage de chaque Item
//
class ItemView extends StatelessWidget {
  
  final Item item;

  ItemView(this.item);
  @override
  Widget build(BuildContext context) {
    return OutlinedButton
    (
      style: OutlinedButton.styleFrom
      (
        side: BorderSide(width: 0, color: Colors.white),
      ),
      //
      // ShowDialog permet d'afficher un message avec une confirmation et un choix
      //
      onPressed: () => showDialog<String>
      (
      context: context,
      builder: (BuildContext context) => AlertDialog
      (
        title: const Text('Remboursement'),
        content: Text
        (
          'Souhaitez-vous rembourser ${item.author} ?'
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Annuler'),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () 
            {
              _payback(item.author);
              //
              // Affiche une bannière en bas d'écran
              //
              ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Remboursement en cours...')));
              //
              // Revient sur l'écran précédent
              //
              Navigator.pop(context, 'Rembourser');
            },
            child: const Text('Rembourser'),
          ),
        ],
      ),
    ),
      child:Container
      (
        //
        // Premier Conteneur : Bouton pour une seule personne
        //
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: EdgeInsets.only(top:10, bottom:10, left:10, right:10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: 
          [
            Expanded
            (
              child: Column
              (
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                [
                  Text
                  (
                    '${item.author}',
                    style: TextStyle
                    (
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFFFFFFFF)
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: 
              [
                Text
                (
                  '${item.amount}€',
                  style: TextStyle
                  (
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                    color: Color(0xFFBBBBBB)
                  ),
                )
              ],
            ),
          ],
        ),
      )
    );
  }
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


void main() {
  runApp(MyMenu());
}

//
// Classe principale de l'application
//
class MyMenu extends StatelessWidget {
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
      home: MyMenuPage(title: 'EPICOLOC'),
      debugShowCheckedModeBanner: false,

    );
  }
}

class MyMenuPage extends StatefulWidget {
  MyMenuPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyMenuPageState createState() => _MyMenuPageState();
}

//
// Sous classe principale de l'application
//
class _MyMenuPageState extends State<MyMenuPage> {
    late Future<List<Item>> transaction_to_pay_List;
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
                        transaction_to_pay_List = getTransactions(token);
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
                          transaction_to_pay_List = getTransactions(token);
                        });
                      });
      });}

    //
    // Widget principal
    // De type Future car la variable transactionsList est de type Future (Cf fonction requête)
    //
      @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: transaction_to_pay_List,
      builder: (context, snapshot) 
      {
        if (snapshot.hasData) {
          List<Item> data = snapshot.data as List<Item>;
          return Scaffold
          (
            appBar: AppBar
            (
              title: Text
              (
                "Profil",
                style: TextStyle
                (
                  fontWeight: FontWeight.normal,
                  fontSize: 30,
                ),
              ),
            ),
            body: Center
              (
                child: Column
                (
                  children: <Widget>
                  [
                    Container
                    (
                      margin: EdgeInsets.only(top:20, bottom:40),
                      child: Text
                      (
                        "Sommes à rembourser",
                        style: TextStyle
                        (
                          fontWeight: FontWeight.normal,
                          fontSize: 30,
                          color: Color(0xFF568ca8)
                        ),
                      ),
                    ),
                    Expanded
                    (
                      //
                      // Important !
                      // Initialement impossible de mettre une Liste de Widgets en Children
                      // C'est finalement possible en la mettant en child dans un Expanded()
                      // TRES UTILE !
                      child: _buildListView(data),
                    ),
                    Container
                    (
                      child: ElevatedButton
                        (
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF2C2C2E),
                            onPrimary: Colors.white,
                          ),
                          onPressed: () 
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Déconnexion en cours... L\'application va quitter !')));
                            final storage = new FlutterSecureStorage();
                            storage.delete(key: "token");
                            exit(0);
                          },
                          child: const Text('Déconnexion'),
                        ),
                    )
                  ],
                )
              ),
          );              
          
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return LinearProgressIndicator();
      }
    );
  }
  //
// Construit la liste de Widgets
//
  Widget _buildListView(List<Item> item) 
  {
    return ListView.builder(
      itemBuilder: (ctx, idx) {
        return ItemView(item[idx]);
      },
      itemCount: item.length,
    );
  }
}