import 'package:flutter/material.dart';
import '../utils/ticket_status_enum.dart';
import '../utils/colours.dart';

class ScannedTicketCard extends StatelessWidget {
  final Map<String, dynamic> ticketScan;

  ScannedTicketCard(this.ticketScan);

  final Map<TicketStatus, String> errorCardTitles = <TicketStatus, String> {
    TicketStatus.DifferentEvent: "Different Event",
    TicketStatus.UnknownUser: "Unkown Guest",
    TicketStatus.UnableToAccessCamera: "Unable to Access Camera",
    TicketStatus.ExitedScan: "Exited Scan",
    TicketStatus.ScanFailed: "Unknown Scan Error"
  };

  final Map<TicketStatus, String> errorCardDescriptions = <TicketStatus, String> {
    TicketStatus.AlreadyScanned: "This guest has already entered",
    TicketStatus.DifferentEvent: "This ticket is for a different event",
    TicketStatus.UnknownUser: "The scanned ticket does not belong to a guest going to this event",
    TicketStatus.InvalidEntryCode: "The scanned ticket belongs to a guest going to this event, but the security information was not valid",
    TicketStatus.UnableToAccessCamera: "Ensure that the camera permissions have been enabled",
    TicketStatus.ExitedScan: "The scan was exited before a ticket was shown",
    TicketStatus.ScanFailed: ""
  };

  @override
  Widget build(BuildContext context) {
    String cardTitle;
    String cardDescription;
    bool ticketVerified = false;
    bool scanError = false;

    if (ticketScan["TicketStatus"] == TicketStatus.Verified) {
      cardTitle = ticketScan["Name"];
      cardDescription = "Entry verified";
      ticketVerified = true;
    } else if (ticketScan["TicketStatus"] == TicketStatus.AlreadyScanned || ticketScan["TicketStatus"] == TicketStatus.InvalidEntryCode) {
      cardTitle = ticketScan["Name"];
      cardDescription = errorCardDescriptions[ticketScan["TicketStatus"]];
    } else {
      cardTitle = errorCardTitles[ticketScan["TicketStatus"]];
      cardDescription = errorCardDescriptions[ticketScan["TicketStatus"]];
    }

    if(ticketScan["TicketStatus"] == TicketStatus.UnableToAccessCamera || ticketScan["TicketStatus"] == TicketStatus.ExitedScan || ticketScan["TicketStatus"] == TicketStatus.ScanFailed) {
      scanError = true;
    }


    return new Card(
      child: new ListTile(
        leading: ticketVerified
            ? const Icon(Icons.check, color: Colors.greenAccent,) : const Icon(Icons.clear, color: Colors.white),
        title: new Text(cardTitle),
        subtitle: new Text(cardDescription),
      ),
      color: ticketVerified ? Colors.white
          : scanError ? AppColours.warning
          : AppColours.error,
    );
  }

}