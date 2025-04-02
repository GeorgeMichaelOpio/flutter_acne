// // screens/home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../auth_provider.dart';

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.user;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () async {
//               await authProvider.signOut();
//               Navigator.pushReplacementNamed(context, '/login');
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Welcome!',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 24),
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'User Details',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Divider(),
//                       ListTile(
//                         leading: user?.photoURL != null
//                             ? CircleAvatar(
//                                 backgroundImage: NetworkImage(user!.photoURL!),
//                               )
//                             : Icon(Icons.person),
//                         title: Text('Name'),
//                         subtitle: Text(user?.displayName ?? 'Not available'),
//                       ),
//                       ListTile(
//                         leading: Icon(Icons.email),
//                         title: Text('Email'),
//                         subtitle: Text(user?.email ?? 'Not available'),
//                       ),
//                       ListTile(
//                         leading: Icon(Icons.verified_user),
//                         title: Text('User ID'),
//                         subtitle: Text(user?.uid ?? 'Not available'),
//                       ),
//                       ListTile(
//                         leading: Icon(Icons.login),
//                         title: Text('Provider'),
//                         subtitle: Text(
//                           user?.providerData.isNotEmpty == true
//                               ? user!.providerData[0].providerId
//                               : 'Not available',
//                         ),
//                       ),
//                       ListTile(
//                         leading: Icon(Icons.access_time),
//                         title: Text('Account Created'),
//                         subtitle: Text(
//                           user?.metadata.creationTime?.toString() ??
//                               'Not available',
//                         ),
//                       ),
//                       ListTile(
//                         leading: Icon(Icons.verified),
//                         title: Text('Email Verified'),
//                         subtitle: Text(
//                           user?.emailVerified == true ? 'Yes' : 'No',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
