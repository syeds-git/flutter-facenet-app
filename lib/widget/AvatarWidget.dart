import 'package:flutter/material.dart';
import 'package:GoNawazGo/model/Avatar.dart';

class AvatarWidget extends StatelessWidget {
  final List<Avatar> avatars;
  final AvatarCallback onAvatarSelect;

  AvatarWidget(this.avatars, this.onAvatarSelect);

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: getCircleAvatars(this.avatars, context),
    );
  }

  List<Widget> getCircleAvatars(List<Avatar> avs, BuildContext context) {
    return avs
        .map((av) => GestureDetector(
              onTap: () {
                this.onAvatarSelect(av);
              },
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    SizedBox(height: 2),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade900,
                        borderRadius: BorderRadius.circular(26),
                        border:
                            Border.all(color: Colors.green.shade900, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.black,
                        backgroundImage: AssetImage(av.imageLocation),
                      ),
                    ),
                    Expanded(
                        child: Text(
                      av.firstName,
                      style: TextStyle(
                          height: 1.75,
                          letterSpacing: 0.15,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    )),
                    // SizedBox(height: 1),
                    Expanded(
                      child: Text(
                        av.lastName,
                        style: TextStyle(
                            height: 1.15,
                            letterSpacing: 0.15,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(height: 1),
                  ],
                ),
              ),
            ))
        .toList();
  }

  List<Widget> getCircularAvatar(List<Avatar> avs, BuildContext context) {
    return avs
        .map((av) => GestureDetector(
              onTap: () {
                this.onAvatarSelect(av);
              },
              child: Column(children: [
                CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(av.imageLocation),
                    backgroundColor: Colors.green.shade800),
                Expanded(
                    child: Text(
                  av.firstName,
                  style: Theme.of(context).textTheme.bodyText2,
                )),
                SizedBox(height: 5),
                Expanded(
                    child: Text(
                  av.lastName,
                  style: Theme.of(context).textTheme.bodyText2,
                )),
              ]),
            ))
        .toList();
  }
}

typedef AvatarCallback = void Function(Avatar avatar);
