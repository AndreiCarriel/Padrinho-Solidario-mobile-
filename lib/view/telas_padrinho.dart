import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../control/control.dart';
import '../model/modelos.dart';
import '../widgets/textview.dart';
import 'telas_admin.dart';
import 'telas_instituicao.dart';
import 'visual.dart';

//VIEW: Login (primeira tela), Cadastro de padrinho, area do padrinho e Doacao

//login.php - e a primeira tela do app
class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  ControlBanco _control = ControlBanco();
  String _perfil = 'padrinho'; //valor escolhido no Radio
  String _erro = '';
  bool _bancoOk = false;
  String _bancoTexto = 'Verificando o banco de dados...';

  //aula 14 - metodo start chamado quando a tela abre: confere a conexao com o banco
  @override
  void initState() {
    super.initState();
    _verificarBanco();
  }

  Future<void> _verificarBanco() async {
    Map<String, dynamic> resultado = await _control.verificarBanco();
    if (!mounted) return;
    setState(() {
      _bancoOk = resultado['ok'] as bool;
      _bancoTexto = resultado['texto'] as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Padrinho Solidário"),
        actions: <Widget>[
          //aula 06 - IconButton na AppBar, abre a area administrativa
          IconButton(
            icon: Icon(Icons.admin_panel_settings_outlined),
            onPressed: () {
              abreOutraTela(context, AdminLogin());
            },
          ),
        ],
      ),
      body: _body(),
    );
  }

  _body() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 8),
          alignment: Alignment.center,
          child: Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: corPrimaria, shape: BoxShape.circle),
            child: Icon(Icons.favorite, color: Colors.white, size: 38),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Textview("Entrar", corEscura)],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 8),
          child: Text("Acesse sua conta usando seu e-mail e senha.",
              textAlign: TextAlign.center, style: estiloSuave),
        ),
        //situacao da conexao com o banco de dados
        caixaAviso(_bancoTexto, _bancoOk ? corVerde : corVermelho,
            _bancoOk ? Icons.storage : Icons.error_outline),
        Container(
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.all(18),
          decoration: decoCartao(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Tipo de acesso", style: estiloTitulo),
              //aula 06 - Radio (o grupo e controlado pelo RadioGroup)
              RadioGroup<String>(
                groupValue: _perfil,
                onChanged: (String? valor) {
                  setState(() {
                    _perfil = valor ?? 'padrinho';
                  });
                },
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: opcaoRadio<String>("Padrinho", 'padrinho', () {
                        setState(() {
                          _perfil = 'padrinho';
                        });
                      }),
                    ),
                    Expanded(
                      child: opcaoRadio<String>("Instituição", 'instituicao', () {
                        setState(() {
                          _perfil = 'instituicao';
                        });
                      }),
                    ),
                  ],
                ),
              ),
              if (_erro != '') caixaAviso(_erro, corVermelho, Icons.error_outline),
              campo("E-mail", "Digite seu e-mail", _controllerEmail),
              campoSenha("Senha", "Digite sua senha", _controllerSenha),
              botao("Entrar", _entrar),
            ],
          ),
        ),
        InkWell(
          onTap: _abreCadastro,
          child: Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text("Ainda não tem cadastro? Cadastre-se",
                style: TextStyle(color: corPrimaria, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _abreCadastro() {
    if (_perfil == 'instituicao') {
      abreOutraTela(context, CadastroInstituicao());
    } else {
      abreOutraTela(context, CadastroPadrinho());
    }
  }

  Future<void> _entrar() async {
    String email = _controllerEmail.text.trim();
    String senha = _controllerSenha.text;
    if (!emailValido(email) || senha == '') {
      setState(() {
        _erro = 'Informe um e-mail válido e sua senha.';
      });
      return;
    }
    try {
      Map<String, dynamic>? usuario = await _control.login(_perfil, email, senha);
      if (!mounted) return;
      if (usuario == null) {
        setState(() {
          _erro = 'E-mail ou senha incorretos para o perfil selecionado.';
        });
        return;
      }
      await ControlSessao().salvar(
        _perfil,
        usuario['id'] as int,
        usuario['nome'] as String,
        usuario['email'] as String,
      );
      if (!mounted) return;
      _erro = '';
      _controllerSenha.clear();
      if (_perfil == 'instituicao') {
        abreOutraTela(context, PainelInstituicao());
      } else {
        abreOutraTela(context, BoasVindas());
      }
    } catch (e) {
      developer.log('Erro no login: $e');
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao consultar o banco: $e';
      });
    }
  }
}

