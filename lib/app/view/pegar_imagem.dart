import 'package:controls_data/data.dart';
import 'package:controls_firebase/firestorage_images.dart';
import 'package:controls_web/controls/rounded_button.dart';
import 'package:estou_entregando/app/models/estouentregando_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class PegarImagemLogoView extends StatefulWidget {
  final String logo;
  final Map<String, dynamic> dados;
  final Function(String) onChanged;
  PegarImagemLogoView({Key key, this.logo, this.onChanged, this.dados})
      : super(key: key);

  @override
  _PegarImagemLogoViewState createState() => _PegarImagemLogoViewState();
}

class _PegarImagemLogoViewState extends State<PegarImagemLogoView> {
  String imagem;
  bool processando;
  @override
  void initState() {
    processando = false;
    imagem = (widget.logo ?? '').replaceAll('null', '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mask = ((imagem ?? '').length == 0)
        ? 'entregando/' + Uuid().v1().substring(1, 5) + '_'
        : imagem;
    return Scaffold(
      appBar: AppBar(title: Text('Imagem')),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
                height: 300,
                width: 400,
                child: FirestorageUploadImage(
                  buttonTitle: 'Localizar um LOGO para o cartão',
                  maskTo: mask,
                  maxBytes: 75000,
                  img: imagem,
                  clientId: 'entregando',
                  onProgress: (b) {
                    setState(() {
                      processando = b;
                    });
                  },
                  onChange: (src) {
                    //print('upload: $src');

                    widget.onChanged(src);
                    Navigator.of(context).pop();
                  },
                  metadata: {
                    "type": 'logo',
                    "nome":
                        EstouEntregandoItem.limpar(widget.dados['nome'] ?? ''),
                    "id": widget.dados['gid']
                  },
                )),
            RoundedButton(
              buttonName: 'Confirmar',
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            if (processando) Align(child: CircularProgressIndicator()),
            StreamBuilder(
              stream: ErrorNotify().stream,
              builder: (a, b) {
                if (!b.hasData) return Container();
                return Text(b.data);
              },
            )
          ],
        ),
      ),
    );
  }
}
