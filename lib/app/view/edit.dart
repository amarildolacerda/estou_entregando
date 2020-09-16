import 'package:estou_entregando/app/config/config.dart';
import 'package:estou_entregando/app/models/estouentregando_model.dart';
import 'package:flutter/material.dart';

import 'cadastrar.dart';
import 'home_page.dart';

class EditarView extends StatefulWidget {
  final String gid;
  EditarView({Key key, this.gid}) : super(key: key);

  @override
  _EditarViewState createState() => _EditarViewState();
}

class _EditarViewState extends State<EditarView> {
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();

    ConfigApp().checkInited();
    ConfigApp().tokenAlteracao = widget.gid;
    print('gid: ${widget.gid}');
    return Scaffold(
      appBar: AppBar(title: Text('Alteração dos dados do Cartão')),
      body: FutureBuilder(
          future: EstouEntregandoModel().byGid(widget.gid),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Align(child: CircularProgressIndicator());
            print(snapshot.data);
            List<dynamic> result = snapshot.data['result'];
            if (result.length == 0) return HomePage();
            return CadastrarView(
              item: result[0],
              embeded: false,
              tokenAlteracao: widget.gid,
            );
          }),
    );
  }
}