//cadastro.php
class CadastroPadrinho extends StatefulWidget {
  @override
  State<CadastroPadrinho> createState() => _CadastroPadrinhoState();
}

class _CadastroPadrinhoState extends State<CadastroPadrinho> {
  //um controller para cada input (aula 03)
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerTelefone = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  TextEditingController _controllerConfirmar = TextEditingController();
  TextEditingController _controllerCpf = TextEditingController();
  TextEditingController _controllerRenda = TextEditingController();
  TextEditingController _controllerEndereco = TextEditingController();
  ControlBanco _control = ControlBanco();
  List<String> _erros = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quero apadrinhar")),
      body: _body(),
    );
  }

  _body() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: <Widget>[
        bannerTopo("Faça parte dessa mudança",
            "Crie seu cadastro de padrinho", Icons.favorite_border),
        if (_erros.isNotEmpty)
          caixaAviso(_erros.map<String>((e) => "• $e").join("\n"), corVermelho,
              Icons.error_outline),
        cartaoSecao("Dados de acesso", Icons.lock_outline, <Widget>[
          campo("Nome *", "Digite seu nome", _controllerNome),
          campo("E-mail *", "Digite seu e-mail", _controllerEmail),
          campo("Telefone *", "Com DDD", _controllerTelefone),
          campoSenha("Senha *", "Mínimo de 8 caracteres", _controllerSenha),
          campoSenha("Confirmar senha *", "Repita a senha", _controllerConfirmar),
        ]),
        cartaoSecao("Dados do padrinho", Icons.badge_outlined, <Widget>[
          campo("CPF *", "Somente números", _controllerCpf),
          campo("Renda (R\$) *", "Ex.: 2500.00", _controllerRenda),
          campo("Endereço *", "Rua, número, cidade", _controllerEndereco),
        ]),
        botao("Criar cadastro", _salvar),
      ],
    );
  }

  Future<void> _salvar() async {
    String nome = _controllerNome.text.trim();
    String email = _controllerEmail.text.trim();
    String telefone = _controllerTelefone.text.trim();
    String senha = _controllerSenha.text;
    String confirmar = _controllerConfirmar.text;
    String cpf = _controllerCpf.text.trim();
    String endereco = _controllerEndereco.text.trim();
    double? renda = double.tryParse(_controllerRenda.text.trim().replaceAll(',', '.'));

    //mesmas validacoes do cadastro.php
    List<String> erros = [];
    if (nome.length < 3 || nome.length > 100) {
      erros.add('Informe um nome entre 3 e 100 caracteres.');
    }
    if (!emailValido(email) || email.length > 100) {
      erros.add('Informe um e-mail válido com até 100 caracteres.');
    }
    if (digitos(telefone).length < 10 || digitos(telefone).length > 11) {
      erros.add('Informe um telefone com DDD.');
    }
    if (digitos(cpf).length != 11) {
      erros.add('O CPF deve conter 11 dígitos.');
    }
    if (renda == null || renda < 0) {
      erros.add('Informe uma renda válida.');
    }
    if (endereco == '' || endereco.length > 200) {
      erros.add('Informe o endereço (até 200 caracteres).');
    }
    if (senha.length < 8) {
      erros.add('A senha deve ter pelo menos 8 caracteres.');
    }
    if (senha != confirmar) {
      erros.add('A confirmação da senha não corresponde.');
    }
    if (erros.isEmpty && await _control.emailExiste(email)) {
      erros.add('Este e-mail já está cadastrado.');
    }
    if (!mounted) return;
    if (erros.isNotEmpty) {
      setState(() {
        _erros = erros;
      });
      return;
    }

    try {
      Usuario usuario = Usuario(nome, email.toLowerCase(), senha, digitos(telefone));
      Padrinho padrinho = Padrinho(digitos(cpf), renda!, endereco);
      int id = await _control.cadastrarPadrinho(usuario, padrinho);
      await ControlSessao().salvar('padrinho', id, nome, email.toLowerCase());
      if (!mounted) return;
      abreTelaSubstituindo(context, BoasVindas());
    } catch (e) {
      developer.log('Erro ao salvar o padrinho: $e');
      if (!mounted) return;
      setState(() {
        _erros = ['Não foi possível salvar o cadastro: $e'];
      });
    }
  }
}

