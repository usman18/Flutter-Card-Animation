import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';

//constants
Color kInactiveGradientStartColor = Colors.grey;
Color kInactiveGradientEndColor = Colors.grey;

Color kActiveGradientStartColor = Colors.blue.shade900;
Color kActiveGradientEndColor = Colors.pink.shade700;

double kActiveOpacity = 1;
double kInactiveOpacity = 0.3;

double kInactiveHeight = 200;
double kInactiveWidth = 200;

double kActiveHeight = 300;
double kActiveWidth = 300;






/*
* The following is an example demonstrating animation of a deck of cards
* where each card when tapped on like/dislike button, moves out with a rotating
* animation and the card behind the current card (which just underwent rotating animation) in the list,
* is brought forward with an animating effect making it 'active' by changing its color
* to a gradient.
* */


void main() => runApp(
      MaterialApp(
        home: ContainerExample(),
      ),
    );



class ContainerModel {
  bool activeState;     //Indicating whether the card/container is in the active state or not (grey/gradient color or small/big in size)

  double opacity;       //For making the card invisible with an animating effect once the card is either liked/disliked

  double rotation;      //The degree of rotation for the rotating animation/effect. It will be clockwise or anticlockwise depending which button (like/dislike) is tapped
  Offset rotationOffset; //The origin which is to be set for the rotating effect. Will vary depending upon which button is clicked

  ContainerModel({this.activeState, this.opacity, this.rotation, this.rotationOffset});

}


class ContainerExample extends StatefulWidget {
  @override
  _ContainerExampleState createState() => _ContainerExampleState();
}

class _ContainerExampleState extends State<ContainerExample> {

  List<ContainerModel> containers = [];

  @override
  void initState() {
    populateCards();
    super.initState();
  }



  void populateCards() {
    for (int i = 10; i >= 0; i--) {
      containers.add(
        ContainerModel(
          activeState: i == 0 ? true : false,       // Making the first card already active
          rotationOffset: Offset(0, 0),             //Default
          rotation: 0,                              //Default
          opacity: 1                                //Default
        )
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cards Animation'),
        centerTitle: true,
      ),
      body: Center(
        child: Stack(
          children: containers.map((container) {
            return Align(
              alignment: Alignment.center,
              child: AnimatingContainer(
                active: container.activeState,
                rotation: container.rotation,
                rotationOffset: container.rotationOffset,
                opacity: container.opacity,
                onThumbsDown: () {
                  setState(() {
                    thumbsDownAnimation(container);
                    int currentIndex = containers.indexOf(container);

                    if (currentIndex != 0) {
                      //Making sure we do not go index out of bounds while we are trying to access the card/container behind the current card

                      Future.delayed(Duration(milliseconds: 200))
                      .then((res) {
                        activeAnimation(containers[currentIndex - 1]);
                      });
                    }

                  });
                },
                onThumbsUp: () {
                  setState(() {
                    thumbsUpAnimation(container);


                    int currentIndex = containers.indexOf(container);

                    if (currentIndex != 0) {
                      //Making sure we do not go index out of bounds while we are trying to access the card/container behind the current card

                      Future.delayed(Duration(milliseconds: 200))
                        .then((res) {
                        activeAnimation(containers[currentIndex - 1]);
                      });

                    }
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }


  void activeAnimation(ContainerModel model) {
    setState(() {
      model.activeState = true;   //Transition the card state from 'inactive' to 'active'
                                  //which will animate the size, color and margins of the card
    });
  }


  void thumbsDownAnimation(ContainerModel model) {
    setState(() {
      model.rotation = -75;
      model.rotationOffset = Offset(0, kActiveHeight);        //As The origin or the axis of rotation is supposed to be the bottom left corner of the card
      model.opacity = 0;  //To make it totally invisible over the rotating animation as the card is no longer supposed to be interacted with.
    });
  }


  void thumbsUpAnimation(ContainerModel model) {
    setState(() {
      model.rotation = 75;
      model.rotationOffset = Offset(kActiveHeight, kActiveHeight);    //As the origin or the axis of rotation is supposed to be the bottom right corner of the card
      model.opacity = 0;          //To make it totally invisible over the rotating animation as the card is no longer supposed to be interacted with.
    });
  }




}


typedef onTapped = void Function();


class AnimatingContainer extends StatelessWidget {
  final bool active;
  final double rotation;
  final double opacity;


  final onTapped onThumbsUp;
  final onTapped onThumbsDown;

  final Offset rotationOffset;


  const AnimatingContainer({Key key, this.active = false, this.rotation = 0, this.onThumbsUp, this.onThumbsDown, this.rotationOffset, this.opacity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      //After the card is invisible, we do not want it to obstruct the other cards (even though it is invisible)
      //so we ignore it once it's opacity becomes 0 and the card is no longer a part of the list.
      //By obstructing here, I mean obstructing the gestures (onThumbsUp/onThumbsDown) of the other cards in the list
    ignoring: opacity == 0,
      child: AnimatedOpacity(
        curve: Curves.bounceOut,
        duration: Duration(milliseconds: 600,),
        opacity: opacity,
        child: AnimatedContainer(
          alignment: Alignment.center,
          //Animating the card/container with rotating effect when the like/dislike button is clicked.
          //This will only happen when the rotating attribute is set to a non - null or non - zero value
          transform: rotation != null ?
            Matrix4Transform().rotateDegrees(rotation,
              origin: rotationOffset
            ).matrix4 :
            null,
          duration: Duration(
            milliseconds: 800,
          ),
          //Animating the margins while the card transitions from active to inactive state
          //to give it a downward translating effect
          margin: EdgeInsets.only(
            top: active ? 80 : 0,
            bottom: active ? 0 : 80,
          ),
          curve: Curves.bounceOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
            gradient: LinearGradient(
              //animating the color of the card/container as it goes from inactive to active state
              colors: active ? [kActiveGradientStartColor, kActiveGradientEndColor] : [kInactiveGradientStartColor, kInactiveGradientEndColor],
            ),
          ),
          height: active ? kActiveHeight : kInactiveHeight,
          width: active ? kActiveWidth : kInactiveWidth,
          child: AnimatedOpacity(
            opacity: active ? kActiveOpacity : kInactiveOpacity,      //Animating the opacity of the buttons as it goes from inactive to active
            duration: Duration(
              milliseconds: 600,
            ),
            child: IgnorePointer(
              ignoring: !active,          //Do not want the icons to be tapped at, when the card is not in focus or is not in 'active' state
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(icon: Icon(Icons.thumb_down), onPressed: onThumbsDown,
                    color: Colors.white,
                    iconSize: 35,
                  ),
                  IconButton(icon: Icon(Icons.thumb_up), onPressed: onThumbsUp,
                    color: Colors.white,
                    iconSize: 35,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
