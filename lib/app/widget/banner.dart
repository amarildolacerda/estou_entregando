import 'dart:async';
import 'dart:math';
//import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef void OnBannerClickListener<D>(int index, D itemData);
typedef Widget BuildShowView<D>(int index, D itemData);

const IntegerMax = 0x7fffffff;

class BannerView<T> extends StatefulWidget {
  final OnBannerClickListener<T> onBannerClickListener;

  final int delayTime;
  final int scrollTime;
  final double height;
  final List<T> data;
  final int randomSeed;
  final BuildShowView<T> buildShowView;

  BannerView(
      {Key key,
      @required this.data,
      @required this.buildShowView,
      this.onBannerClickListener,
      this.delayTime = 3,
      this.scrollTime = 200,
      this.height = 200.0,
      this.randomSeed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new BannerViewState();
}

class BannerViewState extends State<BannerView> {
//  double.infinity
  PageController pageController;

  Timer timer;

  BannerViewState() {
//    print(widget.delayTime);
  }
  Random random;
  @override
  void initState() {
    super.initState();
    if (widget.randomSeed != null) random = Random(widget.randomSeed ?? 0);
    pageController = new PageController(initialPage: 0);
    resetTimer();
  }

  resetTimer() {
    clearTimer();
    timer = new Timer.periodic(new Duration(seconds: widget.delayTime),
        (Timer timer) {
      if (pageController.hasClients) {
        var i = pageController.page.toInt() + 1;
        if (random != null) {
          i = random.nextInt(widget.data.length);
        }
        print(i);
        pageController.animateToPage(i == widget.data.length ? 0 : i,
            duration: new Duration(milliseconds: widget.scrollTime),
            curve: Curves.linear);
      }
    });
  }

  clearTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
        height: widget.height,
        child: widget.data.length == 0
            ? null
            : new GestureDetector(
                onTap: () {
                  widget.onBannerClickListener(
                      pageController.page.round() % widget.data.length,
                      widget.data[
                          pageController.page.round() % widget.data.length]);
                },
                onTapDown: (details) {
                  clearTimer();
                },
                onTapUp: (details) {
                  resetTimer();
                },
                onTapCancel: () {
                  resetTimer();
                },
                child: new PageView.builder(
                  controller: pageController,
                  physics: const PageScrollPhysics(
                      parent: const ClampingScrollPhysics()),
                  itemBuilder: (BuildContext context, int index) {
                    return widget.buildShowView(
                        index, widget.data[index % widget.data.length]);
                  },
                  itemCount: widget.data.length,
                ),
              ));
  }

  @override
  void dispose() {
    clearTimer();
    super.dispose();
  }
}
