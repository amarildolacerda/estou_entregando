import 'dart:async';

import 'package:controls_firebase/firebase_driver.dart';
import 'package:controls_firebase/firestorage_images.dart';
import 'package:controls_web/controls/alert.dart';
import 'package:controls_web/controls/asymmetric_view.dart';
import 'package:controls_web/controls/home_elements.dart';

import 'package:controls_web/drivers/bloc_model.dart';
import 'package:estou_entregando/app/models/estouentregando_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cadastrar.dart';
import 'home_bloc.dart';
import 'procurar_textform.dart';

extension DoubleExt on double {
  double max(double value) {
    return (value > this) ? this : value;
  }

  double min(double value) {
    return (value > this) ? value : this;
  }

  double between(double a, double b) {
    double v = min(a);
    return v.max(b);
  }
}

extension SizeResponsive on Size {
  bool get isSmaller {
    return width < 500;
  }

  bool get isCellPhone {
    return (width >= 500) && (width < 700);
  }

  bool get isMedium {
    return (width >= 700) && (width < 1400);
  }

  bool get isLarger {
    return width >= 1400;
  }

  double minWidth(double value, {double min = 0}) {
    return (value < min) ? min : value;
  }

  double maxWidth(double value, {double max = 99999}) {
    return (value > max) ? max : value;
  }

  double boxWidth({max = 250, min = 200}) {
    var cols = width ~/ max;
    if (cols <= 1) return width;
    var w = (width - (cols * 5)) / cols;
    return (w >= min) ? w : min;
  }

  int cols({max = 250, min = 200}) {
    var cols = width ~/ max;
    if (cols <= 1) return 1;
    return cols;
  }
}

class LimpaProcurarBloc extends BlocModel<bool> {
  static final _singleton = LimpaProcurarBloc._create();
  LimpaProcurarBloc._create();
  factory LimpaProcurarBloc() => _singleton;
}

class ProcurarPor extends BlocModel<List<dynamic>> {
  static final _singleton = ProcurarPor._create();
  ProcurarPor._create();
  factory ProcurarPor() => _singleton;
  List<dynamic> _items = [];
  add(item) {
    _items.add(item);
  }

  clear() {
    _items.clear();
    notify(_items);
  }

  update() {
    notify(_items);
  }
}

class BuscarPalavra extends BlocModel<String> {
  static final _singleton = BuscarPalavra._create();
  BuscarPalavra._create();
  factory BuscarPalavra() => _singleton;
}

String buscarPalavra; // usado para passar parametro inicial

class ProcurarLojaView extends StatefulWidget {
  final bool isComponentOnly;
  final String cidade;
  final String por;
  final String tokenAlteracao;
  ProcurarLojaView(
      {Key key,
      this.tokenAlteracao,
      this.cidade,
      this.por,
      this.isComponentOnly = false})
      : super(key: key);

  @override
  _ProcurarLojaViewState createState() => _ProcurarLojaViewState();
}

