import 'package:flutter/material.dart';

class MusicCard extends StatefulWidget {
  String _imageSource;
  String _title;
  String _artist;
  bool _currentlyPlaying;
  Color _background;

  //Todo: include track uri as var
  MusicCard(String imageSource, String title, String artist, {bool currentlyPlaying: false, Color background: Colors.white}) {
    this._imageSource = imageSource;
    this._title = title;
    this._artist = artist;
    this._currentlyPlaying = currentlyPlaying;
    this._background = background;
  }

  @override
  State createState() => new MusicCardState();
}

class MusicCardState extends State<MusicCard> {

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: new Card(
        color: widget._background,
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Image.network(widget._imageSource, fit: BoxFit.contain, width: MediaQuery.of(context).size.width*0.3,),
            new Padding(
              padding: const EdgeInsets.all(5.0),
              child: new Container(
                width: MediaQuery.of(context).size.width*0.6,
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    widget._currentlyPlaying ? new Text("Currently Playing",
                      style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
                    ) : new Container(),
                      new Text(widget._title,
                        style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
                        overflow: TextOverflow.ellipsis,
                      ),
                    new Text("by " + widget._artist,
                      style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.w300),)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}