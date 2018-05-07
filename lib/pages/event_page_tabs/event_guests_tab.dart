import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/event_guest_list_card.dart';


class EventGuestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new EventGuestPageState();

  final String _eventID;
  EventGuestPage(this._eventID);
}

class EventGuestPageState extends State<EventGuestPage> {

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 15.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Expanded(
            child: new StreamBuilder<QuerySnapshot>(

              // Gets all attendees in the current event
              stream: Firestore.instance
                  .collection('events').document(widget._eventID)
                  .getCollection('attendees')
                  .snapshots,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Text("Loading...");
                return new ListView(
                  children: snapshot.data.documents.map((DocumentSnapshot document) {
                    return new EventGuestListCard(document.documentID, document.data["Going"]);
                  }).toList(),
                );
              },
            ),
          )
        ]
      )
    );
  }

}