class _ProcurarLojaViewState extends State<ProcurarLojaView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _porController = TextEditingController();
  BlocModel<bool> procurando;

  bool pesquisando;
  BlocModel<bool> cidadesChegou = BlocModel<bool>();
  bool mostrarDesafio;

  StreamSubscription limparBloc, reloadBusca, buscarPor; //loginChanged,

  AnimationController controllerAnimateIcon;
  void initState() {
    mostrarDesafio = true;
    cidadesList = [];
    buscarPor = BuscarPalavra().stream.listen((x) {
      procurar('', x);
    });
    print('initState procurar ok');
    pesquisando = false;
    procurando = BlocModel<bool>();
    cidadeNode = FocusNode();

    limparBloc = LimpaProcurarBloc().stream.listen((x) {
      _cidadeController.text = '';
      _porController.text = '';
    });
    reloadBusca = BuscaReloadNotifier().stream.listen((x) {
      _buscarDados();
    });

    if (widget.por != null) {
      _porController.text = widget.por;
      buscarPalavra = widget.por;
    }

    if (buscarPalavra != null) {
      Timer.run(() {
        BuscarPalavra().notify(buscarPalavra);
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    cidadeNode.dispose();
    cidadesChegou.dispose();
    procurando.dispose();
    limparBloc.cancel();
    reloadBusca.cancel();
    buscarPor.cancel();
    super.dispose();
  }

  Size size;

  estaPesquisando() {
    return pesquisando && (_cidadeController.text != '') ||
        (_porController.text != '');
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    var w = size.boxWidth(max: 300) * 0.95;

    return SliverContents(
      appBar: //(widget.isComponentOnly)
          //? AppBar(title: Text('Estabelecimentos'))
          //:
          AppBar(
        flexibleSpace: GestureDetector(child: buildProcurar()),
      ),
      body: StreamBuilder<List<dynamic>>(
          stream: ProcurarPor().stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return (widget.isComponentOnly)
                  ? Align(child: CircularProgressIndicator())
                  : ContainerDesafio();

            return AsymmetricView(
                count: snapshot.data.length,
                builder: (x, i) {
                  return buildCard(snapshot.data[i], i, w);
                });
          }),
    );
  }

  perguntaCadastrar(context) {
    return Dialogs.show(context,
        title: Text('Ops, não encontei entregadores'),
        children: [],
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                color: Colors.blue.withAlpha(30),
                child: Text('Continuar'),
                onPressed: () {
                  _cidadeController.text = '';
                  _porController.text = '';
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(
                width: 10,
              ),
              FlatButton(
                color: Colors.blue.withAlpha(30),
                child: Text('Quero indicar um'),
                onPressed: () {
                  _cidadeController.text = '';
                  _porController.text = '';
                  Navigator.of(context).pop();
                  Timer.run(() {
                    HomePageTabNotifier().notify(1);
                  });
                },
              )
            ],
          ),
        ]);
  }

  buildCard(item, int index, double width) {
    var it = EstouEntregandoItem.fromJson(item);
    var f = 15.0;
    var tkn = podeEditar(it.gid ?? '', widget.tokenAlteracao ?? '??');
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          padding: EdgeInsets.all(8),
          width: width,
          color: ((index % 2) == 0)
              ? Colors.amber.withAlpha(30)
              : Colors.blue.withAlpha(30),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (it.logo != null) createLogo(it.logo, it.app),
            Wrap(
              children: <Widget>[
                Text(
                  it.nome,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (tkn != null)
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // editar
                      it.token = podeEditar(
                          it.gid,
                          widget
                              .tokenAlteracao); // quando loga tem um token; - token do proprietadiro do card
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (x) => CadastrarView(
                                    tokenAlteracao: tkn,
                                    item: it.toJson(),
                                    embeded: false,
                                  )));
                    },
                  )
              ],
            ),
            if ((it.oque ?? '').length > 0)
              Text(
                '${it.oque}',
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: f),
              ),
            Divider(),
            if ((it.ender ?? '').length > 0)
              Text(
                '${it.ender}',
                style: TextStyle(fontSize: f),
              ),
            if ((it.cidade ?? '').length > 0)
              Text(
                '${it.cidade} - ${it.estado}',
                style: TextStyle(fontSize: f),
              ),
            if ((it.fone ?? '').length > 0)
              InkWell(
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Fone: ${it.fone}',
                        //style: TextStyle(fontSize: f),
                      ),
                      Icon(Icons.call)
                    ],
                  ),
                  onTap: () {
                    goTel(it.fone);
                  }),
            if (it.app != null) Divider(),
            if ((it.whatsapp ?? '').length > 0)
              InkWell(
                  child: Align(
                    child: Text(
                      'Whats: ${it.whatsapp}',
                      style: TextStyle(fontSize: f, color: Colors.blue),
                    ),
                  ),
                  onTap: () {
                    goWhats(it.whatsapp);
                  }),
            if ((it.app ?? '').length > 0)
              Align(
                child: InkWell(
                    child: Wrap(
                      children: <Widget>[
                        Text(
                          it.app.startsWith('http') ? 'Ir para a loja' : it.app,
                          style: TextStyle(fontSize: f, color: Colors.blue),
                        ),
                        Icon(Icons.smartphone)
                      ],
                    ),
                    onTap: () {
                      goUrl(it.app);
                    }),
              ),
            if ((it.horario ?? '').length > 0)
              Align(
                child: Text(
                  'Horário: ${it.horario}',
                  style: TextStyle(fontSize: f),
                ),
              ),
            if (tkn != null)
              if ((it.email ?? '').length > 0)
                Align(
                  child: InkWell(
                      child: Row(
                        children: <Widget>[
                          Text(
                            it.email,
                            textAlign: TextAlign.center,
                          ),
                          Icon(Icons.mail)
                        ],
                      ),
                      onTap: () {
                        goEmail(it.email);
                      }),
                )
          ]),
        ),
      ),
    );
  }

  FocusNode cidadeNode;
  List<String> cidadesList;

  final TextEditingController _cidadeController = TextEditingController();

  procurar(cidade, por) {
    buscarPalavra = ''; // limpa
    _porController.text = por;
    _cidadeController.text = cidade;
    _buscarDados();
  }

  buildProcurar() {
    return BuildProcurar(
      text: _porController.text,
      onClick: (por) {
        Timer.run(() {
          BuscarPalavra().notify(por);
        });
      },
    );
  }

  _buscarDados() {
    if ((_cidadeController.text.length == 0) &&
        (_porController.text.length == 0)) return;
    pesquisando = true;
    procurando.notify(true);
    Timer(Duration(seconds: 5), () {
      procurando.notify(false);
      if (pesquisando)
        Get.snackbar('', 'Tentar novamente',
            snackPosition: SnackPosition.BOTTOM);
    });

    //print([_cidadeController.text, _porController.text]);
    EstouEntregandoModel()
        .procurar(_cidadeController.text, _porController.text)
        .then((x) {
      pesquisando = false;
      procurando.notify(false);
      if (x != null) {
        List<dynamic> lst = (x['result'] ?? []);
        ProcurarPor().clear();
        lst.forEach((item) {
          //print(item);sao
          ProcurarPor().add(item);
        });
        ProcurarPor().update();
        FocusScope.of(context).unfocus();
      }
    });
  }

  goUrl(String url) async {
    if (url.startsWith('http')) await launch(url);
  }

  goEmail(email) async {
    await launch(
        'mailto:$email?subject=Aplicativo Estou Entregando&body=Vi no aplicativo que vocês estão entregando em casa, poderia:...');
  }

  goTel(fone) async {
    await launch('tel:$fone');
  }

  goWhats(String numero) async {
    var s = '';
    for (var i = 0; i < numero.length; i++) {
      var k = numero[i];
      if ('0123456789'.indexOf(k) >= 0) s += k;
    }
    if (s.length <= 11) {
      if (s.startsWith('55'))
        s = '+' + s;
      else if (!s.startsWith('+55')) s = '+55' + s;
    }
    String url =
        'https://api.whatsapp.com/send?phone=$s&text=Olá. Vi seu contato no aplicativo "estou entregando" e gostaria de:  ';
    //print(s);
    await launch(url);
  }

  createLogo(String logo, String app) {
    logo = (logo ?? '').replaceAll('null', '');
    if ((logo ?? '').length == 0) return Container();
    return Align(
      child: InkWell(
          child: Stack(
            children: <Widget>[
              //Image.network(logo),
              Container(
                height: 200,
                child: FirestorageDownloadImage(
                  img: logo,
                  fit: BoxFit.contain,
                  clientId: 'entregando',
                ),
              ),
              if ((app ?? '').length > 0)
                Positioned(
                    right: 5,
                    child: Icon(Icons.play_circle_filled,
                        color: Colors.red, size: 36)),
            ],
          ),
          onTap: () {
            goUrl(app);
          }),
    );
  }

  double heightTextForm = 50;
