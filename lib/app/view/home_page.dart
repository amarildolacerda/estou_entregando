import 'dart:async';

import 'package:controls_data/odata_client.dart';
import 'package:controls_web/controls/dialogs_widgets.dart';
import 'package:controls_web/controls/responsive.dart';
import 'package:controls_web/controls/tab_choice.dart';
import 'package:controls_web/controls/vertical_tab_view.dart';
//import 'package:controls_web/controls/page_tab_view.dart';
//import 'package:controls_web/controls/vertical_tab_view.dart';

import 'package:estou_entregando/app/config/config.dart';
import 'package:estou_entregando/app/view/cadastrar.dart';
import 'package:estou_entregando/app/view/edit.dart';
import 'package:estou_entregando/app/view/procurar.dart';
//import 'package:estou_entregando/app/view/tabview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:url_launcher/url_launcher.dart';

import 'entrada_view.dart';
import 'home_bloc.dart';

class HomePage extends StatefulWidget {
  final String title;
  final String por;
  final bool isComponentOnly;
  const HomePage(
      {Key key, this.title = "Home", this.isComponentOnly = false, this.por})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageTabNotifier listen;
  String texto;
  @override
  void initState() {
    texto = widget.por;
    listen = HomePageTabNotifier();
    listen.stream.listen((index) {
      controller.animateTo(index);
    });
    ODataInst().client.notifyError.stream.listen((err) {
      Get.snackbar('Erro', '$err');
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  var controller = VerticalTabViewController();
  Size size;
  @override
  Widget build(BuildContext context) {
    //_context = context;
    ResponsiveInfo responsive = ResponsiveInfo(context);
    ConfigApp().init().then((rsp) {
      ConfigApp().setup();
    });

    size = MediaQuery.of(context).size;
    if (ConfigApp().params('edit') != null)
      Timer.run(() {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (x) => EditarView(
                  gid: ConfigApp().params('edit'),
                )));
      });

    if (widget.isComponentOnly) return buildEntradaView();

    return VerticalTabView(
      title: (responsive.size.width < 550)
          ? null
          : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  child: Text(
                'Estou Entregando',
                overflow: TextOverflow.ellipsis,
              )),
            ]),
      leading: CircleAvatar(
        backgroundColor: Colors.white54,
        radius: 20,
        child: GestureDetector(
            child: Image.asset(
              "assets/estou_entregando.png",
              width: 40,
            ),
            onTap: () {
              controller.goHome();
            }),
      ),
      //home: buildEntradaView(),
      bottomNavigationBar: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.all(8),
          height: 40,
          color: Colors.blue.withAlpha(40),
          child: GestureDetector(
              child: Text('powered by Storeware Team',
                  style: TextStyle(color: Colors.blue)),
              onTap: () async {
                String url = 'https://wbagestao.com';
                await launch(url);
              })),
      controller: controller,
      initialIndex: 0,
      choices: [
        TabChoice(
          label: 'Home',
          width: 80,
          index: 0,
          child:
              buildEntradaView(), //color: (x == i) ? _indicatorColor : _titleColor,
        ),
        TabChoice(
          label: 'Procurar',
          width: 100,
          index: procurarView,
          child: ProcurarLojaView(
            tokenAlteracao: ConfigApp().tokenAlteracao,
          ),
        ),
        TabChoice(
          label: 'Cadastrar',
          width: 100,
          index: cadastrarView,
          child: CadastrarView(
            tokenAlteracao: ConfigApp().tokenAlteracao,
          ),
        ),
      ],
    );
  }

  get isComponentOnly => widget.isComponentOnly || (texto != null);
  Widget buildEntradaView() {
    var x = texto;
    texto = null;
    if (x != null)
      return StreamBuilder(
          stream: LogouCloudV3().stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Align(child: CircularProgressIndicator());
            return ProcurarLojaView(
              isComponentOnly: isComponentOnly,
              por: x,
              tokenAlteracao: ConfigApp().tokenAlteracao,
            );
          });
    return EntradaView(
      isComponentOnly: isComponentOnly,
      por: x,
      onClick: (por) {
        buscarPalavra = por;
        if (isComponentOnly) {
          // Size size = MediaQuery.of(context).size;
          Dialogs.showPage(
            context,
            //width: size.width,
            //height: size.height,
            //duration: 0,
            fullPage: true,
            child: ProcurarLojaView(
              isComponentOnly: isComponentOnly,
              tokenAlteracao: ConfigApp().tokenAlteracao,
            ),
          );
        } else
          controller.animateTo(procurarView);
      },
    );
  }
}
