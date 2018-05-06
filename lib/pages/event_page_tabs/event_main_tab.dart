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

  bool _qrReady = false;
  String _qrEntryCode = "null";

  final String description = "Very Very Brief"; //"Lorem ipsum dolor amet butcher snackwave hexagon pabst wayfarers taxidermy flexitarian man bun. Mixtape post-ironic raclette, art party cliche fingerstache DIY mustache vaporware thundercats air plant chicharrones celiac hammock photo booth. Etsy disrupt you probably haven't heard of them mumblecore sriracha jianbing. Godard keytar lomo chartreuse deep v drinking vinegar actually la croix marfa wolf subway tile. Chia live-edge cold-pressed, kombucha offal godard disrupt VHS ethical cornhole tumblr post-ironic irony.";

}

class EventMainTabPageState extends State<EventMainTabPage> with SingleTickerProviderStateMixin {
  bool fullScreenQR = false;
  DocumentSnapshot eventDocumentSnapshot;


  @override
  void initState() {
    super.initState();
    getEventData(widget._eventId);
    getEntryCode();
  }

  void setAddress(GeoPoint location) async {
    String query =  "https://nominatim.openstreetmap.org/reverse?format=json&lat="+ location.latitude.toString() + "&lon=" + location.longitude.toString();

    var response = await http.get(
        Uri.encodeFull(query),
    );

    this.setState(() => widget._address = JSON.decode(response.body)["display_name"]);
  }

  void getEventData (String eventID) async {
    Firestore.instance.collection("events").document(eventID).snapshots.listen((DocumentSnapshot eventSnapshot) {
      this.setState(() => eventDocumentSnapshot = eventSnapshot);
      setAddress(eventSnapshot.data["location"]);
    });
  }

  void getEntryCode () async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print(user.uid);
    Firestore.instance.document("events/" + widget._eventId + "/attendees/" + user.uid).snapshots.listen((DocumentSnapshot attendeeSnapshot) {
      this.setState(() {
        widget._qrEntryCode = attendeeSnapshot.data["EntryCode"];
        widget._qrReady = true;
        print(widget._qrEntryCode);
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
                  fullScreenQR ? new Container() : new InkWell(
                    onTap: () {
                      this.setState(() => fullScreenQR = !fullScreenQR);
                    },
                    child: widget._qrReady ? new QrImage(
                      data: widget._qrEntryCode,
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
              child: new Text(widget.description, textAlign: TextAlign.justify,),
            ),
          ],
        ),
        fullScreenQR ? new InkWell(
          splashColor: Colors.greenAccent,
          onTap: () => this.setState(() => fullScreenQR = !fullScreenQR),
          child: new Container(
            color: Colors.white.withOpacity(1.0),
            alignment: Alignment.center,
            child: new QrImage(
              data: widget._qrEntryCode,
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
