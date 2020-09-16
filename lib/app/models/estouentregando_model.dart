import 'dart:convert';

import 'package:controls_data/cached.dart';
import 'package:controls_data/odata_client.dart';
import 'package:estou_entregando/app/config/config.dart';
import 'package:uuid/uuid.dart';

extension StringMax on String {
  max(int n) {
    if (this.length <= n) return this;
    return this.substring(0, n);
  }
}

class EstouEntregandoItem {
  String gid;
  String nome;
  String ender;
  String cidade;
  String estado;
  String contato;
  String oque;
  String fone;
  String whatsapp;
  String app;
  String horario;
  String bairro;
  String email;
  String token;
  String logo;
  String palavras;

  EstouEntregandoItem.test() {
    nome = 'WBAGestao';
    ender = "Rua Parque Domingos luis";
    cidade = "São Paulo";
    estado = "SP";
    contato = "Bruna";
    oque = "Aplicativo de delivery";
    fone = "(11)2914-5067";
    whatsapp = "storeware";
    app = "Storeware APP";
    horario = "8:00 as 20:00";
    bairro = "Jardim São Paulo";
  }

  EstouEntregandoItem.fromJson(j) {
    gid = j['gid'] ?? Uuid().v4();
    nome = j['nome'] ?? '';
    ender = j['ender'] ?? '';
    cidade = j['cidade'] ?? '';
    estado = j['estado'] ?? '';
    contato = j['contato'] ?? '';
    oque = j['oque'] ?? '';
    fone = j['fone'] ?? '';
    whatsapp = j['whatsapp'] ?? '';
    app = j['app'] ?? '';
    horario = j['horario'] ?? '';
    bairro = j['bairro'] ?? '';
    email = j['email'] ?? '';
    token = j['token'];
    logo = j['logo'];
    palavras = j['palavras'];
  }

  encurtarNome(String texto, {minChars = 3}) {
    String rt = '';
    var lst = texto.split(' ');
    lst.forEach((x) {
      if (x.length >= minChars) rt += ' ' + x;
    });
    return rt;
  }

  toJson() {
    prepare();
    var r = {
      "gid": gid,
      "nome": nome,
      "ender": ender,
      "cidade": cidade,
      "estado": estado,
      "contato": contato,
      "oque": oque,
      "fone": fone,
      "whatsapp": whatsapp,
      "app": app,
      "horario": horario,
      "bairro": bairro,
      "email": email,
      'token': token,
      'logo': logo,
      'palavras': palavras
    };
    return r;
  }

  prepare() {
    palavras = limpar((cidade ?? '') +
            '; ' +
            encurtarNome(oque ?? '', minChars: 3) +
            ' ' +
            encurtarNome(nome ?? ' ', minChars: 4) +
            ' ' +
            encurtarNome(ender, minChars: 4))
        .replaceAll(',', '')
        .max(255);
  }

  static String limpar(String texto) {
    texto = texto.toLowerCase();
    var de = 'éíóúâáãàçôÉÍÓÚÂÁÃÀÇÔ';
    var para = 'eiouaaaacoEIOUAAAACO';
    for (var i = 0; i < de.length; i++) {
      var p = texto.indexOf(de[i]);
      if (p > -1) texto = texto.replaceAll(de[i], para[i]);
    }
    //print(texto);
    if (texto.length > 254) texto = texto.substring(0, 254);
    print(texto);
    return texto.toLowerCase();
  }
}

class EstouEntregandoModel {
  static final _singleton = EstouEntregandoModel._create();
  EstouEntregandoModel._create();
  factory EstouEntregandoModel() => _singleton;
  prepare() {
    ODataInst().client.headers['contaid'] = ConfigApp().conta;
  }

  enviar(EstouEntregandoItem item) async {
    try {
      item.prepare();
      prepare();
      var r = ODataInst().client;
      return r.openJsonAsync(
        '/v3/command',
        method: 'POST',
        body: {
          "command":
              "select * from sp_estouentregando4('${item.palavras ?? ''}','${item.gid}','${item.nome}','${item.ender}','${item.cidade}','${item.estado}','${item.contato}','${item.oque}','${item.fone}','${item.whatsapp}','${item.app}','${item.horario}','${item.bairro}','${item.email}','N','${item.token}','${item.logo}')"
        },
      ).then((d) {
        return d;
      });
    } catch (e) {
      print(e.message);
      ODataInst().errorNotifier.notify(e.message);
    }
    //('estouentregando', item.toJson(), removeNulls: true);
  }

//http://fb2.wbagestao.com:8889/v3/estouentregando?
//$select=*&$filter=(cidade%20like%20%27%DElivery%25%27)&$top=500&
  procurar(String cidade, String por) {
    if ((cidade.length == 0) && (por.length == 0)) return null;
    prepare();
    var r = ODataInst().client;
    por = EstouEntregandoItem.limpar(por);
    cidade = EstouEntregandoItem.limpar(cidade);
    // r.contentType = 'application/json; charset=utf-8';

    cidade = cidade.trimLeft().trimRight();
    por = por.trimLeft().trimRight();

    r.contentType = 'application/json';
    return r.openJsonAsync(
      '/v3/open',
      method: 'POST',
      body: {
        "command":
            "select * from SP_PROCURAR_ESTOUENTREGANDO2('$cidade','$por')"
      },
    ).then((d) {
      //print('Resposta: $d');
      return d;
    });
  }

  byGid(String gid) async {
    prepare();
    return ODataInst().send(
      ODataQuery(
        resource: 'wba_estouentregando2',
        filter: "gid eq '$gid' ",
        select: '*',
      ),
    );
  }

  palavrasMaisCadastradas() {
    prepare();
    return ODataInst().send(
      ODataQuery(
        resource: 'estouentregando_palavras',
        top: 100,
        orderby: 'conta desc',
        select: 'texto',
      ),
    );
  }

  cidadesList() async {
    return Cached.value('cidadesList', builder: (x) async {
      prepare();
      return ODataInst()
          .log((x) {
            //print(x);
          })
          .error((a) {
            return null;
          })
          .open("select texto as t from sp_estouentregando_cidades")
          .then((x) {
            return jsonDecode(x);
          });
    });
  }

  palavrasList(cidade) async {
    var c = EstouEntregandoItem.limpar(cidade);
    //print('Pesquisndo: $c');
    prepare();
    try {
      return ODataInst()
          .error((x) {
            print(x);
          })
          .send(ODataQuery(
            resource: "SP_ESTOUENTR_CIDADES_PALAVRAS('$c')",
            select: 'texto as t',
          ))
          .then((x) {
            //print(x);
            return x;
          });
    } catch (e) {
      print('Palavras: $e');
    }
  }

  palavrasPesquisadas() {
    prepare();
    return ODataInst().send(
      ODataQuery(
        resource: 'ESTOUENTREGANDO_PESQUISAS2_LOG',
        top: 100,
        orderby: 'data desc',
        select: 'distinct cidade,pesquisou',
      ),
    );
  }
}
