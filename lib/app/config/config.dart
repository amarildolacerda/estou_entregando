//import 'package:comum/services/config_service.dart';
import 'package:controls_data/odata_client.dart';
import 'package:controls_data/odata_firestore.dart';
import 'package:controls_firebase/firebase.dart';
import 'package:controls_web/drivers/bloc_model.dart';
import 'package:estou_entregando/app/config/config_service.dart';

bool inDev = false;
bool inLog = false;

class LogouCloudV3 extends BlocModel<bool> {
  static final _singleton = LogouCloudV3._create();
  LogouCloudV3._create();
  factory LogouCloudV3() => _singleton;
}

class ConfigApp extends ConfigAppBase {
  static final _singleton = ConfigApp._create();
  ConfigApp._create();
  factory ConfigApp() => _singleton;
  @override
  init() async {
    super.init();
    conta = '14812';
    isFirebase = FirebaseApp().isWebBrowser;
  }

  @override
  setup({autoLogin = false, usuario, senha}) async {
    ODataInst().log((x) {
      if (inLog) print('ConfigLog: $x');
    });
    CloudV3().client.log((x) {
      if (inLog) print(x);
    });
    CloudV3().client.error((x) {
      print(x);
    });
    var p = Uri.base.queryParameters;
    restServer = (inDev)
        ? 'http://localhost:8886'
        : p['h'] ?? 'https://estouentregando.com';
    ODataInst().prefix = '/v3/';
    _token = params('token') ?? params('edit') ?? '??';
    conta = '14812';
    queryParameters['q'] = p['q'] ?? '14812';
    queryParameters['h'] = restServer;
    super.setup(autoLogin: autoLogin, usuario: 'checkout', senha: '14812');
  }

  params(nome) => Uri.base.queryParameters[nome];

  String _token;
  get tokenAlteracao => _token;
  set tokenAlteracao(x) {
    _token = x;
  }

  String desafio1 =
      'Conectar o comércio local com as pessoas que desejando algum produto.';
  String desafio2 =
      'Se há um comércio próximo no seu bairro que entrega em casa, não deixe de cadastrá-lo/indicá-lo ajudando quem esta em casa.';
  String desafio3 = 'Estou Entregando agradece sua ajuda';

  @override
  afterLoaded(a, b) {
    print('afterLoaded event');
    LogouCloudV3().notify(true);
  }
}
