// import 'package:epicoloc/main.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:async';
// import 'dart:convert';
// import 'main.dart';
// // ignore: import_of_legacy_library_into_null_safe
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'dart:io';

// //
// // Fonction qui effectue la requête GET get_all_transactions_to_pay
// // Renvoie une liste d'Item
// //
// Future<List<Item>> getTransactions() async {
//   Authentificator token_auth = Authentificator();
//   final response = await http
//       .get(Uri.parse('https://finance.core2duo.fr/api.php?request=get_transactions_to_pay'));
//   if (response.statusCode == 200) {
//     var tmp = jsonDecode(response.body) as List;
//     List<Item> listItems = tmp.map((transJson) => Item.fromJson(transJson)).toList();
//     return listItems;
//   } else {
//     throw Exception('Failed to load Transaction');
//   }
// }

// //
// // Fonction qui effectue une requête POST pour le remboursement d'une personne
// //
// void _payback(String author) {
//   http.post
//   (
//     Uri.parse('https://finance.core2duo.fr/api.php?request=payback'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(<String, String>{
//       'author': author,
//     }),
//   );
// }

// //
// // Classe Item : Permet de récupérer le Nom : Montant à rembourser facilement
// //
// class Item {
//   final String author;
//   final String id;
//   final String amount;

//   Item({
//     required this.author,
//     required this.id,
//     required this.amount,
//   });

//   factory Item.fromJson(Map<String, dynamic> json) {
//     return Item(
//       author: json['author'],
//       id: json['id'].toString(),
//       amount: json['amount'].toString(),

//     );
//   }

//   String toString()
//   {
//     return "Ceci est un test : {${this.author}}";
//   }
// }

// //
// // Affichage de chaque Item
// //
// class ItemView extends StatelessWidget {
  
//   final Item item;

//   ItemView(this.item);
//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton
//     (
//       style: OutlinedButton.styleFrom
//       (
//         side: BorderSide(width: 0, color: Colors.white),
//       ),
//       //
//       // ShowDialog permet d'afficher un message avec une confirmation et un choix
//       //
//       onPressed: () => showDialog<String>
//       (
//       context: context,
//       builder: (BuildContext context) => AlertDialog
//       (
//         title: const Text('Remboursement'),
//         content: Text
//         (
//           'Souhaitez-vous rembourser ${item.author} ?'
//         ),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () => Navigator.pop(context, 'Annuler'),
//             child: const Text('Annuler'),
//           ),
//           TextButton(
//             onPressed: () 
//             {
//               _payback(item.author);
//               //
//               // Affiche une bannière en bas d'écran
//               //
//               ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Remboursement en cours...')));
//               //
//               // Revient sur l'écran précédent
//               //
//               Navigator.pop(context, 'Rembourser');
//             },
//             child: const Text('Rembourser'),
//           ),
//         ],
//       ),
//     ),
//       child:Container
//       (
//         //
//         // Premier Conteneur : Bouton pour une seule personne
//         //
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         margin: EdgeInsets.only(top:10, bottom:10, left:10, right:10),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: 
//           [
//             Expanded
//             (
//               child: Column
//               (
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: 
//                 [
//                   Text
//                   (
//                     '${item.author}',
//                     style: TextStyle
//                     (
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                       color: Color(0xFFFFFFFF)
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: 
//               [
//                 Text
//                 (
//                   '${item.amount}€',
//                   style: TextStyle
//                   (
//                     fontWeight: FontWeight.normal,
//                     fontSize: 20,
//                     color: Color(0xFFBBBBBB)
//                   ),
//                 )
//               ],
//             ),
//           ],
//         ),
//       )
//     );
//   }
// }

// //
// // Classe principale de la route
// //
// // ignore: must_be_immutable
// class Menu extends StatelessWidget {
//   // ignore: non_constant_identifier_names
//   late Future<List<Item>> transaction_to_pay_List = getTransactions();

//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Item>>(
//       future: transaction_to_pay_List,
//       builder: (context, snapshot) 
//       {
//         if (snapshot.hasData) {
//           List<Item> data = snapshot.data as List<Item>;
//           return Scaffold
//           (
//             appBar: AppBar
//             (
//               title: Text
//               (
//                 "Profil",
//                 style: TextStyle
//                 (
//                   fontWeight: FontWeight.normal,
//                   fontSize: 30,
//                 ),
//               ),
//             ),
//             body: Center
//               (
//                 child: Column
//                 (
//                   children: <Widget>
//                   [
//                     Container
//                     (
//                       margin: EdgeInsets.only(top:20, bottom:40),
//                       child: Text
//                       (
//                         "Sommes à rembourser",
//                         style: TextStyle
//                         (
//                           fontWeight: FontWeight.normal,
//                           fontSize: 30,
//                           color: Color(0xFF568ca8)
//                         ),
//                       ),
//                     ),
//                     Expanded
//                     (
//                       //
//                       // Important !
//                       // Initialement impossible de mettre une Liste de Widgets en Children
//                       // C'est finalement possible en la mettant en child dans un Expanded()
//                       // TRES UTILE !
//                       child: _buildListView(data),
//                     ),
//                     Container
//                     (
//                       child: ElevatedButton
//                         (
//                           style: ElevatedButton.styleFrom(
//                             primary: Color(0xFF2C2C2E),
//                             onPrimary: Colors.white,
//                           ),
//                           onPressed: () 
//                           {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Déconnexion en cours... L\'application va quitter !')));
//                             final storage = new FlutterSecureStorage();
//                             storage.delete(key: "token");
//                             exit(0);
//                           },
//                           child: const Text('Déconnexion'),
//                         ),
//                     )
//                   ],
//                 )
//               ),
//           );              
          
//         } else if (snapshot.hasError) {
//           return Text("${snapshot.error}");
//         }
//         return LinearProgressIndicator();
//       }
//     );
//   }

// //
// // Construit la liste de Widgets
// //
//   Widget _buildListView(List<Item> item) {
//   return ListView.builder(
//     itemBuilder: (ctx, idx) {
//       return ItemView(item[idx]);
//     },
//     itemCount: item.length,
//   );
// }
// }

// MaterialColor createMaterialColor(Color color) {
//   List strengths = <double>[.05];
//   final swatch = <int, Color>{};
//   final int r = color.red, g = color.green, b = color.blue;

//   for (int i = 1; i < 10; i++) {
//     strengths.add(0.1 * i);
//   }
//   strengths.forEach((strength) {
//     final double ds = 0.5 - strength;
//     swatch[(strength * 1000).round()] = Color.fromRGBO(
//       r + ((ds < 0 ? r : (255 - r)) * ds).round(),
//       g + ((ds < 0 ? g : (255 - g)) * ds).round(),
//       b + ((ds < 0 ? b : (255 - b)) * ds).round(),
//       1,
//     );
//   });
//   return MaterialColor(color.value, swatch);
// }

