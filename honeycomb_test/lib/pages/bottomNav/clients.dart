import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/clients_ui.dart';

class ClientsPage extends StatefulWidget {
  @override
  ClientsPageState createState() => ClientsPageState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;

  ClientsPage();
}

class ClientsPageState extends State<ClientsPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget userBuilder() {
    return FutureBuilder(
      future: widget.proxyModel.getUser(widget.userID),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          MPUser user = snapshot.data!;
          return clientsBuilder(snapshot.data);
        } else {
          return const Center(
            child: Text("No user found"),
          );
        }
      },
    );
  }

  Widget clientsBuilder(MPUser user) {
    return FutureBuilder(
      future: widget.proxyModel.listUserClients(user),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          Iterable clients = snapshot.data!;
          if (clients.isEmpty) {
            return (const Center(
              child: Text("No Clients Found"),
            ));
          }
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            shrinkWrap: true,
            itemCount: clients.length,
            itemBuilder: (BuildContext context, int index) {
              return clientCard(context, clients.elementAt(index));
            },
          );
        } else {
          return const Center(
            child: Text("Error"),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        title: const Text(
          "My Clients",
        ),
        backgroundColor: const Color(0xFF2B2A2A),
        foregroundColor: Colors.white,
      ),
      body: userBuilder(),
      bottomNavigationBar: customNav(context, 4),
    );
  }
}
