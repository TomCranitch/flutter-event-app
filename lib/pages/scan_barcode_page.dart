import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/ticket_status_enum.dart';

class ScanBarcodePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new ScanBarcodePageState();

  String _eventId;
  ScanBarcodePage(this._eventId);

}

class ScanBarcodePageState extends State<ScanBarcodePage>{

  List<List> scannedTickets = []; //[Name, Status, Pass]

  void checkTicket (String qrContent) async {
    List<String> qrContentArray = qrContent.split(",");
    if(qrContentArray[0] != widget._eventId) {
      this.setState(() {
        scannedTickets.add(["Ticket Lookup Failed", "This ticket is for a different event", TicketStatus.Unverified]);

      });
      // ignore: return_without_value
      return;
    }
    Firestore.instance.document("events/" + qrContentArray[0] + "/attendees/" + qrContentArray[1]).get().then((DocumentSnapshot attendeeSnapshot) {
      Firestore.instance.document("users/" + qrContentArray[1]).get().then((DocumentSnapshot userSnapshot) {
        String name = userSnapshot.data["FirstName"] + " " + userSnapshot.data["LastName"];
        this.setState(() {
          if(qrContentArray[2] == attendeeSnapshot.data["EntryCode"] && attendeeSnapshot.data["Entered"] == false){
            scannedTickets.add([name, "Ticket Verified", TicketStatus.Verified]);
            Firestore.instance.document("events/" + qrContentArray[0] + "/attendees/" + qrContentArray[1]).updateData({"Entered": true});
            // TODO: set Entered to true
          } else if(qrContentArray[2] == attendeeSnapshot.data["EntryCode"] && attendeeSnapshot.data["Entered"] == true){
            scannedTickets.add([name, "Ticket Verification Failed: Guest has already entered", TicketStatus.Unverified]);
          } else {
            scannedTickets.add([name, "Ticket Verification Failed: Invalid Ticket", TicketStatus.Unverified]);
          }
        });
      }).catchError((Error error) {
        this.setState(() {
          scannedTickets.add(["Ticket Lookup Failed", "The user doesn't exist or cannot attend this event", TicketStatus.Unverified]);

        });
        print(error);
      });
    });

  }

  Widget build(BuildContext context) {
    return new Material(
      child: new Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 15.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new MaterialButton(
              onPressed: scan,
              child: new Text("Scan Ticket", style: new TextStyle(fontSize: 30.0),),
              padding: const EdgeInsets.all(9.0),
            ),
            new Expanded(
              child: new ListView.builder(
                itemCount: scannedTickets.length,
                itemBuilder: (BuildContext context, int index) {
                  index = scannedTickets.length - index -  1;
                  return new Card(
                    child: new ListTile(
                      leading: scannedTickets[index][2] == TicketStatus.Verified
                          ? const Icon(Icons.check, color: Colors.greenAccent,) : const Icon(Icons.clear, color: Colors.white),
                      title: new Text(scannedTickets[index][0]),
                      subtitle: new Text(scannedTickets[index][1]),
                    ),
                    color: scannedTickets[index][2] == TicketStatus.Verified ? Colors.white : scannedTickets[index][2] == TicketStatus.ScanFailed ? Colors.orangeAccent : Colors.redAccent,
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      checkTicket(barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.scannedTickets.add(['Scan Failed', 'Unable to access the camera.', TicketStatus.ScanFailed]);
        });
      } else {
        setState(() => this.scannedTickets.add(['Scan Failed', 'Unknown error: $e', TicketStatus.ScanFailed]));
      }
    } on FormatException{
      setState(() => this.scannedTickets.add(['Scan Failed', 'Exited scanning before scanning a ticket', TicketStatus.ScanFailed]));
    } catch (e) {
      setState(() => this.scannedTickets.add(['Scan Failed', 'Unknown error: $e', TicketStatus.ScanFailed]));
    }
  }

}