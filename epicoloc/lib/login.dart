import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'main.dart';
import 'webview.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<AuthResponse> _postLogin(String userName, String password) async{
  
  if( userName == "")
  {
    userName = "unknowm";
  }
  if (password == "")
  {
    password = "unknown";
  }
  
  final response =  await http.post
  (
    Uri.parse('https://finance.core2duo.fr/api.php?request=post_auth'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'user_name': userName,
      'password': password,
    }),
  );
  if (response.statusCode == 200) {
    print(response.body.toString());
    return AuthResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to log in. Please try again...!');
  }
  
}

class AuthResponse {
  final String token;
  final String id;
  // ignore: non_constant_identifier_names
  final String is_auth_valid;
  
  AuthResponse({
    required this.token,
    required this.id,
    // ignore: non_constant_identifier_names
    required this.is_auth_valid,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      id: json['id'],
      is_auth_valid: json['is_auth_valid'],
    );
  }
}

void main() {
  runApp(LoginApp());
}

//
// Récupère le token stocké dans le flutter_secure_storage
//
Future<String> _getToken() async
{
  final storage = new FlutterSecureStorage();
  Future<String> storageToken = storage.read(key: "token");
  return storageToken;
}

//
// Vérifie que l'utilisateur est bien connecté à Internet
//
Future<String> _checkInternetConnection() async
{
          
              final result = await InternetAddress.lookup('example.com');
              if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) 
              {
                return "connected";
              }
              else
              {
                return "not_connected";
              }
}

//
// Classe principale de l'application
//
class LoginApp extends StatelessWidget {
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
        primarySwatch: createMaterialColor(Color(0xFF2C2C2E)),
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
    TextEditingController passwordController = new TextEditingController();
    // ignore: non_constant_identifier_names
    TextEditingController user_nameController = new TextEditingController();
    // ignore: non_constant_identifier_names
    Future<AuthResponse>? future_AuthResponse;
    String token = "";
    // ignore: non_constant_identifier_names
    String is_connected = "";
    
