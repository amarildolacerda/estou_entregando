import 'package:controls_web/controls/home_elements.dart';
import 'package:controls_web/controls/page_tab_view.dart';
import 'package:controls_web/controls/tab_choice.dart';
import 'package:estou_entregando/app/models/estouentregando_model.dart';
import 'package:flutter/material.dart';

class PainelView extends StatefulWidget {
  static final route = '/painel';
  PainelView({Key key}) : super(key: key);

  @override
  _PainelViewState createState() => _PainelViewState();
}

class _PainelViewState extends State<PainelView> {
  @override
  Widget build(BuildContext context) {
    return PageTabView(
      appBar: AppBar(title: Text('')),
      indicatorColor: Colors.amber,
      tabColor: Colors.blue,
      choices: [
        TabChoice(
          index: 0,
          icon: Icons.account_box,
          label: 'Cadastrados',
          child: PainelMaisPage(),
        ),
        TabChoice(
          index: 1,
          icon: Icons.info,
          label: 'Consultados',
          child: PainelMaisConsultadasPage(),
        )
      ],
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int cards = 0;

  @override
  Widget build(BuildContext context) {
    return ApplienceCards(children: [
      ApplienceStatus(
        title: 'Cards',
        value: cards.toString(),
      )
    ]);
  }
}

class PainelMaisConsultadasPage extends StatelessWidget {
  const PainelMaisConsultadasPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var i = 0;
    return SingleChildScrollView(
      child: FutureBuilder(
          future: EstouEntregandoModel().palavrasPesquisadas(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Align(child: CircularProgressIndicator());
            return SafeArea(
                child: Wrap(
              children: <Widget>[
                for (var item in snapshot.data['result'])
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: ((i++ % 2) == 0) ? Colors.white30 : Colors.amber,
                      constraints: BoxConstraints(minWidth: 50, minHeight: 30),
                      padding: EdgeInsets.all(2),
                      child: Text(
                          '$i: ${(item['cidade'] ?? '').replaceAll('%', ' ')}/${(item['pesquisou'] ?? '').replaceAll('%', ' ')}'),
                    ),
                  )
              ],
            ));
          }),
    );
  }
}

class PainelMaisPage extends StatelessWidget {
  const PainelMaisPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var i = 0;
    return SingleChildScrollView(
      child: FutureBuilder(
          future: EstouEntregandoModel().palavrasMaisCadastradas(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Align(child: CircularProgressIndicator());
            return SafeArea(
                child: Wrap(
              children: <Widget>[
                for (var item in snapshot.data['result'])
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: ((i++ % 2) == 0) ? Colors.white30 : Colors.amber,
                      constraints: BoxConstraints(minWidth: 50, minHeight: 30),
                      padding: EdgeInsets.all(2),
                      child: Text('$i: ${item['texto']}'),
                    ),
                  )
              ],
            ));
          }),
    );
  }
}
