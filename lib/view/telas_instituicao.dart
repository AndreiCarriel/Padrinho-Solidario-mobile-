import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../control/control.dart';
import '../model/modelos.dart';
import 'visual.dart';

//VIEW: Cadastro da instituicao e painel da instituicao

//cadastro-instituicao.php (o botao Buscar CEP usa o web service da aula 13)
class CadastroInstituicao extends StatefulWidget {
  @override
  State<CadastroInstituicao> createState() => _CadastroInstituicaoState();
}

class _CadastroInstituicaoState extends State<CadastroInstituicao> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerTelefone = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  TextEditingController _controllerConfirmar = TextEditingController();
  TextEditingController _controllerCep = TextEditingController();
  TextEditingController _controllerResponsavel = TextEditingController();
  TextEditingController _controllerNecessidades = TextEditingController();
  ControlBanco _control = ControlBanco();
  CepService _cepService = CepService();
  String _endereco = ''; //resultado da busca do CEP
  List<String> _erros = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastrar instituição")),
      body: _body(),
    );
  }

  _body() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: <Widget>[
        bannerTopo("Receba apoio de padrinhos",
            "Cadastre sua instituição na plataforma", Icons.home_work_outlined),
        if (_erros.isNotEmpty)
          caixaAviso(_erros.map<String>((e) => "• $e").join("\n"), corVermelho,
              Icons.error_outline),
        cartaoSecao("Dados de acesso", Icons.lock_outline, <Widget>[
          campo("Nome da instituição *", "Digite o nome", _controllerNome),
          campo("E-mail *", "Digite o e-mail", _controllerEmail),
          campo("Telefone *", "Com DDD", _controllerTelefone),
          campoSenha("Senha *", "Mínimo de 8 caracteres", _controllerSenha),
          campoSenha("Confirmar senha *", "Repita a senha", _controllerConfirmar),
        ]),
        cartaoSecao("Dados da instituição", Icons.apartment, <Widget>[
          campo("CEP *", "Somente números", _controllerCep),
          botao("Buscar CEP", _buscarCep),
          if (_endereco != '') linhaInfo(Icons.place_outlined, _endereco),
          campo("Responsável *", "Nome do responsável", _controllerResponsavel),
          campo("Necessidades *", "O que a instituição precisa",
              _controllerNecessidades),
        ]),
        botao("Criar cadastro", _salvar),
      ],
    );
  }

  Future<void> _buscarCep() async {
    String cep = digitos(_controllerCep.text);
    if (cep.length != 8) {
      setState(() {
        _endereco = 'Informe um CEP com 8 dígitos.';
      });
      return;
    }
    Cep? resultado = await _cepService.buscarCep(cep);
    if (!mounted) return;
    setState(() {
      if (resultado == null) {
        _endereco = 'CEP não encontrado.';
      } else {
        _endereco =
            "${resultado.logradouro}, ${resultado.bairro} - ${resultado.localidade}/${resultado.uf}";
      }
    });
  }

  Future<void> _salvar() async {
    String nome = _controllerNome.text.trim();
    String email = _controllerEmail.text.trim();
    String telefone = _controllerTelefone.text.trim();
    String senha = _controllerSenha.text;
    String confirmar = _controllerConfirmar.text;
    String cep = digitos(_controllerCep.text);
    String responsavel = _controllerResponsavel.text.trim();
    String necessidades = _controllerNecessidades.text.trim();

    List<String> erros = [];
    if (nome.length < 3 || nome.length > 100) {
      erros.add('Informe o nome da instituição (3 a 100 caracteres).');
    }
    if (!emailValido(email) || email.length > 100) {
      erros.add('Informe um e-mail válido com até 100 caracteres.');
    }
    if (digitos(telefone).length < 10 || digitos(telefone).length > 11) {
      erros.add('Informe um telefone com DDD.');
    }
    if (cep.length != 8) {
      erros.add('O CEP deve conter 8 dígitos.');
    }
    if (responsavel.length < 3 || responsavel.length > 100) {
      erros.add('Informe o responsável (3 a 100 caracteres).');
    }
    if (necessidades == '') {
      erros.add('Descreva as necessidades da instituição.');
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
      Instituicao instituicao = Instituicao(cep, responsavel, necessidades);
      int id = await _control.cadastrarInstituicao(usuario, instituicao);
      await ControlSessao().salvar('instituicao', id, nome, email.toLowerCase());
      if (!mounted) return;
      abreTelaSubstituindo(context, PainelInstituicao());
    } catch (e) {
      developer.log('Erro ao salvar a instituicao: $e');
      if (!mounted) return;
      setState(() {
        _erros = ['Não foi possível salvar o cadastro: $e'];
      });
    }
  }
}