    @override
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
        // ignore: non_constant_identifier_names
        _checkInternetConnection().then((String is_connected_response)
                    {
                        setState(() {
                          is_connected = is_connected_response;
                        });
                    });

      });}

    //
    // Widget principal
    // De type Future car la variable transactionsList est de type Future (Cf fonction requête)
    //
      @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Connexion à EpiColoc"),
      ),
      body: (future_AuthResponse == null) ? buildColumn(token) : buildFutureBuilder(),
        
    ); 
}

  SingleChildScrollView buildColumn(token) {
    //
    // A AJOUTER : Verification du token, regeneration etc
    // Pour le moment, simple verification de l'existence du token
    //
    
    if (is_connected == "connected" || kIsWeb)
    {
      if (token != "" && token != null)
      {
        return SingleChildScrollView
        (
          child: Center
            (
              child: Column
              (
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[  
                  Container
                  (
                    margin: EdgeInsets.only(top:20, bottom:40),
                    child: Text
                    (
                      "Connexion établie !",
                      style: TextStyle
                      (
                        fontWeight: FontWeight.normal,
                        fontSize: 30,
                        color: Color(0xFF30D158)
                      ),
                    ),
                  ),
                  ElevatedButton
                  (
                    onPressed: () 
                    {
                      Navigator.push
                      (
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                      
                    },
                    child: const Text('Accéder à Epicoloc !'),
                  )
                ]
              )
            )
        );
      }
      else
      {
        return SingleChildScrollView
        (
          child: Column
          (
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>
            [
              Container
                  (
                margin: const EdgeInsets.only(top: 40.0, bottom:20.0, left: 20.0, right:20.0),
                child: Image
                (
                  image: AssetImage('assets/images/epicoloc_logo_1.png'),
                ),
              ),
              Container
                  (
                            margin: const EdgeInsets.only(top: 20.0, bottom:20.0, left: 20.0, right:20.0),
                            child: TextFormField
                            (
                              textInputAction: TextInputAction.next,
                              controller: user_nameController,
                              validator: (value) 
                              {
                                if (value == null || value.isEmpty) 
                                {
                                  return 'Aucun nom d\'utilisateur inséré...';
                                }
                                return null;
                              },
                              decoration: InputDecoration
                              (
                                hintText: 'Nom d\'utilisateur'
                              ),
                              //keyboardType: TextInputType.number,
                            ),
                          ),
              Container
                  (
                    margin: const EdgeInsets.only(top: 20.0, bottom:20.0, left: 20.0, right:20.0),
                    child: TextFormField
                    (
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: passwordController,
                      validator: (value) 
                      {
                        if (value == null || value.isEmpty) 
                        {
                          return 'Aucun mot de passe inséré...';
                        }
                        return null;
                      },
                      decoration: InputDecoration
                      (
                        hintText: 'Mot de passe'
                      ),
                    ),
                  ),
              Container
              (
                margin: const EdgeInsets.only(top: 20.0, bottom:60.0, left: 20.0, right:20.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      future_AuthResponse = _postLogin(user_nameController.text, passwordController.text);
                                  });
                  },
                  child: const Text('Connexion'),
                ),
              ),
              Container
              (
                margin: const EdgeInsets.only(top: 20.0, bottom:60.0, left: 20.0, right:20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push
                    (
                      context,
                      MaterialPageRoute(builder: (context) => WebViewExample()),
                    );
                  },
                  child: const Text('Inscription'),
                ),
              )
              
            ],
          )
        );
      }
    }
    else
    {
      return SingleChildScrollView
      (
        child: Center
          (
            child: Column
            (
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[  
                Container
                (
                  margin: EdgeInsets.only(top:20, bottom:40),
                  child: Text
                  (
                    "Connexion Internet requise !",
                    style: TextStyle
                    (
                      fontWeight: FontWeight.normal,
                      fontSize: 30,
                      color: Color(0xFFFF9F0A)
                    ),
                  ),
                ),
                ElevatedButton
                (
                  onPressed: () 
                  {
                    exit(0);
                  },
                  child: const Text('Quitter l\'application'),
                )
              ]
            )
          )
      );
    }
  }
  FutureBuilder<AuthResponse> buildFutureBuilder() {
    return FutureBuilder<AuthResponse>(
      future: future_AuthResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.is_auth_valid == "user_connected") 
        {
          //
          // Sauvegarde le token dans le flutter_secure_storage
          //
          final storage = new FlutterSecureStorage();
          storage.write(key: "token", value: snapshot.data!.token);

          return Center
          (
            child: Column
            (
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[  
                Container
                (
                  margin: EdgeInsets.only(top:20, bottom:40),
                  child: Text
                  (
                    "Connexion établie !",
                    style: TextStyle
                    (
                      fontWeight: FontWeight.normal,
                      fontSize: 30,
                      color: Color(0xFF30D158)
                    ),
                  ),
                ),
                ElevatedButton
                (
                  onPressed: () 
                  {
                    Navigator.push
                    (
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
                    
                  },
                  child: const Text('Accéder à Epicoloc !'),
                )
              ]
            ),
          );
        } 
        else if ( snapshot.hasData && snapshot.data!.is_auth_valid == "user_not_connected")
        {
          return Column
          (
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[  
              Container
              (
                margin: EdgeInsets.only(top:20, bottom:40),
                child: Text
                (
                  "Nom d'utilisateur ou mot de passe incorrect...!",
                  style: TextStyle
                  (
                    fontWeight: FontWeight.normal,
                    fontSize: 30,
                    color: Color(0xFFFF375F)
                  ),
                ),
              ),
              ElevatedButton
              (
                onPressed: () 
                {
                  Navigator.push
                  (
                    context,
                    MaterialPageRoute(builder: (context) => LoginApp()),
                  );
                  
                },
                child: const Text('Réessayer...'),
              )
            ]
          );
        }
        else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const LinearProgressIndicator();
      },
    );
  }
}