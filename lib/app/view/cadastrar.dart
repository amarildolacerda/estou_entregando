import 'dart:async';

import 'package:controls_web/controls/rounded_button.dart';
import 'package:controls_web/drivers/bloc_model.dart';
import 'package:estou_entregando/app/config/config.dart';
import 'package:estou_entregando/app/models/estouentregando_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_bloc.dart';
import 'pegar_imagem.dart';
import 'package:controls_extensions/extensions.dart';

class CadastrarView extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool embeded;
  final String tokenAlteracao;
  CadastrarView({Key key, this.item, this.embeded = true, this.tokenAlteracao})
      : super(key: key);

  @override
  _CadastrarViewState createState() => _CadastrarViewState();
}

class _CadastrarViewState extends State<CadastrarView> {
  final _formKey = GlobalKey<FormState>();
  //final TextEditingController _cidadeController = TextEditingController();
  EstouEntregandoItem item;
  bool enviando;

  final TextEditingController _logoController = TextEditingController();

  @override
  initState() {
    enviando = false;
    enviandoBloc = BlocModel<bool>();
    item = EstouEntregandoItem.fromJson(widget.item ?? {});
    _logoController.text = item.logo;

    super.initState();
  }

  @override
  void dispose() {
    enviandoBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tkn = podeEditar(item.gid ?? '', widget.tokenAlteracao ?? '??');
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(maxWidth: 550),
          padding: EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                  initialValue: item.nome,
                  maxLength: 128,
                  //controller: _nomeController,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal),
                  decoration: InputDecoration(
                    //border: InputBorder.none,
                    labelText: 'Nome da loja *',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Qual o nome que as pessoas identificam a loja';
                    }
                    return null;
                  },
                  onSaved: (x) {
                    item.nome = x.toUpperCapital();
                  }),
              Row(children: <Widget>[
                Container(
                  width: 140,
                  child: TextFormField(
                      initialValue: item.fone,
                      maxLength: 18,
                      //controller: _item.cidadeController,
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.normal),
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                      ),
                      onSaved: (x) {
                        item.cidade = x.toUpperCapital();
                      }),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Container(
                    child: TextFormField(
                        initialValue: item.contato,
                        maxLength: 128,
                        //controller: _item.cidadeController,
                        style: TextStyle(
                            fontSize: 16, fontStyle: FontStyle.normal),
                        decoration: InputDecoration(
                          labelText: 'Contato',
                        ),
                        onSaved: (x) {
                          item.contato = x.toUpperCapital();
                        }),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
              ]),
              if ((tkn != null) && isWebBrowser)
                Container(
                  child: TextFormField(
                      initialValue: item.email,
                      maxLength: 128,
                      //controller: _item.bairroController,
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.normal),
                      decoration: InputDecoration(
                        //border: InputBorder.none,
                        labelText: 'Email *',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Email de contato';
                        }
                        return null;
                      },
                      onSaved: (x) {
                        item.email = x;
                      }),
                ),
              TextFormField(
                  initialValue: item.ender,
                  maxLength: 128,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal),
                  decoration: InputDecoration(
                    labelText: 'Endereço físico da loja',
                  ),
                  onSaved: (x) {
                    item.ender = x.toUpperCapital();
                  }),
              Container(
                child: TextFormField(
                    initialValue: item.bairro,
                    maxLength: 128,
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal),
                    decoration: InputDecoration(
                      labelText: 'Bairro *',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'O bairro ajuda na localização da loja';
                      }
                      return null;
                    },
                    onSaved: (x) {
                      item.bairro = x.toUpperCapital();
                    }),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      child: TextFormField(
                          initialValue: item.cidade,
                          maxLength: 128,
                          //controller: _item.cidadeController,
                          style: TextStyle(
                              fontSize: 16, fontStyle: FontStyle.normal),
                          decoration: InputDecoration(
                            //border: InputBorder.none,
                            labelText: 'Cidade *',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'diga a cidade para falicitar a localização';
                            }
                            return null;
                          },
                          onSaved: (x) {
                            item.cidade = x.toUpperCapital();
                          }),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                    width: 100,
                    child: TextFormField(
                        initialValue: item.estado,
                        maxLength: 2,
                        //controller: _item.estadoController,
                        style: TextStyle(
                            fontSize: 16, fontStyle: FontStyle.normal),
                        decoration: InputDecoration(
                          //border: InputBorder.none,
                          labelText: 'Estado/UF *',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'UF onde a loja esta localizada';
                          }
                          return null;
                        },
                        onChanged: (x) {
                          item.estado = x.toUpperCase();
                        },
                        onSaved: (x) {
                          item.estado = x.toUpperCase();
                        }),
                  ),
                ],
              ),
              TextFormField(
                  initialValue: item.oque,
                  maxLength: 250,

                  //controller: _item.oque Controller,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal),
                  decoration: InputDecoration(
                    //border: InputBorder.none,
                    labelText: 'o quê a loja entrega *',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'o quê entrega é na localização da loja';
                    }
                    return null;
                  },
                  onSaved: (x) {
                    item.oque = x.toLowerCase();
                  }),
              TextFormField(
                  initialValue: item.whatsapp,
                  maxLength: 128,

                  //controller: _item.whatsappController,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal),
                  decoration: InputDecoration(
                    //border: InputBorder.none,
                    labelText: 'WhatsApp',
                  ),
                  onSaved: (x) {
                    item.whatsapp = x;
                  }),
              if ((tkn != null) && isWebBrowser)
                TextFormField(
                    initialValue: item.app,
                    maxLength: 128,
                    //controller: _item.appController,
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal),
                    decoration: InputDecoration(
                      //border: InputBorder.none,
                      labelText: 'Dados do App de Entrega, quando houver um',
                    ),
                    onSaved: (x) {
                      item.app = x;
                    }),
              if ((tkn != null) && isWebBrowser)
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                          //initialValue: item.logo,
                          maxLength: 255,
                          controller: _logoController,
                          style: TextStyle(
                              fontSize: 16, fontStyle: FontStyle.normal),
                          enabled: false,
                          decoration: InputDecoration(
                            //border: InputBorder.none,

                            labelText: 'Logo de apresentação da loja',
                          ),
                          onSaved: (x) {
                            item.logo = x;
                          }),
                    ),
                    IconButton(
                        icon: Icon(Icons.image),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (x) => PegarImagemLogoView(
                                  logo: _logoController.text,
                                  dados: item.toJson(),
                                  onChanged: (x) {
                                    setState(() {
                                      _logoController.text = x;
                                    });
                                  })));
                        }),
                  ],
                ),
              TextFormField(
                  initialValue: item.horario,
                  maxLength: 128,

                  //controller: _item.horarioController,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal),
                  decoration: InputDecoration(
                    //border: InputBorder.none,
                    labelText: 'Horários de entrega',
                  ),
                  onSaved: (x) {
                    item.horario = x;
                  }),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RoundedButton(
                      roundLeft: 5,
                      roundRight: 5,
                      width: 120,
                      buttonName: 'Enviar',
                      onTap: () {
// app

                        _save(context);
                      }),
                  StreamBuilder<bool>(
                      initialData: false,
                      stream: enviandoBloc.stream,
                      builder: (context, snapshot) {
                        return snapshot.data
                            ? CircularProgressIndicator()
                            : Container();
                      }),
                ],
              ),
            ]),
          ),
        ),
      ),
    ));
  }

  BlocModel<bool> enviandoBloc;
  _save(context) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      item.logo = _logoController.text;
      item.oque = item.oque.toLowerCase();

      enviandoBloc.notify(true);
      enviando = true;
      Timer(Duration(seconds: 5), () {
        enviandoBloc.notify(false);
        if (enviando) Get.snackbar('', 'Tentar novamente');
      });
      try {
        EstouEntregandoModel().enviar(item).then((x) {
          enviandoBloc.notify(false);
          enviando = false;
          ConfigApp().tokenAlteracao = item.gid ?? '';
          item = EstouEntregandoItem.fromJson(widget.item ?? {});

          if (!widget.embeded) {
            Navigator.of(context).pop();
          } else
            HomePageTabNotifier().notify(0);
          BuscaReloadNotifier().notify(0);
        });
      } catch (e) {
        enviando = false;
        enviandoBloc.notify(false);
      }
    }
  }
}
