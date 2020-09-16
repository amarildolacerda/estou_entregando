library html_container_web;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'fakeui.dart' if (dart.library.html) 'dart:ui'
    as ui; //import 'dart:html';
import 'package:universal_html/html.dart' as html;

class Iframe extends StatefulWidget {
  final String width;
  final String height;
  final double border;
  final String name;
  final String src;
  final String srcDoc;
  Iframe(
      {Key key,
      this.src,
      this.name = 'iframe',
      this.width,
      this.srcDoc,
      this.border = 0,
      this.height})
      : super(key: key);

  @override
  _IframeState createState() => _IframeState();
}

class _IframeState extends State<Iframe> {
  var element;
  StreamSubscription stm;
  @override
  void initState() {
    super.initState();
    ui.platformViewRegistry.registerViewFactory(widget.name, (int viewId) {
      var iframe = html.IFrameElement();
      //iframe.src = 'javascript:void(0);';
      if (widget.src != null) iframe.src = widget.src;
      if (widget.srcDoc != null) iframe.srcdoc = widget.srcDoc;
      iframe.width = widget.width ?? '100%';
      //iframe.setAttribute('srcbase', widget.src);
      //iframe.setAttribute(
      //    'onload', "frameLoad(this,'${widget.name}','${widget.src}');");
      iframe.height = widget.height ?? '100%';
      stm = iframe.onLoad.listen((item) {
        // iframe.contentWindow.location.href = widget.src;
        stm.cancel();
      });
      //iframe.setAttribute('border', "${border ?? 0}");
      //iframe.setAttribute('frameBorder', "${border ?? 0}");
      //iframe.setAttribute('data-userset', 'true');
      return iframe;
    });

    element = HtmlElementView(key: UniqueKey(), viewType: widget.name);
  }

  close() {
    //stm.close();
  }

  @override
  Widget build(BuildContext context) {
    print('builder iframe');
    return element;
  }
}
