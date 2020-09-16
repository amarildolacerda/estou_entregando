import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:estou_entregando/app/config/config.dart';

import 'iframe.dart';
import 'procurar_textform.dart';

class EntradaView extends StatefulWidget {
  final Function(String) onClick;
  final bool isComponentOnly;
  final String por;
  EntradaView({
    Key key,
    this.onClick,
    this.isComponentOnly,
    this.por,
  }) : super(key: key);

  @override
  _EntradaViewState createState() => _EntradaViewState();
}

class _EntradaViewState extends State<EntradaView> {
  String texto;
  var viewKey = ValueKey('proc1');
  var iframeKey = GlobalKey();

  @override
  void initState() {
    texto = widget.por;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isComponentOnly)
      return Material(
          child: BuildProcurar(text: texto, onClick: widget.onClick));

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: GestureDetector(child: buildProcurar()),
      ),
      body: StreamBuilder<Object>(
          initialData: ConfigApp().logado,
          stream: LogouCloudV3().stream,
          builder: (context, snapshot) {
            if ((!snapshot.hasData) || (!snapshot.data)) return Container();
            print('main load');
            return Column(
              children: [
                Expanded(
                  child: FutureBuilder<Response<dynamic>>(
                      future: Dio().get(
                          'https://wbagestao.com/wp-json/wp/v2/posts?per_page=1&_fields=link'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Container();
                        var map = snapshot.data.data;
                        String src = '${map[0]['link']}';
                        return Iframe(
                            key: iframeKey,
                            src: src); // HtmlIFrameViewImpls(src: src);
                      }),
                ),
              ],
            );
          }),
    );
  }

  buildProcurar() {
    return BuildProcurar(onClick: widget.onClick);
  }
}
