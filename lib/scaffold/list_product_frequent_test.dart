import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:add_to_cart_animation/add_to_cart_icon.dart';

import 'package:flutter/material.dart';

import 'list_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add To Cart Animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListProductFrequent(title: 'Add To Cart Animation'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ListProductFrequent extends StatefulWidget {
  ListProductFrequent({Key key, this.title = 'สินค้าสั่งประจำ'})
      : super(key: key);
  final String title;

  @override
  _ListProductFrequentState createState() => _ListProductFrequentState();
}

class _ListProductFrequentState extends State<ListProductFrequent> {
  // We can detech the location of the card by this  GlobalKey<CartIconKey>
  GlobalKey<CartIconKey> gkCart = GlobalKey<CartIconKey>();
  Function(GlobalKey) runAddToCardAnimation;
  var _cartQuantityItems = 0;

  @override
  Widget build(BuildContext context) {
    return AddToCartAnimation(
      // To send the library the location of the Cart icon
      gkCart: gkCart,
      rotation: true,
      dragToCardCurve: Curves.easeIn,
      dragToCardDuration: const Duration(milliseconds: 1000),
      previewCurve: Curves.linearToEaseOut,
      previewDuration: const Duration(milliseconds: 500),
      previewHeight: 30,
      previewWidth: 30,
      opacity: 0.85,
      initiaJump: false,
      receiveCreateAddToCardAnimationMethod: (addToCardAnimationMethod) {
        // You can run the animation by addToCardAnimationMethod, just pass trough the the global key of  the image as parameter
        this.runAddToCardAnimation = addToCardAnimationMethod;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: false,
          actions: [
            // Improvement/Suggestion 4.4 -> Adding 'clear-cart-button'
            IconButton(
              icon: Icon(Icons.cleaning_services),
              onPressed: () {
                _cartQuantityItems = 0;
                gkCart.currentState.runClearCartAnimation();
              },
            ),
            SizedBox(width: 16),
            AddToCartIcon(
              key: gkCart,
              icon: Icon(Icons.shopping_cart),
              colorBadge: Colors.red,
            ),
            SizedBox(
              width: 16,
            )
          ],
        ),
        body: ListView(
          children: [
            AppListItem(onClick: listClick, index: 1),
            AppListItem(onClick: listClick, index: 2),
            AppListItem(onClick: listClick, index: 3),
            AppListItem(onClick: listClick, index: 4),
            AppListItem(onClick: listClick, index: 5),
            AppListItem(onClick: listClick, index: 6),
            AppListItem(onClick: listClick, index: 7),
          ],
        ),
      ),
    );
  }

  // Improvement/Suggestion 4.4 -> Running AddTOCartAnimation BEFORE runCArtAnimation
  void listClick(GlobalKey gkImageContainer) async {
    await runAddToCardAnimation(gkImageContainer);
    await gkCart.currentState
        .runCartAnimation((++_cartQuantityItems).toString());
  }
}
