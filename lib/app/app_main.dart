import 'package:comum/services/config_service.dart';
import 'package:estou_entregando/app/routing.dart';
//import 'package:estou_entregando/app/view/procurar.dart';
import 'package:flutter/material.dart';
import 'config/config.dart';
import 'package:get/get.dart';
import 'view/home_page.dart';

class AppMain extends StatefulWidget {
  final bool isComponentOnly;

  const AppMain({Key key, this.isComponentOnly = false}) : super(key: key);

  @override
  _AppMainState createState() => _AppMainState();
}

class _AppMainState extends State<AppMain> {
  var texto;
  @override
  void initState() {
    super.initState();
    texto = Uri.base.queryParameters['texto'];
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    ConfigApp().init().then((x) {
      print('iniciado');
      ConfigApp().setup(autoLogin: true);
    });

    bool _isComponentOnly =
        ((Uri.base.queryParameters['embedded'] ?? '') == '1') ||
            this.widget.isComponentOnly ||
            texto != null;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Estou entregando',
      theme: ThemeData(
        fontFamily: 'WorkSans',
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      home: StreamBuilder(
          stream: ConfigNotifier().stream,
          builder: (context, snapshot) {
            return HomePage(
              isComponentOnly: _isComponentOnly,
              por: texto,
            );
          }),
      getPages: Routes.routes,
    );
  }
}