/*
  buildTypeAheadFormFieldProcuraPor() {
    return StreamBuilder<bool>(
        stream: palavrasChegou.stream,
        builder: (context, snapshot) {
          return Container(
            padding: EdgeInsets.zero, // symmetric(horizontal: 12),
            // height: heightTextForm,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                border: Border.all(color: Colors.black45)),
            child: TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                  onEditingComplete: () {},
                  controller: _porController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'procura por?',
                  )),
              suggestionsCallback: (pattern) {
                return palavrasList
                    .where((item) =>
                        item.toLowerCase().startsWith(pattern.toLowerCase()))
                    .toList();
              },
              //autoFlipDirection: true,
//            noItemsFoundBuilder: (c) => Text('nenhum item disponível'),
              noItemsFoundBuilder: (c) =>
                  Container(), //Text('cidade não disponível'),
              itemBuilder: (context, suggestion) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(suggestion),
                );
              },
              getImmediateSuggestions: palavrasList.length < 15,
              onSuggestionSelected: (sug) {
                _porController.text = sug;
              },
            ),
          );
        });
  }

  buildTypeAheadFromFileCidade() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      // height: heightTextForm,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            topLeft: Radius.circular(25),
          ),
          border: Border.all(color: Colors.black45)),

      child: TypeAheadField<String>(
        textFieldConfiguration: TextFieldConfiguration(
            autofocus: true,
            controller: _cidadeController,
            onEditingComplete: () {},
            decoration:
                InputDecoration(border: InputBorder.none, labelText: 'cidade')),
        suggestionsCallback: (pattern) {
          return cidadesList
              .where((item) =>
                  item.toLowerCase().startsWith(pattern.toLowerCase()))
              .toList();
        },
        itemBuilder: (context, suggestion) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(suggestion),
          );
        },
        noItemsFoundBuilder: (c) =>
            Container(), //Text('cidade não disponível'),
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        onSuggestionSelected: (suggestion) {
          palavrasList.clear();
          sendPalavrasList(suggestion);
          _cidadeController.text = suggestion;
          _porController.text = '';
        },
        getImmediateSuggestions: false,
        hideOnEmpty: true,
      ),
    );
  }*/
}

class ContainerDesafio extends StatelessWidget {
  const ContainerDesafio({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var loja = '14812';
    print('Loja: $loja');

    return FutureBuilder<Map<String, dynamic>>(
        future: FirebaseApp()
            .firestore()
            .getDoc('lojas/$loja/entregandoConfig', loja),
        builder: (context, x) {
          if (!x.hasData) return Container();
          return DefaultTextStyle(
            style: TextStyle(fontSize: 14, color: Colors.black),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 100, right: 100),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 40,
                    ),
                    Text(x.data['desafio0'],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 20,
                    ),
                    Text(x.data['desafio1']),
                    SizedBox(
                      height: 10,
                    ),
                    Text(x.data['desafio2']),
                    SizedBox(
                      height: 10,
                    ),
                    Text(x.data['desafio3'])
                  ],
                ),
              ),
            ),
          );
        });
  }
}