//boas-vindas.php (area do padrinho: apadrinhados, solicitacoes e criancas disponiveis)
class BoasVindas extends StatefulWidget {
  @override
  State<BoasVindas> createState() => _BoasVindasState();
}

class _BoasVindasState extends State<BoasVindas> {
  ControlBanco _control = ControlBanco();
  int _idPadrinho = 0;
  String _nome = '';
  int _aba = 0; //0 = disponiveis, 1 = solicitacoes, 2 = apadrinhados
  List<Map<String, dynamic>> _disponiveis = [];
  List<Map<String, dynamic>> _solicitacoes = [];
  String _mensagem = '';
  String _erro = '';

  //aula 14 - metodo start chamado quando a tela abre
  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    Map<String, dynamic>? sessao = await ControlSessao().ler();
    int idPadrinho = sessao == null ? 0 : sessao['id'] as int;
    String nome = sessao == null ? '' : sessao['nome'] as String;
    List<Map<String, dynamic>> disponiveis = await _control.listarCriancasDisponiveis();
    List<Map<String, dynamic>> solicitacoes =
        await _control.listarSolicitacoesPadrinho(idPadrinho);
    if (!mounted) return;
    setState(() {
      _idPadrinho = idPadrinho;
      _nome = nome;
      _disponiveis = disponiveis;
      _solicitacoes = solicitacoes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minha área"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _sair,
          ),
        ],
      ),
      body: _body(),
    );
  }

  _body() {
    String primeiroNome = _nome.trim().split(' ').first;
    //so as solicitacoes aprovadas viram "Meus apadrinhados"
    List<Map<String, dynamic>> apadrinhados =
        _solicitacoes.where((s) => s['status'] == 'Aprovado').toList();
    return ListView(
      padding: EdgeInsets.all(16),
      children: <Widget>[
        bannerTopo("Olá, $primeiroNome!",
            "Acompanhe suas solicitações e conheça crianças das instituições.",
            Icons.favorite),
        botao("Fazer doação", () {
          abreOutraTela(context, TelaDoacao());
        }),
        abas(
          [
            "Disponíveis (${_disponiveis.length})",
            "Solicitações (${_solicitacoes.length})",
            "Apadrinhados (${apadrinhados.length})",
          ],
          _aba,
          (int i) {
            setState(() {
              _aba = i;
            });
          },
        ),
        if (_mensagem != '') caixaAviso(_mensagem, corVerde, Icons.check_circle_outline),
        if (_erro != '') caixaAviso(_erro, corVermelho, Icons.error_outline),
        if (_aba == 0) ..._abaDisponiveis(),
        if (_aba == 1) ..._abaSolicitacoes(),
        if (_aba == 2) ..._abaApadrinhados(apadrinhados),
      ],
    );
  }

  List<Widget> _abaApadrinhados(List<Map<String, dynamic>> apadrinhados) {
    if (apadrinhados.isEmpty) {
      return [
        vazio(Icons.child_care,
            "Quando uma instituição aprovar sua solicitação, a criança aparecerá aqui."),
      ];
    }
    return apadrinhados.map<Widget>((item) {
      return cartaoSimples(<Widget>[
        cabecalhoCartao(Icons.child_care, corVerde, "${item['nome_apadrinhado']}",
            "${item['idade']} anos · ${item['sexo']}",
            status: "Aprovado"),
        linhaInfo(Icons.apartment, "${item['instituicao']}"),
        botao("Doar", () {
          abreOutraTela(context, TelaDoacao(solicitacaoId: item['id'] as int));
        }),
      ]);
    }).toList();
  }

  List<Widget> _abaSolicitacoes() {
    if (_solicitacoes.isEmpty) {
      return [vazio(Icons.inbox_outlined, "Você ainda não enviou solicitações.")];
    }
    return _solicitacoes.map<Widget>((item) {
      bool aprovado = item['status'] == 'Aprovado';
      //o nome so aparece depois da aprovacao
      String titulo =
          aprovado ? "${item['nome_apadrinhado']}" : "Criança #${item['crianca_id']}";
      return cartaoSimples(<Widget>[
        cabecalhoCartao(Icons.mail_outline, corStatus("${item['status']}"), titulo,
            "${item['idade']} anos · ${item['sexo']}",
            status: "${item['status']}"),
        linhaInfo(Icons.apartment, "${item['instituicao']}"),
        linhaInfo(Icons.schedule, "Enviada em ${formatarData(item['criado_em'] as String?)}"),
      ]);
    }).toList();
  }

  List<Widget> _abaDisponiveis() {
    if (_disponiveis.isEmpty) {
      return [vazio(Icons.search_off, "Nenhuma criança disponível no momento.")];
    }
    return _disponiveis.map<Widget>((item) {
      return cartaoSimples(<Widget>[
        cabecalhoCartao(Icons.child_friendly, corPrimaria, "${item['idade']} anos",
            "${item['sexo']}",
            status: "Disponível"),
        linhaInfo(Icons.apartment, "${item['instituicao']}"),
        linhaInfo(Icons.notes, "${item['observacoes_necessidades']}"),
        botao("Solicitar apadrinhamento", () {
          _solicitar(item['id'] as int);
        }),
      ]);
    }).toList();
  }

  Future<void> _solicitar(int idCrianca) async {
    String erro = await _control.solicitarApadrinhamento(_idPadrinho, idCrianca);
    if (!mounted) return;
    setState(() {
      _erro = erro;
      _mensagem = erro == ''
          ? 'Solicitação enviada! Ela ficará aguardando a análise da instituição responsável.'
          : '';
    });
    _carregar();
  }

  //sair.php
  Future<void> _sair() async {
    await ControlSessao().limpar();
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}

