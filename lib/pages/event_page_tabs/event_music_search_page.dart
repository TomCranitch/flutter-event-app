import 'package:flutter/material.dart';
import '../../widgets/event_music_list_card.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class EventMusicSearchPage extends StatefulWidget {
  String _searchString;
  final String _eventID;

  EventMusicSearchPage(this._searchString, this._eventID);

  @override
  State createState() => new EventMusicSearchPageState();

}

class EventMusicSearchPageState extends State<EventMusicSearchPage>{
  String _spotifyAccessToken = "BQCVNnU7xRTdVmG2bNEVmG5l0iUfMI_PYvK92xj7Ee8XKCUUHnJQ0FnMZAtePet2n4R86PcjU5T6wY6dre9_3toHRsy0bwmvMoIRKZrvHnAr1xMOo7kUdYLVqBdFJZIturCvWI8yI7rWhkXHEMuLguxC0EAuBS4BldAnfvnwxO4_kwWLmwJFLUKMUwIL";
  List _data;


  @override
  void initState () {
    super.initState();
    querySpotify(widget._searchString);
  }

  querySpotify(String query) async {
    query = "https://api.spotify.com/v1/search?q=" + query.replaceAll(new RegExp("\s+"), "%20") + "&type=track";

    var response = await http.get(
      Uri.encodeFull(query),
      headers: {
        "Authorization": "Bearer " + _spotifyAccessToken
      }
    );
    this.setState(() {
      _data = JSON.decode(response.body)["tracks"]["items"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Column(
          children: <Widget>[
            new Text("Music Search",
              style: new TextStyle(fontSize: 40.0, fontWeight: FontWeight.w600),
            ),
            new TextField(
              onSubmitted: (content) => onSubmit(content),
              decoration: new InputDecoration(hintText: "Search for song to add"),
            ),
            new Padding(padding: new EdgeInsets.only(top: 10.0)),
            _data == null ? new CircularProgressIndicator() :
            new Expanded(
              child: new ListView.builder(
                itemCount: _data.length,
                itemBuilder: (BuildContext context, int index) {
                  return new InkWell(
                    onTap: () => onSongTap(index),
                    child: new MusicCard(
                        _data[index]["album"]["images"][0]["url"],
                        _data[index]["name"],
                        _data[index]["artists"][0]["name"],
                    ),
                  );
                },
              ),
            )
            //new MusicCard("https://marketplace.canva.com/MAB6qNBAV-0/1/0/thumbnail_large/canva-in-too-deep-diving-music-album-cover-MAB6qNBAV-0.jpg", "In Too Deep", "The Naked Heros", true),
            //new MusicCard("http://payload368.cargocollective.com/1/4/158872/9666476/Tame-Impala-Currents-final-packshot-1200px_800.jpg", "The Less You Know the Better", "Tame Impala", false),
          ],
        ),
      ),
    );
  }

  void onSubmit(String content) {
    querySpotify(content);
  }
  
  void onSongTap (int index) async {
    Firestore.instance.collection("events").document(widget._eventID).getCollection("music")
        .document(_data[index]["uri"]).setData(<String, dynamic>{
          "played": false,
          "name": _data[index]["name"],
          "artist": _data[index]["artists"][0]["name"],
          "cover":  _data[index]["album"]["images"][0]["url"],
          //TODO:
    });

    print(_data[index]["uri"]);
    this.setState(() => _data.removeAt(index));
  }


}

