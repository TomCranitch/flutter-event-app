import 'package:flutter/material.dart';
import '../widgets/event_list_card.dart';
import 'event_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'scan_barcode_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomePageState();

  /*void onBarcodeCardTap (BuildContext context) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new ScanBarcodePage()));
  }*/
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.deepPurpleAccent,
      child: new StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('events')
            .orderBy("time")
            .snapshots,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return new Text("Loading...");
          return new ListView(
            children: snapshot.data.documents.map((DocumentSnapshot document) {
              return new EventCard(document['name'], document['description'], document.documentID);
            }).toList(),
          );
        },
      ),
    );
  }
}

