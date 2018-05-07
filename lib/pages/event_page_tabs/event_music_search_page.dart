import 'package:flutter/material.dart';
import '../../widgets/event_music_list_card.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class EventMusicSearchPage extends StatefulWidget {
  String _searchString;
  String _accessToken;
  final String _eventID;

  EventMusicSearchPage(this._searchString, this._eventID);

  @override
  State createState() => new EventMusicSearchPageState();

}

class EventMusicSearchPageState extends State<EventMusicSearchPage>{
  List _data;


  @override
  void initState () {
    super.initState();
    getAccessToken();
    querySpotify(widget._searchString);
  }

  ///Queries the Firestore for the Spotify Access Tocken
  getAccessToken() async {
    Firestore.instance.document("events/" + widget._eventID).snapshots.listen((DocumentSnapshot docSnapshot) {
      this.setState(() {
        widget._accessToken = docSnapshot.data["access-token"];
      });
    });
  }

  ///Searches Spotify based on the [query]
  querySpotify(String query) async {
    if(widget._accessToken == "") {
      _data = null;
      return;
    }
    query = "https://api.spotify.com/v1/search?q=" + query.replaceAll(new RegExp("\s+"), "%20") + "&type=track";

    var response = await http.get(
      Uri.encodeFull(query),
      headers: {
        "Authorization": "Bearer " + widget._accessToken
      }
    );
    this.setState(() {
      _data = JSON.decode(response.body)["tracks"]["items"];
    });
  }

  ///Queries Spotify with the [content] when the search field is submitted
  void onSubmit(String content) {
    querySpotify(content);
  }

  ///Votes for song when the song at the specified [index] is tapped
  void onSongTap (int index) async {
    Firestore.instance.collection("events").document(widget._eventID).getCollection("music")
        .document(_data[index]["uri"]).setData(<String, dynamic>{
      "played": false,
      "name": _data[index]["name"],
      "artist": _data[index]["artists"][0]["name"],
      "cover":  _data[index]["album"]["images"][0]["url"],
    });

    // TODO: add user vote

    this.setState(() => _data.removeAt(index));
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
          ],
        ),
      ),
    );
  }

}

