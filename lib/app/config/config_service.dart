import 'dart:async';

import 'package:controls_data/data_model.dart';
import 'package:controls_data/local_storage.dart' as ls;
import 'package:controls_data/odata_client.dart';
import 'package:controls_data/odata_firestore.dart';
import 'package:controls_firebase/firebase.dart';
import 'package:controls_web/drivers/bloc_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:comum/services/firebase_service.dart';
import 'package:get/get.dart';

bool isFirebase = false;

class LoginChanged extends ChangeNotifier {
  ConfigAppBase config;
  LoginChanged({this.config});
  notify(ConfigAppBase value) {
    config = value;
    notifyListeners();
  }
}

abstract class ConfigBase {
  String restServer = 'https://estouentregando.com';
  ConfigBase();
  init();
  setup();
  String imagemEntradaUrl = 'https://wbagestao.com/w3/resources/entrar.png';
}

var defaultElevation = 1;

/// Configurações do APP
/// de uso interno para controle dos recursos o APP
/// Não usar para configurações da loja   LojaConfig() - configurações do usuário
class ConfigNotifier extends BlocModel<String> {
  static final _singleton = ConfigNotifier._create();
  ConfigNotifier._create();
  factory ConfigNotifier() => _singleton;
}

class Themechanged extends BlocModel<bool> {
  static final _singleton = Themechanged._create();
  Themechanged._create();
  factory Themechanged() => _singleton;
}

class SnakbarNotifier extends BlocModel<String> {
  static final _singleton = SnakbarNotifier._create();
  SnakbarNotifier._create();
  factory SnakbarNotifier() => _singleton;
}

abstract class ConfigAppBase extends ConfigBase {
  int instanceCount = 0;
  bool inited = false;
  var queryParameters = {};
  double filial; // mudar depois que inicializou os dados;
  var _backgroundColor = 'azure';
  get backgroudColor => _backgroundColor;
  set backgroundColor(x) {
    _backgroundColor = x;
  }

  afterLoaded(a, b) {
    /// chamado apos configuraçao concluida
  }

  bool inDev = false;

  LoginChanged loginChanged = LoginChanged();

  checkInited() async {
    if (!inited)
      return await init().then((x) async {
        await setup();
        return true;
      });
    return inited;
  }

  StreamSubscription errorNotifier;
  dispose() {
    errorNotifier.cancel();
  }

  /// Chamar antes de iniciado o App
  @override
  init() async {
    var p = Uri.base.queryParameters;
    p.forEach((k, v) {
      if (v != null) queryParameters[k] = v;
    });
    loginChanged.config = this;
    inited = true;
    try {
      await ls.LocalStorage().init();
    } catch (e) {
      //TODO: windows - erro ao carregar configruação inicial...
    }
    defaultElevation = 0;
    return this;
  }

  recarregar() {
    if ((conta?.length ?? 0) > 0) // carrega as configurações da loja
      setLoja(conta);
  }

  bool autoLogin = false;
  logout() {
    _authorization = '';
    password = '';
    logado = false;
  }

  /// chamar depois de inicado o App
  @override
  setup({bool autoLogin = false, String usuario, String senha}) async {
    if (errorNotifier == null)
      errorNotifier = ErrorNotify().stream.listen((String x) {
        SnakbarNotifier().notify(x);
      });

    this.usuario = usuario ?? this.usuario;
    this.password = senha ?? this.password;

    if (instanceCount == 0) {
      instanceCount++;
      queryParameters['q'] ??= conta ?? 'm5'; // entra em demo
      restServer = queryParameters['h'] ?? 'https://estouentregando.com';

      this.conta ??= queryParameters['q'];

      ODataInst().baseUrl = restServer;
      ODataInst().prefix = '/v3/';

      if (autoLogin)
        firebaseLogin(conta, this.usuario, this.password);
      else {
        // usado em DEV.
        cloudV3.token =
            'eyJjb250YWlkIjoibTUiLCJ1c3VhcmlvIjoiXHUwMDA177+9XCJx77+977+977+977+977+977+977+977+977+977+9IiwiZGF0YSI6IjIwMjAtMDUtMTZUMDI6MTA6MjMuNjUxWiJ9';
      }

      return await ls.LocalStorage().init().then((x) async {
        load();
        if (!autoLogin) {
          loginChanged.notify(this);
        }
        CloudV3();
        return this;
      });
    }
  }

  bool lembrarSenha = false;

  /// Uid de login na plataforma autorizadora
  String userUid = '';

  /// provedor de login autorizador
  String userProvider;

  Map<String, dynamic> configDados = {};
  Map<String, dynamic> dadosLoja = {};

