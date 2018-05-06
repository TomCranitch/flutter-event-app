import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
    home: new HomePage(),
  ));
}

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({ this.builder }) : super();

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(
        opacity: new CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut
        ),
        child: child
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  // TODO: implement barrierLabel
  @override
  String get barrierLabel => null;

}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Hero demo'),
      ),
      body: new Align(
        alignment: FractionalOffset.center,
        child: new Card(
          child: new Hero(
            tag: 'developer-hero',
            child: new Container(
              width: 300.0,
              height: 300.0,
              child: new FlutterLogo(),
            ),
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.developer_mode),
        onPressed: () {
          Navigator.push(
            context,
            new HeroDialogRoute(
              builder: (BuildContext context) {
                return new Center(
                  child: new AlertDialog(
                    title: new Text('You are my hero.'),
                    content: new Container(
                      child: new Hero(
                        tag: 'developer-hero',
                        child: new Container(
                          height: 200.0,
                          width: 200.0,
                          child: new FlutterLogo(),
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text('RAD!'),
                        onPressed: Navigator
                            .of(context)
                            .pop,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}