//doacao.php (so para apadrinhamentos aprovados)
class TelaDoacao extends StatefulWidget {
  //parametro do construtor (aula 06): ja deixa o apadrinhado escolhido
  final int? solicitacaoId;
  TelaDoacao({this.solicitacaoId});

  @override
  State<TelaDoacao> createState() => _TelaDoacaoState();
}

class _TelaDoacaoState extends State<TelaDoacao> {
  ControlBanco _control = ControlBanco();
  TextEditingController _controllerValor = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();
  int _idPadrinho = 0;
  List<Map<String, dynamic>> _vinculos = []; //apadrinhamentos aprovados
  int? _vinculoEscolhido; //valor do Radio
  String? _tipoEscolhido; //valor do Radio
  String _erro = '';
  bool _sucesso = false;
  final List<String> _tipos = [
    'Dinheiro',
    'Alimentos',
    'Roupas',
    'Higiene',
    'Material escolar',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    Map<String, dynamic>? sessao = await ControlSessao().ler();
    int idPadrinho = sessao == null ? 0 : sessao['id'] as int;
    List<Map<String, dynamic>> vinculos =
        await _control.listarVinculosAprovados(idPadrinho);
    if (!mounted) return;
    setState(() {
      _idPadrinho = idPadrinho;
      _vinculos = vinculos;
      _vinculoEscolhido = widget.solicitacaoId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrar doação")),
      body: _body(),
    );
  }

  _body() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Textview("Doar", corEscura)],
        ),
        caixaAviso(
            "As doações são destinadas à instituição responsável pelo apadrinhamento "
            "aprovado. Este registro não processa pagamentos nem comprova transferência.",
            corPrimaria,
            Icons.info_outline),
        if (_sucesso)
          caixaAviso("Doação registrada e enviada para a área de doações da instituição.",
              corVerde, Icons.check_circle_outline),
        if (_erro != '') caixaAviso(_erro, corVermelho, Icons.error_outline),
        if (_vinculos.isEmpty)
          vazio(Icons.volunteer_activism,
              "Você ainda não possui apadrinhamentos aprovados. A doação ficará disponível depois que a instituição aceitar uma solicitação.")
        else ...[
          cartaoSecao("Para quem?", Icons.child_care, <Widget>[
            //aula 06 - Radio: uma linha para cada opcao
            RadioGroup<int>(
              groupValue: _vinculoEscolhido,
              onChanged: (int? valor) {
                setState(() {
                  _vinculoEscolhido = valor;
                });
              },
              child: Column(
                children: _vinculos.map<Widget>((v) {
                  return opcaoRadio<int>(
                    "${v['nome_apadrinhado']} — ${v['idade']} anos · ${v['instituicao']}",
                    v['solicitacao_id'] as int,
                    () {
                      setState(() {
                        _vinculoEscolhido = v['solicitacao_id'] as int;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ]),
          cartaoSecao("Tipo de doação", Icons.category_outlined, <Widget>[
            RadioGroup<String>(
              groupValue: _tipoEscolhido,
              onChanged: (String? valor) {
                setState(() {
                  _tipoEscolhido = valor;
                });
              },
              child: Column(
                children: _tipos.map<Widget>((tipo) {
                  return opcaoRadio<String>(tipo, tipo, () {
                    setState(() {
                      _tipoEscolhido = tipo;
                    });
                  });
                }).toList(),
              ),
            ),
          ]),
          cartaoSecao("Detalhes", Icons.edit_note, <Widget>[
            //o valor so aparece quando o tipo for Dinheiro
            if (_tipoEscolhido == 'Dinheiro')
              campo("Valor (R\$) *", "0,00", _controllerValor),
            campo("Descrição da doação *", "Itens, quantidade ou detalhes",
                _controllerDescricao),
          ]),
          botao("Enviar registro de doação", _salvar),
        ],
      ],
    );
  }

  Future<void> _salvar() async {
    String descricao = _controllerDescricao.text.trim();
    double? valor;
    String? problema;
    if (_vinculoEscolhido == null) {
      problema = 'Selecione um apadrinhamento aprovado.';
    } else if (_tipoEscolhido == null) {
      problema = 'Selecione um tipo de doação válido.';
    } else if (_tipoEscolhido == 'Dinheiro') {
      valor = double.tryParse(_controllerValor.text.trim().replaceAll(',', '.'));
      if (valor == null || valor <= 0) {
        problema = 'Informe um valor válido para a doação em dinheiro.';
      }
    }
    if (problema == null && descricao == '') {
      problema = 'Descreva a doação.';
    }
    if (problema != null) {
      setState(() {
        _sucesso = false;
        _erro = problema!;
      });
      return;
    }

    String erro = await _control.registrarDoacao(
        _idPadrinho, _vinculoEscolhido!, _tipoEscolhido!, valor, descricao);
    if (!mounted) return;
    setState(() {
      _erro = erro;
      _sucesso = erro == '';
      if (erro == '') {
        _tipoEscolhido = null;
        _controllerValor.clear();
        _controllerDescricao.clear();
      }
    });
  }
}
