// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'main.dart';

// Future<AuthResponse> _postLogin(String user_name, String password) async{
//   final response =  await http.post
//   (
//     Uri.parse('https://finance.core2duo.fr/api.php?request=post_auth'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(<String, String>{
//       'user_name': user_name,
//       'password': password,
//     }),
//   );
//   if (response.statusCode == 200) {
//     print(response.body.toString());
//     return AuthResponse.fromJson(jsonDecode(response.body));
//   } else {
//     throw Exception('Failed to log in. Please try again...!');
//   }
  
// }

// class AuthResponse {
//   final String token;
//   final String id;
//   final String is_auth_valid;
  
//   AuthResponse({
//     required this.token,
//     required this.id,
//     required this.is_auth_valid,
//   });

//   factory AuthResponse.fromJson(Map<String, dynamic> json) {
//     return AuthResponse(
//       token: json['token'],
//       id: json['id'],
//       is_auth_valid: json['is_auth_valid'],
//     );
//   }
// }


// void main() {
//   runApp(LoginApp());
// }

// // class LoginApp extends StatefulWidget {
// //   const LoginApp({Key? key}) : super(key: key);

// //   @override
// //   Login createState() {
// //     return Login();
// //   }
// // }
// class LoginApp extends StatefulWidget {
//   //const LoginApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp
//     (
//       title: 'EpiColoc',
//       theme: ThemeData
//       (
//         //
//         // Thême global de l'application
//         //
//         primarySwatch: createMaterialColor(Color(0xFF42ecf5)),
//         //scaffoldBackgroundColor: const Color(0xFFEEEEEE),
//         brightness: Brightness.dark,
//         textTheme: TextTheme
//         (
//           bodyText1: TextStyle(),
//           bodyText2: TextStyle(),
//         ).apply
//         (
//           bodyColor: Color(0xFFffffff), 
//           displayColor: Color(0xFFFFFFFF), 
//         ),
//       ),
//       home: LoginPage(title: 'EPICOLOC'),
//       debugShowCheckedModeBanner: false,

//     );
//   }

//   @override
//   Login createState() {
//     return Login();
//   }
// }

// class LoginPage extends StatefulWidget {
//   LoginPage({Key? key, required this.title}) : super(key: key);
//   final String title;
//   @override
//   Login createState() => Login();
// }


// class Login extends State<LoginApp> 
// {
//   TextEditingController passwordController = new TextEditingController();
//   TextEditingController user_nameController = new TextEditingController();
//   Future<AuthResponse>? future_AuthResponse;

//   @override
//   Widget build(BuildContext context) 
//   {
//     final _formKey = GlobalKey<FormState>();
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Connexion à EpiColoc"),
//       ),
//       body: 
//         Container(
//           alignment: Alignment.center,
//           padding: const EdgeInsets.all(8.0),
//           child: (future_AuthResponse == null) ? buildColumn() : buildFutureBuilder(),
//         ),
//     );
//   }
  
//   Column buildColumn() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Container
//                     (
//                       margin: const EdgeInsets.only(top: 20.0, bottom:20.0, left: 20.0, right:20.0),
//                       child: TextFormField
//                       (
//                         controller: user_nameController,
//                         validator: (value) 
//                         {
//                           if (value == null || value.isEmpty) 
//                           {
//                             return 'Aucun nom d\'utilisateur inséré...';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration
//                         (
//                           hintText: 'Nom d\'utilisateur'
//                         ),
//                         keyboardType: TextInputType.number,
//                       ),
//                     ),
//         Container
//             (
//               margin: const EdgeInsets.only(top: 20.0, bottom:20.0, left: 20.0, right:20.0),
//               child: TextFormField
//               (
//                 controller: passwordController,
//                 validator: (value) 
//                 {
//                   if (value == null || value.isEmpty) 
//                   {
//                     return 'Aucun mot de passe inséré...';
//                   }
//                   return null;
//                 },
//                 decoration: InputDecoration
//                 (
//                   hintText: 'Mot de passe'
//                 ),
//               ),
//             ),
//         ElevatedButton(
//           onPressed: () {
//             setState(() {
//               future_AuthResponse = _postLogin(user_nameController.text, passwordController.text);
//                           });
//           },
//           child: const Text('Connexion'),
//         ),
//       ],
//     );
//   }
  
//   //
//   // Change l'affichage de l'écran lors de la réponse du serveur
//   // Retourne un "body" avec le contenu de ce qui est affiché à l'écran
//   //
//   FutureBuilder<AuthResponse> buildFutureBuilder() {
//     return FutureBuilder<AuthResponse>(
//       future: future_AuthResponse,
//       builder: (context, snapshot) {
//         if (snapshot.hasData && snapshot.data!.is_auth_valid == "user_connected") 
//         {
//           return Column
//           (
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[  
//               Container
//               (
//                 margin: EdgeInsets.only(top:20, bottom:40),
//                 child: Text
//                 (
//                   "Connexion établie !",
//                   style: TextStyle
//                   (
//                     fontWeight: FontWeight.normal,
//                     fontSize: 30,
//                     color: Color(0xFF568ca8)
//                   ),
//                 ),
//               ),
//               ElevatedButton
//               (
//                 onPressed: () 
//                 {
//                   Navigator.push
//                   (
//                     context,
//                     MaterialPageRoute(builder: (context) => LoginApp()),
//                   );
                  
//                 },
//                 child: const Text('Accéder à Epicoloc !'),
//               )
//             ]
//           );
//         } 
//         else if ( snapshot.hasData && snapshot.data!.is_auth_valid == "user_not_connected")
//         {
//           return Column
//           (
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[  
//               Container
//               (
//                 margin: EdgeInsets.only(top:20, bottom:40),
//                 child: Text
//                 (
//                   "Nom d'utilisateur ou mot de passe incorrect...!",
//                   style: TextStyle
//                   (
//                     fontWeight: FontWeight.normal,
//                     fontSize: 30,
//                     color: Color(0xFF568ca8)
//                   ),
//                 ),
//               ),
//               ElevatedButton
//               (
//                 onPressed: () 
//                 {
//                   Navigator.push
//                   (
//                     context,
//                     MaterialPageRoute(builder: (context) => LoginApp()),
//                   );
                  
//                 },
//                 child: const Text('Réessayer...'),
//               )
//             ]
//           );
//         }
//         else if (snapshot.hasError) {
//           return Text('${snapshot.error}');
//         }

//         return const LinearProgressIndicator();
//       },
//     );
//   }
// }
