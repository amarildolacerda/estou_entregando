import 'package:estou_entregando/app/view/edit.dart';
import 'package:estou_entregando/app/view/painel_view.dart';
import 'package:get/get.dart';
import 'view/cadastrar.dart';
import 'view/home_page.dart';

class Routes {
  static final routes = [
    GetPage(name: '/', page: () => HomePage()),
    GetPage(name: '/procurar', page: () => HomePage()),
    GetPage(name: '/cadastrar', page: () => CadastrarView()),
    GetPage(name: '/painel', page: () => PainelView()),
    GetPage(
        name: '/edit/:gid', page: () => EditarView(gid: Get.parameters['gid'])),
  ];
}
