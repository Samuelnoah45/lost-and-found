import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

final List<List> imageList = [
  <String>[
    "https://res.cloudinary.com/blue-sky/image/upload/v1676667400/sample/i1_grd9fi.jpg",
    "Do you some wallets to keep your money safe",
    "Wallet for mens",
    "199 ETB"
  ],
  <String>[
    "https://res.cloudinary.com/blue-sky/image/upload/v1676668009/sample/i2_mgxt9t.jpg",
    "Do you want some wallets to keep your money safe",
    "Mobile holder",
    "129 ETB"
  ],
  <String>[
    "https://res.cloudinary.com/blue-sky/image/upload/v1676668008/sample/i3_ipzluz.jpg",
    "Do you want some wallets to keep your money safe",
    "Mobile safety",
    "149 ETB"
  ],
  <String>[
    "https://res.cloudinary.com/blue-sky/image/upload/v1676668008/sample/i5_ylrur9.png",
    "Do you want some wallets to keep your money safe",
    "Car key holder",
    "399 ETB"
  ],
  <String>[
    "https://res.cloudinary.com/blue-sky/image/upload/v1676668008/sample/i4_fwtsgt.png",
    "Do you want some wallets to keep your money safe",
    "House key holder",
    "99 ETB"
  ],
];

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: GFCarousel(
          height: MediaQuery.of(context).size.height * 0.75,
          autoPlay: true,
          items: imageList.map(
            (url) {
              return Container(
                margin: const EdgeInsets.all(2.0),
                child: GFCard(
                  boxFit: BoxFit.cover,
                  titlePosition: GFPosition.start,
                  image: Image.network(
                    url[0],
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                  showImage: true,
                  title: GFListTile(
                    titleText: url[2],
                    subTitleText: url[3],
                  ),
                  content: Text(url[1]),
                  // ignore: prefer_const_constructors
                  buttonBar: GFButtonBar(
                    children: const <Widget>[
                      GFAvatar(
                        backgroundColor: GFColors.PRIMARY,
                        child: Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                      ),
                      GFAvatar(
                        backgroundColor: GFColors.SECONDARY,
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                      GFAvatar(
                        backgroundColor: GFColors.SUCCESS,
                        child: Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).toList(),
          onPageChanged: (index) {
            setState(() {
              index;
            });
          },
        ),

        //  Image.asset("assets/images/lastlogo.png")
      ),
    );
  }
}
