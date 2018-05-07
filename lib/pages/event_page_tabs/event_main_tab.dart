import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';


class EventMainTabPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new EventMainTabPageState();

  String _eventId;
  EventMainTabPage(this._eventId);
  String _address;

}

class EventMainTabPageState extends State<EventMainTabPage> with SingleTickerProviderStateMixin {
  bool fullScreenQR = false;
  DocumentSnapshot eventDocumentSnapshot;
  bool _qrReady = false;
  String _qrEntryCode = "null";



  @override
  void initState() {
    super.initState();
    getEventData(widget._eventId);
    getEntryCode();
  }


  ///Queries OpenStreetMap using the latitude and longitude given in the [location].
  ///The resulting address is then displayed using setState.
  void setAddress(GeoPoint location) async {
    String query =  "https://nominatim.openstreetmap.org/reverse?format=json&lat="+ location.latitude.toString() + "&lon=" + location.longitude.toString();

    var response = await http.get(
        Uri.encodeFull(query),
    );

    this.setState(() => widget._address = JSON.decode(response.body)["display_name"]);
  }

  ///Gets the document snapshot of the event with [eventID] and updates the address appropriately
  void getEventData (String eventID) async {
    Firestore.instance.collection("events").document(eventID).snapshots.listen((DocumentSnapshot eventSnapshot) {
      this.setState(() => eventDocumentSnapshot = eventSnapshot);
      setAddress(eventSnapshot.data["location"]);
    });
  }

  ///Gets the unique ticketing entry code of the current user
  void getEntryCode () async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance.document("events/" + widget._eventId + "/attendees/" + user.uid).snapshots.listen((DocumentSnapshot attendeeSnapshot) {
      this.setState(() {
        _qrEntryCode = attendeeSnapshot.data["EntryCode"];
        _qrReady = true;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return eventDocumentSnapshot == null ? new Text("Loading...")
    : new Stack(
      children: <Widget>[
        new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Image.network(
              'https://raw.githubusercontent.com/flutter/website/master/_includes/code/layout/lakes/images/lake.jpg',
            ),
            new Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 12.0),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  //Column with the event title and address
                  new Expanded(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(eventDocumentSnapshot.data["name"], style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),),
                        widget._address == null ? new Text("Loading address...")
                        : new Text(widget._address)
                      ],
                    ),
                  ),

                  //Entry QR Code
                  fullScreenQR ? new Container() : new InkWell(
                    onTap: () {
                      this.setState(() => fullScreenQR = !fullScreenQR);
                    },
                    child: _qrReady ? new QrImage(
                      data: _qrEntryCode,
                      version: 5, foregroundColor: Colors.green[900],
                      size: MediaQuery.of(context).size.width/2.5,
                    ) :
                    new Text("Loading entry QR code..."),
                  ),
                ],
              ),
            ),
            new Padding(
              padding: const EdgeInsets.all(10.0),
              child: new Text(eventDocumentSnapshot.data["description"], textAlign: TextAlign.justify,),
            ),
          ],
        ),

        // If set to display a full screen QR Code, the QR code goes full screen
        fullScreenQR ? new InkWell(
          splashColor: Colors.greenAccent,
          onTap: () => this.setState(() => fullScreenQR = !fullScreenQR),
          child: new Container(
            color: Colors.white.withOpacity(1.0),
            alignment: Alignment.center,
            child: new QrImage(
              data: _qrEntryCode,
              version: 5, foregroundColor: Colors.black,
              size: MediaQuery.of(context).size.width,
              padding: new EdgeInsets.all(30.0),
            ),
          ),
        ) : new Container(),
      ],
    );
  }

}
