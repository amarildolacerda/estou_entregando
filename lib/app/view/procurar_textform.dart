//import 'dart:async';

import 'package:controls_web/controls/rounded_button.dart';
import 'package:estou_entregando/app/config/config.dart';
import 'package:flutter/material.dart';

class BuildProcurar extends StatelessWidget {
  final String text;
  BuildProcurar({
    Key key,
    @required this.onClick,
    this.text,
  }) : super(key: key);

  final Function(String p1) onClick;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (text != null) {
      _textController.text = text;
      LogouCloudV3().stream.listen((x) {
        onClick(_textController.text);
      });
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0).copyWith(top: 3),
      child: Stack(
        children: [
          Container(
            height: 50,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      autofocus: true,
                      controller: _textController,
                    ),
                  ),
                ),
                RoundedButton(
                  height: 44,
                  //type: StrapButtonType.warning,
                  borderWidth: 0,
                  color: Colors.amber,
                  buttonName: 'buscar',
                  //radius: 20,
                  onTap: () {
                    onClick(_textController.text);
                  },
                )
              ],
            ),
          ),
          Positioned(
              left: 20,
              child: Text(
                  'procurando por ? (nome, cidade, bairro, produto, serviço)',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Theme.of(context).primaryColor))),
        ],
      ),
    );
  }
}
