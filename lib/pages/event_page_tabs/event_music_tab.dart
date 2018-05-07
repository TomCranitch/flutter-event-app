import 'package:flutter/material.dart';
import '../../widgets/event_music_list_card.dart';
import 'event_music_search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventMusicPage extends StatefulWidget {
  final String _eventID;
  EventMusicPage(this._eventID);

  @override
  State createState() => new EventMusicPageState();
}

class EventMusicPageState extends State<EventMusicPage>{
  Color background = Colors.white; // TODO: very, very hacky. only for brief testing

  void onSubmit(BuildContext context, String content) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new EventMusicSearchPage(content, widget._eventID)));
  }

  ///Adds the song with [musicID] to the playlist when tapped
  void onMusicTap(String musicID) {
    background = Colors.greenAccent;
    Firestore.instance
        .collection('events').document(widget._eventID)
        .getCollection('music').document(musicID)
        .getCollection('votes').document() //User ID
        .setData(<String, dynamic> {
      //TODO: 'user'
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Column(
        children: <Widget>[
          new Text("Music",
            style: new TextStyle(fontSize: 40.0, fontWeight: FontWeight.w600),
          ),
          new TextField(
            onSubmitted: (content) => onSubmit(context, content),
            decoration: new InputDecoration(hintText: "Search for song to add"),
          ),
          new Padding(padding: new EdgeInsets.only(top: 10.0)),
          new MusicCard("https://marketplace.canva.com/MAB6qNBAV-0/1/0/thumbnail_large/canva-in-too-deep-diving-music-album-cover-MAB6qNBAV-0.jpg", "In Too Deep", "The Naked Heros", currentlyPlaying: true),

          new Expanded(
            child: new StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('events').document(widget._eventID).getCollection('music')
                  .snapshots,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Text("Loading...");
                return new ListView(
                  children: snapshot.data.documents.map((DocumentSnapshot document) {
                    return new InkWell(
                        onTap: () => this.setState(() => onMusicTap(document.documentID)),
                        child: new MusicCard(document.data["cover"], document.data["name"], document.data["artist"], background: background,)
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}

