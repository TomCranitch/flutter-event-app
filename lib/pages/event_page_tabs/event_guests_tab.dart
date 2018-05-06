import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/event_guest_list_card.dart';


class EventGuestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new EventGuestPageState();

  final String _eventID;
  EventGuestPage(this._eventID);

  //final List<User> attendees = [new User("Tom", "Cranitch"), new User("User", "Two")];
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
              stream: Firestore.instance
                  .collection('events').document(widget._eventID)
                  .getCollection('attendees')
                  .snapshots,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Text("Loading...");
                //return new Text("hello");
                return new ListView(
                  children: snapshot.data.documents.map((DocumentSnapshot document) {
                    return new EventGuestListCard(document.documentID, document.data["Going"]);
                    //new Text(document.documentID);
                  }).toList(),
                );
              },
            ),

            /*new ListView.builder(
              itemCount: widget.attendees.length,
              itemBuilder: (BuildContext context, int index) {
                return new Card(
                  child: new ListTile(
                    leading: const Icon(Icons.check, color: Colors.greenAccent,),
                    title: new Text(widget.attendees[index].firstName),
                    subtitle: new Text(widget.attendees[index].lastName),
                  ),
                );
              },
            )*/
          )
        ]
      )
    );
  }
}