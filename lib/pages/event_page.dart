//TODO: Hero animation

import 'package:flutter/material.dart';
import 'package:flutter_event_app/pages/event_page_tabs/event_main_tab.dart';
import 'package:flutter_event_app/pages/event_page_tabs/event_guests_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_page_tabs/event_music_tab.dart';
import 'scan_barcode_page.dart';

class EventPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new EventPageState();

  String _eventID;

  EventPage(this._eventID);

  void fabOnPress(BuildContext context) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new ScanBarcodePage(_eventID)));
    //Firestore.instance.collection("users").document()
     //   .setData({"first-name": "Generate", "last-name": "User", "is-male": true});
  }


}

class EventPageState extends State<EventPage> with SingleTickerProviderStateMixin {

  TabController controller;


  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 3, vsync: this);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Scaffold(
        floatingActionButton: new FloatingActionButton(
          onPressed: () => widget.fabOnPress(context),
          child: new Icon(Icons.add),
          backgroundColor: Colors.cyanAccent,
        ),
        body: new TabBarView(
            controller: controller,
            children: <Widget>[
              new EventMainTabPage(widget._eventID),
              new EventGuestPage(widget._eventID),
              new EventMusicPage(widget._eventID)
            ],
        ),
        bottomNavigationBar: new Material(
          color: Colors.greenAccent,
          child: new TabBar(
            controller: controller,
            tabs: <Tab>[
              new Tab(icon: new Icon(Icons.home),),
              new Tab(icon: new Icon(Icons.people),),
              new Tab(icon: new Icon(Icons.queue_music),)
            ]
          ),
        ),
      ),
    );
  }
}