//painel-instituicao.php
class PainelInstituicao extends StatefulWidget {
  @override
  State<PainelInstituicao> createState() => _PainelInstituicaoState();
}

class _PainelInstituicaoState extends State<PainelInstituicao> {
  ControlBanco _control = ControlBanco();
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerIdade = TextEditingController();
  TextEditingController _controllerObs = TextEditingController();
  int _idInstituicao = 0;
  Map<String, dynamic>? _dados;
  List<Map<String, dynamic>> _solicitacoes = [];
  List<Map<String, dynamic>> _criancas = [];
  List<Map<String, dynamic>> _doacoes = [];
  int _aba = 0; //0 pedidos, 1 criancas, 2 doacoes, 3 dados
  String _filtro = 'todas'; //valor do Radio: todas, disponiveis, apadrinhadas, inativas
  String _sexo = 'Feminino'; //valor do Radio no cadastro da crianca
  String _mensagem = '';
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    Map<String, dynamic>? sessao = await ControlSessao().ler();
    int id = sessao == null ? 0 : sessao['id'] as int;
    Map<String, dynamic>? dados = await _control.buscarInstituicao(id);
    List<Map<String, dynamic>> solicitacoes =
        await _control.listarSolicitacoesInstituicao(id);
    List<Map<String, dynamic>> criancas = await _control.listarCriancasInstituicao(id);
    List<Map<String, dynamic>> doacoes = await _control.listarDoacoesInstituicao(id);
    if (!mounted) return;
    setState(() {
      _idInstituicao = id;
      _dados = dados;
      _solicitacoes = solicitacoes;
      _criancas = criancas;
      _doacoes = doacoes;
    });
  }

  //executa uma acao do control, mostra a mensagem e recarrega as listas
  Future<void> _executar(Future<String> acao, String sucesso) async {
    String erro = await acao;
    if (!mounted) return;
    setState(() {
      _erro = erro;
      _mensagem = erro == '' ? sucesso : '';
    });
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel da instituição"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.logout), onPressed: _sair),
        ],
      ),
      body: _body(),
    );
  }

  _body() {
    if (_dados == null) {
      return ListView(
        padding: EdgeInsets.all(16),
        children: <Widget>[vazio(Icons.hourglass_empty, "Carregando...")],
      );
    }
    int pendentes = _solicitacoes.where((s) => s['status'] == 'Pendente').length;
    return ListView(
      padding: EdgeInsets.all(16),
      children: <Widget>[
        bannerTopo("${_dados!['nome']}", "Responsável: ${_dados!['responsavel']}",
            Icons.apartment),
        abas(
          [
            "Pedidos ($pendentes)",
            "Crianças (${_criancas.length})",
            "Doações (${_doacoes.length})",
            "Dados",
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
        if (_aba == 0) ..._abaPedidos(),
        if (_aba == 1) ..._abaCriancas(),
        if (_aba == 2) ..._abaDoacoes(),
        if (_aba == 3) ..._abaDados(),
      ],
    );
  }

  List<Widget> _abaPedidos() {
    if (_solicitacoes.isEmpty) {
      return [vazio(Icons.inbox_outlined, "Nenhuma solicitação recebida ainda.")];
    }
    return _solicitacoes.map<Widget>((s) {
      String status = "${s['status']}";
      return cartaoSimples(<Widget>[
        cabecalhoCartao(Icons.mail_outline, corStatus(status), "${s['nome_apadrinhado']}",
            "${s['idade']} anos · ${s['sexo']}",
            status: status),
        linhaInfo(Icons.person_outline, "${s['padrinho_nome']} (${s['padrinho_email']})"),
        linhaInfo(Icons.schedule, "Enviada em ${formatarData(s['criado_em'] as String?)}"),
        if (status == 'Pendente')
          botao("Aprovar", () {
            _executar(_control.aprovarSolicitacao(s['id'] as int, _idInstituicao),
                'Solicitação aprovada. O apadrinhamento está ativo.');
          }),
        if (status == 'Pendente')
          botao("Recusar", () {
            _executar(_control.recusarSolicitacao(s['id'] as int, _idInstituicao),
                'Solicitação recusada.');
          }),
      ]);
    }).toList();
  }

  List<Widget> _abaCriancas() {
    //filtro simples com Radio (aula 06)
    List<Map<String, dynamic>> lista = _criancas.where((c) {
      bool ativa = c['status'] == 1;
      bool apadrinhada = c['apadrinhamento_id'] != null;
      if (_filtro == 'disponiveis') return ativa && !apadrinhada;
      if (_filtro == 'apadrinhadas') return apadrinhada;
      if (_filtro == 'inativas') return !ativa;
      return true;
    }).toList();

    return [
      cartaoSecao("Cadastrar criança", Icons.add_circle_outline, <Widget>[
        campo("Nome *", "Nome da criança", _controllerNome),
        campo("Idade *", "0 a 17", _controllerIdade),
        Container(
          margin: EdgeInsets.only(top: 8),
          child: RadioGroup<String>(
            groupValue: _sexo,
            onChanged: (String? valor) {
              setState(() {
                _sexo = valor ?? 'Feminino';
              });
            },
            child: Row(
              children: <Widget>[
                Expanded(
                  child: opcaoRadio<String>("Feminino", 'Feminino', () {
                    setState(() {
                      _sexo = 'Feminino';
                    });
                  }),
                ),
                Expanded(
                  child: opcaoRadio<String>("Masculino", 'Masculino', () {
                    setState(() {
                      _sexo = 'Masculino';
                    });
                  }),
                ),
              ],
            ),
          ),
        ),
        campo("Observações / necessidades *", "Saúde, estudos, interesses",
            _controllerObs),
        botao("Cadastrar criança", _cadastrarCrianca),
      ]),
      cartaoSecao("Filtrar", Icons.filter_list, <Widget>[
        RadioGroup<String>(
          groupValue: _filtro,
          onChanged: (String? valor) {
            setState(() {
              _filtro = valor ?? 'todas';
            });
          },
          child: Column(
            children: <Widget>[
              opcaoRadio<String>("Todas", 'todas', () {
                setState(() {
                  _filtro = 'todas';
                });
              }),
              opcaoRadio<String>("Disponíveis", 'disponiveis', () {
                setState(() {
                  _filtro = 'disponiveis';
                });
              }),
              opcaoRadio<String>("Apadrinhadas", 'apadrinhadas', () {
                setState(() {
                  _filtro = 'apadrinhadas';
                });
              }),
              opcaoRadio<String>("Inativas", 'inativas', () {
                setState(() {
                  _filtro = 'inativas';
                });
              }),
            ],
          ),
        ),
      ]),
      if (lista.isEmpty) vazio(Icons.child_care, "Nenhuma criança neste filtro."),
      ...lista.map<Widget>((c) {
        bool ativa = c['status'] == 1;
        bool apadrinhada = c['apadrinhamento_id'] != null;
        String situacao = !ativa ? 'Inativa' : (apadrinhada ? 'Apadrinhada' : 'Disponível');
        return cartaoSimples(<Widget>[
          cabecalhoCartao(Icons.child_care, corStatus(situacao), "${c['nome']}",
              "${c['idade']} anos · ${c['sexo']}",
              status: situacao),
          if (apadrinhada)
            linhaInfo(Icons.favorite_border,
                "Padrinho: ${c['padrinho_nome']} (${c['padrinho_email']})"),
          botao(ativa ? "Inativar" : "Ativar", () {
            _executar(
                _control.alternarStatusCrianca(
                    c['id'] as int, ativa ? 0 : 1, _idInstituicao),
                ativa ? 'Criança inativada.' : 'Criança ativada.');
          }),
          if (apadrinhada)
            botao("Cancelar apadrinhamento", () {
              _executar(
                  _control.cancelarApadrinhamento(
                      c['apadrinhamento_id'] as int, _idInstituicao),
                  'Apadrinhamento cancelado.');
            }),
        ]);
      }),
    ];
  }

  Future<void> _cadastrarCrianca() async {
    String nome = _controllerNome.text.trim();
    int? idade = int.tryParse(_controllerIdade.text.trim());
    String obs = _controllerObs.text.trim();
    String? problema;
    if (nome.length < 2) {
      problema = 'Informe o nome da criança.';
    } else if (idade == null || idade < 0 || idade > 17) {
      problema = 'Informe uma idade entre 0 e 17 anos.';
    } else if (obs == '') {
      problema = 'Descreva as observações da criança.';
    }
    if (problema != null) {
      setState(() {
        _mensagem = '';
        _erro = problema!;
      });
      return;
    }
    await _control.cadastrarApadrinhado(
        Apadrinhado(nome, idade!, _sexo, obs, 1, _idInstituicao));
    if (!mounted) return;
    _controllerNome.clear();
    _controllerIdade.clear();
    _controllerObs.clear();
    setState(() {
      _erro = '';
      _mensagem = 'Criança cadastrada com sucesso.';
    });
    _carregar();
  }

  List<Widget> _abaDoacoes() {
    if (_doacoes.isEmpty) {
      return [vazio(Icons.volunteer_activism, "Nenhuma doação registrada ainda.")];
    }
    return _doacoes.map<Widget>((d) {
      String status = "${d['status']}";
      bool dinheiro = d['tipo'] == 'Dinheiro';
      return cartaoSimples(<Widget>[
        cabecalhoCartao(Icons.volunteer_activism, corStatus(status),
            dinheiro ? "${d['tipo']} · ${formatarValor(d['valor'])}" : "${d['tipo']}",
            "De ${d['padrinho_nome']} para ${d['crianca_nome']}",
            status: status),
        linhaInfo(Icons.notes, "${d['descricao']}"),
        linhaInfo(Icons.schedule, formatarData(d['data_doacao'] as String?)),
        if (status == 'Informada')
          botao("Marcar como recebida", () {
            _executar(
                _control.atualizarStatusDoacao(d['id'] as int, _idInstituicao, 'Recebida'),
                'Doação marcada como recebida.');
          }),
        if (status == 'Informada')
          botao("Não recebida", () {
            _executar(
                _control.atualizarStatusDoacao(
                    d['id'] as int, _idInstituicao, 'Não Recebida'),
                'Doação marcada como não recebida.');
          }),
      ]);
    }).toList();
  }

  List<Widget> _abaDados() {
    return [
      cartaoSecao("Dados cadastrados", Icons.badge_outlined, <Widget>[
        rotuloValor("E-mail", "${_dados!['email']}"),
        rotuloValor("Telefone", formatarTelefone(_dados!['telefone'] as String)),
        rotuloValor("CEP", "${_dados!['cep']}"),
        rotuloValor("Necessidades", "${_dados!['necessidades']}"),
      ]),
    ];
  }

  Future<void> _sair() async {
    await ControlSessao().limpar();
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