  firebaseLogin(loja, [usuario, senha]) async {
    var cloudV3 = FirebaseService();
    if (isFirebase) firebaseAuth(usuario, senha).then((resp) {});
    return cloudV3.login(loja, usuario, senha ?? loja).then((xCloud) {
      if (xCloud == null) {
        print('não conectou no CloudV3');
        Get.snackbar(
          'Ops... estou só.',
          'Falha na conexão, tente novamente',
          snackPosition: SnackPosition.BOTTOM,
        );

        return false;
      }
      return cloudV3.configDados(loja).then((xConfig) {
        if (xConfig == null) return false;
        configDados.addAll(xConfig);
        restServer = queryParameters['h'] ?? xConfig['restserver'];
        ODataInst().baseUrl = restServer;
        ODataInst().prefix = xConfig['restserverPrefix'];
        filial = toDouble(xConfig['filial'] ?? 1);

        this.usuario = usuario ?? this.usuario;
        this.password = senha ?? this.password;
        setLoja(conta).then((fsp) {
          afterLoaded(xConfig, fsp);
        }); // faz login no v3
        return logado; // inicia acesso o cloud
        //});
      });
    });
  }

  get baseUrl => ODataInst().baseUrl;
  get basePrefix => ODataInst().prefix;

  get firebaseOptions => {
        "apiKey": "AIzaSyAV0c4MPfug-hSJYU8bT5pADkpaUadCYGU",
        "authDomain": "selfandpay.firebaseapp.com",
        "databaseURL": "https://selfandpay.firebaseio.com",
        "projectId": "selfandpay",
        "storageBucket": "selfandpay.appspot.com",
        "messagingSenderId": "858174338114",
        "appId": "1:858174338114:web:1f7773702de59dc336e9db",
        "measurementId": "G-G1ZWS0D01G"
      };

  initFirebase() async {
    try {
      //return FirebaseApp().init(firebaseOptions).then((rsp) {});
    } catch (e) {
      print('Erro ao conectar firebase: $e');
    }
  }

  firebaseAuth(usuario, senha) async {
    var r = await FirebaseApp().auth().signInAnonymously();
    userUid = FirebaseApp().auth().uid;
    return r;
  }

  params(nome) {
    return queryParameters[nome];
  }

  get conta => queryParameters['q'];
  set conta(x) {
    if ((queryParameters['q'] ?? '') != x) logado = false;
    queryParameters['q'] = x;
  }

  String _authorization;
  String _usuario;
  String get usuario => _usuario ?? ((inDev) ? 'checkout' : '');
  set usuario(x) {
    _usuario = x;
  }

  String password;
  Future<String> checkToken() async {
    if (_authorization != null) return _authorization;
    return await ODataInst().login(conta, usuario, password ?? conta).then((x) {
      _authorization = x;
      loginChanged.notify(this);
      return x;
    });
  }

  get logado => ((_authorization ?? '').length > 0);
  set logado(bool x) {
    if (!x) _authorization = '';
    loginChanged.notify(this);
  }

  setLoja(String value, {bool inDev = false}) async {
    queryParameters['q'] = conta = value;
    ODataInst().baseUrl = restServer;
    return ODataInst()
        .login(conta, this.usuario, this.password ?? conta)
        .then((x) {
      _authorization = x;
      save();
      loginChanged.notify(this);
    });
  }

  loginSignInByEmail(String loja, email) {
    // procura se o email é valido
    // TODO: repensar login - usar web-usuarios para pegar o codigo do usuario - depende de alteração na view

    this.usuario = 'checkout';
    this.password = loja;
    return cloudV3.login(loja, usuario, password ?? loja).then((xCloud) {
      return cloudV3.configDados(loja).then((xConfig) {
        //ok - conta existe
        configDados.addAll(xConfig);
        restServer = queryParameters['h'] ?? xConfig['restserver'];
        ODataInst().baseUrl = restServer;
        ODataInst().prefix = xConfig['restserverPrefix'];
        filial = toDouble(xConfig['filial'] ?? 1);
        // TODO:fazer login na conta cliente
        setLoja(loja).then((fsp) {
          afterLoaded(xConfig, fsp);
        }); // faz login no v3
        return logado; // inicia acesso o cloud
        //});
      });
    });
  }

  load() {
    celular = ls.LocalStorage().getKey('celular');
    usuario = ls.LocalStorage().getKey('usuario') ?? '';
    conta = queryParameters['q'] ?? ls.LocalStorage().getKey('contaid') ?? '';
    lembrarSenha = ls.LocalStorage().getBool('lembrarSenha') ?? false;
    password = ls.LocalStorage().getKey('usuario1');
  }

  save() {
    ls.LocalStorage().setKey('usuario', usuario);
    ls.LocalStorage().setKey('contaid', conta);
    ls.LocalStorage().setBool('lembrarSenha', lembrarSenha ?? false);
    ls.LocalStorage().setKey('celular', celular);
    ls.LocalStorage().setKey('usuario1', password);
  }

  /// dados do cliente (comprador) que identifica a sua conta
  /// TODO: Mapear para enviar o codigo de confirmação pelo SMS
  /// o celular é usado para recuperar a conta do usuario;
  String celular;

  /// link de acesso ao cloud function
  ODataClient get restCloudAPI => CloudV3().client;

  /// link de acesso local ao RestServer
  ODataClient get restLocalAPI => ODataInst();
  FirebaseService get cloudV3 => FirebaseService();
}
