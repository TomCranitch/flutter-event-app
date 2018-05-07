import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventGuestListCard extends StatefulWidget {
  State<StatefulWidget> createState() => new EventGuestListCardState();

  String _guestUserID;
  bool _going;
  EventGuestListCard(this._guestUserID, this._going);

}

class EventGuestListCardState extends State<EventGuestListCard> {
  String _fName;
  String _lName;

  @override
  void initState() {
    super.initState();
    getGuestUserData();
  }

  ///Gets a list of guests from the database
  void getGuestUserData() {
    Firestore.instance.collection('users').document(widget._guestUserID).get()
        .then((DocumentSnapshot userDocument) {
          this.setState(() {
            _fName = userDocument['FirstName'];
            _lName = userDocument['LastName'];
          });
    });
  }


  @override
  Widget build(BuildContext context) {
    return _fName == null || _lName == null ?
    new Card(
      child: new ListTile(
        leading: const CircularProgressIndicator(),
        title: new Text("Loading Data..."),
      ),
    ) :
    new Card(
      child: new ListTile(
        leading: widget._going ? const Icon(Icons.check, color: Colors.greenAccent,) : const Icon(Icons.clear, color: Colors.redAccent,),
        title: new Text(_fName),
        subtitle: new Text(_lName),
      ),
    );
  }
}