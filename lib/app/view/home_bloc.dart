import 'package:controls_firebase/firebase_driver.dart';
import 'package:controls_web/drivers/bloc_model.dart';

const homeView = 0;
const procurarView = 1;
const cadastrarView = 2;

class HomePageTabNotifier extends BlocModel<int> {
  static final _singleton = HomePageTabNotifier._create();
  HomePageTabNotifier._create();
  factory HomePageTabNotifier() => _singleton;
}

class BuscaReloadNotifier extends BlocModel<int> {
  static final _singleton = BuscaReloadNotifier._create();
  BuscaReloadNotifier._create();
  factory BuscaReloadNotifier() => _singleton;
}

get isWebBrowser {
  print(FirebaseApp().isWebBrowser);
  return FirebaseApp().isWebBrowser;
}

podeEditar(String gid, String token) {
  return (token == 'admin') || (gid.indexOf(token) > -1) ? token : null;
}
