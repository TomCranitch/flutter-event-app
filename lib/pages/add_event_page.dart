import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/calendar_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEventPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AddEventPageState(); 
}

class AddEventPageState extends State<AddEventPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String _eventName;
  String _description;
  num _latitude;
  num _longitude;
  final TextEditingController _startTimeController = new TextEditingController();
  final TextEditingController _endTimeController = new TextEditingController();

  ///Submits the form
  ///
  /// The form fields are first validated, and then the event is added to the
  /// database. The current user is then added to the Administrator collection
  /// of the event with all privileges enabled.
  void submitForm () async {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      // TODO: show message
    } else {
      form.save();
      DocumentReference event = await Firestore.instance.collection("events").add(
          {
            "name": _eventName,
            "description": _description,
            "location": new GeoPoint(_latitude, _longitude),
            "start-time": CalendarPickerState.stringToDate(_startTimeController.text),
            "end-time": CalendarPickerState.stringToDate(_endTimeController.text)
          }
      );

      FirebaseUser user = await FirebaseAuth.instance.currentUser();

      Firestore.instance.document("events/" + event.documentID + "/administrators/" + user.uid).setData(
          {
            "can-scan": true,
            "can-edit-event": true,
            "can-add-attendees": true
          }
      );

      Navigator.of(context).pop();
    }

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Add Event"),),
      body: new SingleChildScrollView(
        child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Form(
            //autovalidate: true,
            key: _formKey,
            child: new Column(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: new TextFormField(
                    decoration: new InputDecoration(
                        labelText: "Event Name",
                      border: new OutlineInputBorder(),
                    ),
                    validator: (val) => val.length < 5 ? "Event name is too short" : null,
                    onSaved: (val) => _eventName = val,
                  ),
                ),
                new TextFormField(
                  decoration: new InputDecoration(
                      labelText: "Description",
                      border: new OutlineInputBorder(),
                  ),
                  validator: (val) => val.isEmpty ? "Event description should not be empty" : null,
                  maxLines: 6,
                  onSaved: (val) => _description = val,
                ),
                new CalendarPicker(_startTimeController),
                new CalendarPicker(_endTimeController),
                new Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: new TextFormField(
                    decoration: new InputDecoration(
                      labelText: "Lattitude",
                      //icon: new Icon(Icons.map),
                      border: new OutlineInputBorder(),
                    ),
                    validator: (val) => double.parse(val, (e) => null) == null ? "Invalid longitude. Should be number." : null,
                    onSaved: (val) => _latitude = double.parse(val, (e) => null),
                  ),
                ),
                new TextFormField(
                  decoration: new InputDecoration(
                    labelText: "Longitude",
                    //icon: new Icon(Icons.map),
                    border: new OutlineInputBorder(),
                  ),
                  validator: (val) => double.parse(val, (e) => null) == null ? "Invalid longitude. Should be number." : null,
                  onSaved: (val) => _longitude = double.parse(val, (e) => null),
                ),
                new MaterialButton(
                  onPressed: () => submitForm(),
                  child: new Text("Submit"),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}