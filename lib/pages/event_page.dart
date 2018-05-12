import 'package:flutter/material.dart';
import 'package:flutter_event_app/pages/event_page_tabs/event_main_tab.dart';
import 'package:flutter_event_app/pages/event_page_tabs/event_guests_tab.dart';
import 'event_page_tabs/event_music_tab.dart';
import 'scan_barcode_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import '../utils/colours.dart';
import 'edit_event_page.dart';

class EventPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new EventPageState();

  String _eventID;
  bool _canScan= false;
  bool _canEdit = false;
  bool _showFAB = false;

  EventPage(this._eventID);

  void fabOnPress(BuildContext context) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new ScanBarcodePage(_eventID)));
  }


}

class EventPageState extends State<EventPage> with SingleTickerProviderStateMixin {
  TabController controller;
  FabMiniMenuItem editFABItem;
  FabMiniMenuItem scanFABItem;

  List<FabMiniMenuItem> fabItems = [];

  void _scanTickets () {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new ScanBarcodePage(widget._eventID)));
  }

  void _editEvent () {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new EventEditPage(widget._eventID)));
  }

  @override
  void initState() {
    super.initState();

    scanFABItem = new FabMiniMenuItem.noText(
        new Icon(Icons.camera_alt),
        AppColours.primaryCharcoalDark,
        4.0,
        "Scan Ticket",
        _scanTickets
    );

    editFABItem = new FabMiniMenuItem.noText(
        new Icon(Icons.edit),
        AppColours.primaryCharcoalDark,
        4.0,
        "Edit Event",
        _editEvent
    );


    controller = new TabController(length: 3, vsync: this);
    adminPrivileges();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  ///Queries the Firestore to see if the current user can can tickets.
  ///Displays the scan ticket button if appropriate
  void adminPrivileges() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance.document("events/" + widget._eventID + "/administrators/" + user.uid).snapshots.listen((DocumentSnapshot administratorsSnapshot) {
      if(administratorsSnapshot.exists){
        this.setState((){
          widget._canScan = administratorsSnapshot.data["can-scan"];
          widget._canEdit = administratorsSnapshot.data["can-edit-event"];

          // TODO: fails if _canEdit or _canScan are null
          if(widget._canEdit || widget._canScan) {
            widget._showFAB = true;
          } else {
            widget._showFAB = false;
          }

          fabItems = [];

          if(widget._canEdit) fabItems.add(editFABItem);
          if(widget._canScan) fabItems.add(scanFABItem);


        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Scaffold(
        // TODO: Currently using a package but its not great. Look at custom implementation
        floatingActionButton: widget._showFAB ? new FabDialer(fabItems, AppColours.secondaryCyan, new Icon(Icons.add))
        : new Container(),
        body: new TabBarView(
            controller: controller,
            children: <Widget>[
              new EventMainTabPage(widget._eventID),
              new EventGuestPage(widget._eventID),
              new EventMusicPage(widget._eventID)
            ],
        ),
        bottomNavigationBar: new Material(
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