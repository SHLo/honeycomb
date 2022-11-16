import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/pages/bottomNav/main_list.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:honeycomb_test/pages/resource_details.dart';
import 'package:honeycomb_test/proxy.dart';
import 'package:honeycomb_test/ui_components/resource_ui.dart';
import 'package:honeycomb_test/utilities.dart';

class FavsPage extends StatefulWidget {
  @override
  FavsPageState createState() => FavsPageState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;

  FavsPage();
}

class FavsPageState extends State<FavsPage> {
  @override
  void initState() {
    resetFilters();
    super.initState();
  }

  Widget userBuilder() {
    return FutureBuilder(
      future: widget.proxyModel.getUser(widget.userID),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return favoritesBuilder(snapshot.data);
        } else {
          return const Center(
            child: Text("No user found"),
          );
        }
      },
    );
  }

  Widget favoritesBuilder(MPUser user) {
    return FutureBuilder(
      future: widget.proxyModel.listUserFavorites(user),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          Iterable favs = snapshot.data!;
          if (favs.isEmpty) {
            return (Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  "No Favorites",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Text('Tap the "Add +" button to make one')
              ]),
            ));
          }
          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(Duration(seconds: 1));
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: favs.length,
              itemBuilder: (BuildContext context, int index) {
                return resourceCard(context, favs.elementAt(index), () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ResourceDetails(
                                resource: favs.elementAt(index),
                              )));
                  setState(() {});
                });
              },
            ),
          );
        } else {
          return const Center(
            child: Text("Error"),
          );
        }
      },
    );
  }

  Widget addButton() {
    return ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ResourcesPage()));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Add"),
            getSpacer(8),
            const Icon(Icons.add_circle),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        title: const Text(
          "My Favorites",
        ),
        backgroundColor: const Color(0xFF2B2A2A),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: addButton(),
          ),
        ],
      ),
      body: userBuilder(),
      bottomNavigationBar: customNav(context, 3),
    );
  }
}
