import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'main.dart';

void _postTransaction(String amount, String description, String token) {
  http.post
  (
    Uri.parse('https://finance.core2duo.fr/api.php?request=post_new_transaction&token=$token'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'amount': amount,
      'description': description,
    }),
  );
}

void main() {
  runApp(MyNewTransaction());
}

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
class MyNewTransaction extends StatelessWidget {
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
      home: MyNewTransactionPage(title: 'EPICOLOC'),
      debugShowCheckedModeBanner: false,

    );
  }
}

class MyNewTransactionPage extends StatefulWidget {
  MyNewTransactionPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyNewTransactionPageState createState() => _MyNewTransactionPageState();
}

//
// Sous classe principale de l'application
//
class _MyNewTransactionPageState extends State<MyNewTransactionPage> {
    late String token;
    TextEditingController descriptionController = new TextEditingController();
    TextEditingController amountController = new TextEditingController();
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
                        });
                      });
      });}

    //
    // Widget principal
    // De type Future car la variable transactionsList est de type Future (Cf fonction requête)
    //
      @override
  Widget build(BuildContext context) {
        final _formKey = GlobalKey<FormState>();

          return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter une nouvelle dépense"),
      ),
      body: Center
      (
        child: Form
          (
            key: _formKey,
            child: Column
            (
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: 
              [
                Container
                    (
                      margin: const EdgeInsets.only(top: 20.0, bottom:20.0, left: 20.0, right:20.0),
                      child: TextFormField
                      (
                        controller: amountController,
                        // The validator receives the text that the user has entered.
                        validator: (value) 
                        {
                          if (value == null || value.isEmpty) 
                          {
                            return 'Aucun montant inséré...';
                          }
                          return null;
                        },
                        decoration: InputDecoration
                        (
                          hintText: 'Montant'
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                Container
                    (
                      margin: const EdgeInsets.only(top: 20.0, bottom:20.0, left: 20.0, right:20.0),
                      child: TextFormField
                      (
                        controller: descriptionController,
                        // The validator receives the text that the user has entered.
                        validator: (value) 
                        {
                          if (value == null || value.isEmpty) 
                          {
                            return 'Aucune description insérée...';
                          }
                          return null;
                        },
                        decoration: InputDecoration
                        (
                          hintText: 'Description'
                        ),
                      ),
                    ),
                Container
                    (
                      margin: const EdgeInsets.only(top: 20.0, bottom:20.0),
                      child: Center
                      (
                        child: ElevatedButton
                                (
                                  onPressed: ()
                                  {
                                    if (_formKey.currentState!.validate()) 
                                    {
                                      if (int.parse(amountController.text) >= 0)
                                      {
                                        _postTransaction(amountController.text, descriptionController.text, token);
                                        ScaffoldMessenger.of(context).showSnackBar
                                        (
                                          SnackBar(content: Text('La transaction de ${amountController.text}€ a bien été enregistrée !')),
                                        );
                                        //
                                        // Normalement navigator.pop, mais ne fonctionne pas
                                        // Changer navigator.push en navigator.pop si trop de bugs sont observés
                                        //
                                        Navigator.push
                                        (
                                          context,
                                          MaterialPageRoute(builder: (context) => MyApp()),
                                        );
                                      }
                                      else
                                      {
                                        ScaffoldMessenger.of(context).showSnackBar
                                        (
                                          SnackBar(content: Text('Une dépense négative est impossible.......!')),
                                        );
                                      }
                                    }
                                  },
                                  child: Text('Enregistrer'),
                                  style: ElevatedButton.styleFrom
                                  (
                                    shape: new RoundedRectangleBorder
                                    (
                                      borderRadius: new BorderRadius.circular(10.0),
                                    ),
                                    padding: EdgeInsets.all(20.0),
                                  ),
                                )
                      )
                    ),
              ],
            ),
          )
      )
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