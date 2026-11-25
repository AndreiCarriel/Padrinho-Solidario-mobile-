import 'package:flutter/material.dart';
import '../control/control.dart';
import 'visual.dart';

class AdminLogin extends StatefulWidget {
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  ControlBanco _control = ControlBanco();
  bool _existe = true;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    bool existe = await _control.adminExiste();
    if (!mounted) return;
    setState(() {
      _existe = existe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Administrador")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          bannerTopo("Área administrativa", "Acesso restrito", Icons.admin_panel_settings),
          if (!_existe)
            caixaAviso("Ainda não existe administrador. Crie o primeiro acesso.",
                corPrimaria, Icons.info_outline),
          if (_erro != '') caixaAviso(_erro, corVermelho, Icons.error_outline),
          if (_existe)
            cartaoSecao("Entrar", Icons.lock_outline, <Widget>[
              campo("E-mail", "Digite o e-mail", _controllerEmail),
              campoSenha("Senha", "Digite a senha", _controllerSenha),
              botao("Entrar", _entrar),
            ])
          else
            botao("Criar administrador", () {
              abreTelaSubstituindo(context, AdminSetup());
            }),
        ],
      ),
    );
  }

  Future<void> _entrar() async {
    Map<String, dynamic>? admin = await _control.loginAdmin(
        _controllerEmail.text.trim(), _controllerSenha.text);
    if (!mounted) return;
    if (admin == null) {
      setState(() {
        _erro = 'E-mail ou senha incorretos.';
      });
      return;
    }
    abreTelaSubstituindo(context, AdminPainel());
  }
}

class AdminSetup extends StatefulWidget {
  @override
  State<AdminSetup> createState() => _AdminSetupState();
}

class _AdminSetupState extends State<AdminSetup> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  ControlBanco _control = ControlBanco();
  String _erro = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Criar administrador")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[
          if (_erro != '') caixaAviso(_erro, corVermelho, Icons.error_outline),
          cartaoSecao("Primeiro acesso", Icons.person_add_alt, <Widget>[
            campo("Nome", "Digite o nome", _controllerNome),
            campo("E-mail", "Digite o e-mail", _controllerEmail),
            campoSenha("Senha", "Mínimo de 8 caracteres", _controllerSenha),
            botao("Criar", _criar),
          ]),
        ],
      ),
    );
  }

  Future<void> _criar() async {
    String nome = _controllerNome.text.trim();
    String email = _controllerEmail.text.trim();
    if (nome.length < 3 || !emailValido(email) || _controllerSenha.text.length < 8) {
      setState(() {
        _erro = 'Informe nome, e-mail válido e senha com 8 ou mais caracteres.';
      });
      return;
    }
    if (await _control.adminExiste()) {
      if (!mounted) return;
      setState(() {
        _erro = 'Já existe um administrador.';
      });
      return;
    }
    await _control.criarAdmin(nome, email, _controllerSenha.text);
    if (!mounted) return;
    abreTelaSubstituindo(context, AdminPainel());
  }
}

class AdminPainel extends StatefulWidget {
  @override
  State<AdminPainel> createState() => _AdminPainelState();
}

class _AdminPainelState extends State<AdminPainel> {
  ControlBanco _control = ControlBanco();
  String _tabela = 'usuarios';
  List<Map<String, dynamic>> _linhas = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    List<Map<String, dynamic>> linhas = await _control.listarTabela(_tabela);
    if (!mounted) return;
    setState(() {
      _linhas = linhas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel administrativo"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: _body(),
    );
  }

  _body() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: <Widget>[
        cartaoSecao("Tabela", Icons.table_rows_outlined, <Widget>[
          RadioGroup<String>(
            groupValue: _tabela,
            onChanged: (String? valor) {
              setState(() {
                _tabela = valor ?? 'usuarios';
              });
              _carregar();
            },
            child: Column(
              children: _control.tabelasAdmin.map<Widget>((t) {
                return opcaoRadio<String>(t, t, () {
                  setState(() {
                    _tabela = t;
                  });
                  _carregar();
                });
              }).toList(),
            ),
          ),
        ]),
        if (_linhas.isEmpty) vazio(Icons.inbox_outlined, "Nenhum registro nesta tabela."),
        ..._linhas.map<Widget>((linha) {
          return cartaoSimples(<Widget>[
            ...linha.entries.map<Widget>((e) => rotuloValor(e.key, "${e.value}")),
            botao("Excluir", () async {
              await _control.excluir(_tabela, linha['id'] as int);
              _carregar();
            }),
          ]);
        }),
      ],
    );
  }
}
