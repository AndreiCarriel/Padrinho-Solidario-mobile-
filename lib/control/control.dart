import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../model/modelos.dart';


class ControlBanco {
  static const String _nomeBase = 'padrinho_solidario_v3.db';
  static Database? _database;

  final List<String> tabelasAdmin = [
    'usuarios',
    'padrinho',
    'instituicao',
    'apadrinhado',
    'apadrinhamento',
    'solicitacoes_apadrinhamento',
    'doacoes',
  ];

  String _agora() {
    return DateTime.now().toString().substring(0, 19);
  }

  String _hoje() {
    return DateTime.now().toString().substring(0, 10);
  }

  Future<Database> _getDatabase() async {
    _database ??= await _abrirBanco();
    return _database!;
  }

  Future<Database> _abrirBanco() async {
    String caminho = await getDatabasesPath();
    return await openDatabase(
      '$caminho/$_nomeBase',
      version: 1,
      onCreate: _criarTabelas,
    );
  }

  Future<void> _criarTabelas(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL,
        telefone TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE padrinho (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cpf TEXT NOT NULL,
        renda REAL NOT NULL,
        endereco TEXT NOT NULL,
        id_usuario INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE instituicao (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cep TEXT NOT NULL,
        responsavel TEXT NOT NULL,
        necessidades TEXT NOT NULL,
        id_usuario INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE apadrinhado (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        idade INTEGER NOT NULL,
        sexo TEXT NOT NULL,
        observacoes_necessidades TEXT NOT NULL,
        status INTEGER NOT NULL,
        id_instituicao INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE apadrinhamento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data_inicio TEXT NOT NULL,
        data_fim TEXT,
        tipo_apadrinhamento TEXT NOT NULL,
        status TEXT NOT NULL,
        id_padrinho INTEGER NOT NULL,
        id_apadrinhado INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE solicitacoes_apadrinhamento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        padrinho_id INTEGER NOT NULL,
        crianca_id INTEGER NOT NULL,
        instituicao_id INTEGER NOT NULL,
        observacoes TEXT,
        status TEXT NOT NULL,
        criado_em TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE doacoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        padrinho_id INTEGER NOT NULL,
        id_apadrinhado INTEGER NOT NULL,
        instituicao_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        valor REAL,
        descricao TEXT NOT NULL,
        data_doacao TEXT NOT NULL,
        status TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE administradores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL
      )''');
    await _inserirDemonstrativos(db);
  }

  Future<void> _inserirDemonstrativos(Database db) async {
    List<List<String>> lares = [
      ['Lar Pequeno Príncipe', 'contato@larpequenoprincipe.org.br'],
      ['Abrigo Esperança', 'contato@abrigoesperanca.org.br'],
      ['Casa Acolhedora Sementes', 'contato@casasementes.org.br'],
    ];
    List<int> idsInstituicao = [];
    for (List<String> lar in lares) {
      int idUsuario = await db.insert('usuarios', {
        'nome': lar[0],
        'email': lar[1],
        'senha': 'demo1234',
        'telefone': '0000000000',
      });
      int idInstituicao = await db.insert('instituicao', {
        'cep': '',
        'responsavel': 'Responsável demonstrativo',
        'necessidades': 'Dados demonstrativos',
        'id_usuario': idUsuario,
      });
      idsInstituicao.add(idInstituicao);
    }

    List<Apadrinhado> criancas = [
      Apadrinhado('Miguel', 7, 'Masculino',
          'Necessita de apoio com materiais escolares e acompanhamento educacional.', 1, idsInstituicao[0]),
      Apadrinhado('Helena', 9, 'Feminino',
          'Precisa de roupas infantis, calçados e incentivo às atividades de leitura.', 1, idsInstituicao[1]),
      Apadrinhado('Davi', 5, 'Masculino',
          'Aguardando disponibilidade para novo apadrinhamento. Necessita de itens de higiene.', 0, idsInstituicao[2]),
      Apadrinhado('Alice', 11, 'Feminino',
          'Necessita de materiais para atividades artísticas e acompanhamento escolar.', 1, idsInstituicao[0]),
    ];
    for (Apadrinhado crianca in criancas) {
      await db.insert('apadrinhado', crianca.toMap());
    }
  }


  Future<Map<String, dynamic>> verificarBanco() async {
    try {
      Database db = await _getDatabase();
      int usuarios = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM usuarios')) ??
          0;
      List<Map<String, dynamic>> disponiveis = await listarCriancasDisponiveis();
      return {
        'ok': true,
        'texto':
            'Banco conectado · $usuarios usuários · ${disponiveis.length} crianças disponíveis',
      };
    } catch (e) {
      developer.log('Erro ao abrir o banco: $e');
      return {'ok': false, 'texto': 'Falha ao abrir o banco: $e'};
    }
  }


  Future<bool> emailExiste(String email) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> lista = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    return lista.isNotEmpty;
  }

  Future<int> cadastrarPadrinho(Usuario usuario, Padrinho padrinho) async {
    Database db = await _getDatabase();
    int idPadrinho = 0;
    await db.transaction((txn) async {
      int idUsuario = await txn.insert('usuarios', usuario.toMap());
      padrinho.idUsuario = idUsuario;
      idPadrinho = await txn.insert('padrinho', padrinho.toMap());
    });
    return idPadrinho;
  }

  Future<int> cadastrarInstituicao(
      Usuario usuario, Instituicao instituicao) async {
    Database db = await _getDatabase();
    int idInstituicao = 0;
    await db.transaction((txn) async {
      int idUsuario = await txn.insert('usuarios', usuario.toMap());
      instituicao.idUsuario = idUsuario;
      idInstituicao = await txn.insert('instituicao', instituicao.toMap());
    });
    return idInstituicao;
  }


  Future<Map<String, dynamic>?> login(
      String perfil, String email, String senha) async {
    Database db = await _getDatabase();
    String tabela = perfil == 'instituicao' ? 'instituicao' : 'padrinho';
    List<Map<String, dynamic>> lista = await db.rawQuery('''
      SELECT p.id AS id, u.nome AS nome, u.email AS email
      FROM $tabela p
      JOIN usuarios u ON u.id = p.id_usuario
      WHERE u.email = ? AND u.senha = ?
    ''', [email.toLowerCase(), senha]);
    if (lista.isEmpty) {
      return null;
    }
    return lista.first;
  }


  Future<List<Map<String, dynamic>>> listarCriancasDisponiveis() async {
    Database db = await _getDatabase();
    return await db.rawQuery('''
      SELECT a.id, a.idade, a.sexo, a.observacoes_necessidades, a.id_instituicao,
             u.nome AS instituicao
      FROM apadrinhado a
      JOIN instituicao i ON i.id = a.id_instituicao
      JOIN usuarios u ON u.id = i.id_usuario
      WHERE a.status = 1
        AND NOT EXISTS (SELECT 1 FROM solicitacoes_apadrinhamento sa
                        WHERE sa.crianca_id = a.id AND sa.status = 'Aprovado')
        AND NOT EXISTS (SELECT 1 FROM apadrinhamento ap
                        WHERE ap.id_apadrinhado = a.id AND ap.status = 'Ativo')
      ORDER BY a.id DESC
    ''');
  }

  Future<String> solicitarApadrinhamento(int idPadrinho, int idCrianca) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> crianca = await db.rawQuery('''
      SELECT a.id, a.id_instituicao, a.observacoes_necessidades
      FROM apadrinhado a
      WHERE a.id = ? AND a.status = 1
        AND NOT EXISTS (SELECT 1 FROM solicitacoes_apadrinhamento sa
                        WHERE sa.crianca_id = a.id AND sa.status = 'Aprovado')
        AND NOT EXISTS (SELECT 1 FROM apadrinhamento ap
                        WHERE ap.id_apadrinhado = a.id AND ap.status = 'Ativo')
    ''', [idCrianca]);
    if (crianca.isEmpty) {
      return 'Esta criança não está disponível para solicitação.';
    }
    List<Map<String, dynamic>> existente = await db.query(
      'solicitacoes_apadrinhamento',
      where: "padrinho_id = ? AND crianca_id = ? AND status IN ('Pendente','Aprovado')",
      whereArgs: [idPadrinho, idCrianca],
    );
    if (existente.isNotEmpty) {
      return 'Você já possui uma solicitação pendente ou um apadrinhamento aprovado para esta criança.';
    }
    await db.insert('solicitacoes_apadrinhamento', {
      'padrinho_id': idPadrinho,
      'crianca_id': idCrianca,
      'instituicao_id': crianca.first['id_instituicao'],
      'observacoes': crianca.first['observacoes_necessidades'],
      'status': 'Pendente',
      'criado_em': _agora(),
    });
    return '';
  }

  Future<List<Map<String, dynamic>>> listarSolicitacoesPadrinho(
      int idPadrinho) async {
    Database db = await _getDatabase();
    return await db.rawQuery('''
      SELECT s.id, s.status, s.criado_em, a.id AS crianca_id,
             CASE WHEN s.status = 'Aprovado' THEN a.nome ELSE NULL END AS nome_apadrinhado,
             a.idade, a.sexo, u.nome AS instituicao
      FROM solicitacoes_apadrinhamento s
      JOIN apadrinhado a ON a.id = s.crianca_id
      JOIN instituicao i ON i.id = s.instituicao_id
      JOIN usuarios u ON u.id = i.id_usuario
      WHERE s.padrinho_id = ?
      ORDER BY s.criado_em DESC
    ''', [idPadrinho]);
  }


  Future<List<Map<String, dynamic>>> listarVinculosAprovados(
      int idPadrinho) async {
    Database db = await _getDatabase();
    return await db.rawQuery('''
      SELECT s.id AS solicitacao_id, s.crianca_id, s.instituicao_id,
             a.nome AS nome_apadrinhado, a.idade, u.nome AS instituicao
      FROM solicitacoes_apadrinhamento s
      JOIN apadrinhado a ON a.id = s.crianca_id
      JOIN instituicao i ON i.id = s.instituicao_id
      JOIN usuarios u ON u.id = i.id_usuario
      WHERE s.padrinho_id = ? AND s.status = 'Aprovado'
      ORDER BY u.nome, a.idade
    ''', [idPadrinho]);
  }

  Future<String> registrarDoacao(int idPadrinho, int idSolicitacao,
      String tipo, double? valor, String descricao) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> vinculo = await db.query(
      'solicitacoes_apadrinhamento',
      where: "id = ? AND padrinho_id = ? AND status = 'Aprovado'",
      whereArgs: [idSolicitacao, idPadrinho],
    );
    if (vinculo.isEmpty) {
      return 'O vínculo selecionado não está aprovado ou não pertence à sua conta.';
    }
    Doacao doacao = Doacao(
      idPadrinho,
      vinculo.first['crianca_id'] as int,
      vinculo.first['instituicao_id'] as int,
      tipo,
      valor,
      descricao,
      _agora(),
    );
    await db.insert('doacoes', doacao.toMap());
    return '';
  }


  Future<List<Map<String, dynamic>>> listarInstituicoes() async {
    Database db = await _getDatabase();
    return await db.rawQuery('''
      SELECT i.id, u.nome, u.email, u.telefone, i.cep, i.responsavel, i.necessidades
      FROM instituicao i
      JOIN usuarios u ON u.id = i.id_usuario
      ORDER BY u.nome
    ''');
  }

  Future<Map<String, dynamic>?> buscarInstituicao(int id) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> lista = await db.rawQuery('''
      SELECT i.id, u.nome, u.email, u.telefone, i.cep, i.responsavel, i.necessidades
      FROM instituicao i
      JOIN usuarios u ON u.id = i.id_usuario
      WHERE i.id = ?
    ''', [id]);
    if (lista.isEmpty) {
      return null;
    }
    return lista.first;
  }


  Future<List<Map<String, dynamic>>> listarSolicitacoesInstituicao(
      int idInstituicao) async {
    Database db = await _getDatabase();
    return await db.rawQuery('''
      SELECT s.id, s.status, s.criado_em, a.id AS crianca_id,
             a.nome AS nome_apadrinhado, a.idade, a.sexo,
             u.nome AS padrinho_nome, u.email AS padrinho_email
      FROM solicitacoes_apadrinhamento s
      JOIN apadrinhado a ON a.id = s.crianca_id
      JOIN padrinho p ON p.id = s.padrinho_id
      JOIN usuarios u ON u.id = p.id_usuario
      WHERE s.instituicao_id = ?
      ORDER BY s.criado_em DESC
    ''', [idInstituicao]);
  }

  Future<List<Map<String, dynamic>>> listarCriancasInstituicao(
      int idInstituicao) async {
    Database db = await _getDatabase();
    return await db.rawQuery('''
      SELECT a.id, a.nome, a.idade, a.sexo, a.status,
             up.nome AS padrinho_nome, up.email AS padrinho_email,
             ap.id AS apadrinhamento_id
      FROM apadrinhado a
      LEFT JOIN (
        SELECT id_apadrinhado, MAX(id) AS apadrinhamento_id
        FROM apadrinhamento
        WHERE status = 'Ativo'
        GROUP BY id_apadrinhado
      ) vinculo ON vinculo.id_apadrinhado = a.id
      LEFT JOIN apadrinhamento ap ON ap.id = vinculo.apadrinhamento_id
      LEFT JOIN padrinho p ON p.id = ap.id_padrinho
      LEFT JOIN usuarios up ON up.id = p.id_usuario
      WHERE a.id_instituicao = ?
      ORDER BY a.id DESC
    ''', [idInstituicao]);
  }

  Future<List<Map<String, dynamic>>> listarDoacoesInstituicao(
      int idInstituicao) async {
    Database db = await _getDatabase();
    return await db.rawQuery('''
      SELECT d.id, d.tipo, d.valor, d.descricao, d.status, d.data_doacao,
             u.nome AS padrinho_nome, a.nome AS crianca_nome
      FROM doacoes d
      JOIN padrinho p ON p.id = d.padrinho_id
      JOIN usuarios u ON u.id = p.id_usuario
      LEFT JOIN apadrinhado a ON a.id = d.id_apadrinhado
      WHERE d.instituicao_id = ?
      ORDER BY d.data_doacao DESC
    ''', [idInstituicao]);
  }

  Future<String> aprovarSolicitacao(int idSolicitacao, int idInstituicao) async {
    Database db = await _getDatabase();
    try {
      await db.transaction((txn) async {
        List<Map<String, dynamic>> pedido = await txn.query(
          'solicitacoes_apadrinhamento',
          where: "id = ? AND instituicao_id = ? AND status = 'Pendente'",
          whereArgs: [idSolicitacao, idInstituicao],
        );
        if (pedido.isEmpty) {
          throw Exception('Solicitação não encontrada ou já processada.');
        }
        int idCrianca = pedido.first['crianca_id'] as int;
        int idPadrinho = pedido.first['padrinho_id'] as int;

        List<Map<String, dynamic>> crianca = await txn.query(
          'apadrinhado',
          where: 'id = ? AND id_instituicao = ?',
          whereArgs: [idCrianca, idInstituicao],
        );
        if (crianca.isEmpty) {
          throw Exception('A criança não pertence a esta instituição.');
        }
        List<Map<String, dynamic>> aprovada = await txn.query(
          'solicitacoes_apadrinhamento',
          where: "crianca_id = ? AND status = 'Aprovado'",
          whereArgs: [idCrianca],
        );
        if (aprovada.isNotEmpty) {
          throw Exception('Esta criança já possui um padrinho ou madrinha aprovado.');
        }
        List<Map<String, dynamic>> ativo = await txn.query(
          'apadrinhamento',
          where: "id_apadrinhado = ? AND status = 'Ativo'",
          whereArgs: [idCrianca],
        );
        if (ativo.isNotEmpty) {
          throw Exception('Esta criança já possui um apadrinhamento ativo.');
        }

        await txn.insert('apadrinhamento', {
          'data_inicio': _hoje(),
          'data_fim': null,
          'tipo_apadrinhamento': 'Afetivo',
          'status': 'Ativo',
          'id_padrinho': idPadrinho,
          'id_apadrinhado': idCrianca,
        });
        await txn.update(
          'solicitacoes_apadrinhamento',
          {'status': 'Aprovado'},
          where: 'id = ?',
          whereArgs: [idSolicitacao],
        );
        await txn.update(
          'solicitacoes_apadrinhamento',
          {'status': 'Recusado'},
          where: "crianca_id = ? AND id <> ? AND status = 'Pendente'",
          whereArgs: [idCrianca, idSolicitacao],
        );
      });
      return '';
    } catch (e) {
      developer.log('Erro ao aprovar a solicitacao: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String> recusarSolicitacao(int idSolicitacao, int idInstituicao) async {
    Database db = await _getDatabase();
    int linhas = await db.update(
      'solicitacoes_apadrinhamento',
      {'status': 'Recusado'},
      where: "id = ? AND instituicao_id = ? AND status = 'Pendente'",
      whereArgs: [idSolicitacao, idInstituicao],
    );
    if (linhas == 0) {
      return 'Não foi possível atualizar a solicitação.';
    }
    return '';
  }

  Future<String> cancelarApadrinhamento(
      int idApadrinhamento, int idInstituicao) async {
    Database db = await _getDatabase();
    try {
      await db.transaction((txn) async {
        List<Map<String, dynamic>> vinculo = await txn.rawQuery('''
          SELECT ap.id, ap.id_apadrinhado
          FROM apadrinhamento ap
          JOIN apadrinhado a ON a.id = ap.id_apadrinhado
          WHERE ap.id = ? AND a.id_instituicao = ? AND ap.status = 'Ativo'
        ''', [idApadrinhamento, idInstituicao]);
        if (vinculo.isEmpty) {
          throw Exception('Apadrinhamento ativo não encontrado para esta instituição.');
        }
        await txn.update(
          'apadrinhamento',
          {'status': 'Cancelado', 'data_fim': _hoje()},
          where: 'id = ?',
          whereArgs: [idApadrinhamento],
        );
        await txn.update(
          'solicitacoes_apadrinhamento',
          {'status': 'Cancelado'},
          where: "crianca_id = ? AND status = 'Aprovado'",
          whereArgs: [vinculo.first['id_apadrinhado']],
        );
      });
      return '';
    } catch (e) {
      developer.log('Erro ao cancelar o apadrinhamento: $e');
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> cadastrarApadrinhado(Apadrinhado crianca) async {
    Database db = await _getDatabase();
    await db.insert('apadrinhado', crianca.toMap());
  }

  Future<String> alternarStatusCrianca(
      int idCrianca, int novoStatus, int idInstituicao) async {
    Database db = await _getDatabase();
    int linhas = await db.update(
      'apadrinhado',
      {'status': novoStatus},
      where: 'id = ? AND id_instituicao = ?',
      whereArgs: [idCrianca, idInstituicao],
    );
    if (linhas == 0) {
      return 'Criança não encontrada para esta instituição.';
    }
    return '';
  }

  Future<String> atualizarStatusDoacao(
      int idDoacao, int idInstituicao, String status) async {
    Database db = await _getDatabase();
    int linhas = await db.update(
      'doacoes',
      {'status': status},
      where: 'id = ? AND instituicao_id = ?',
      whereArgs: [idDoacao, idInstituicao],
    );
    if (linhas == 0) {
      return 'Doação não encontrada para esta instituição.';
    }
    return '';
  }


  Future<bool> adminExiste() async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> lista = await db.query('administradores');
    return lista.isNotEmpty;
  }

  Future<void> criarAdmin(String nome, String email, String senha) async {
    Database db = await _getDatabase();
    await db.insert('administradores', {
      'nome': nome,
      'email': email.toLowerCase(),
      'senha': senha,
    });
  }

  Future<Map<String, dynamic>?> loginAdmin(String email, String senha) async {
    Database db = await _getDatabase();
    List<Map<String, dynamic>> lista = await db.query(
      'administradores',
      where: 'email = ? AND senha = ?',
      whereArgs: [email.toLowerCase(), senha],
    );
    if (lista.isEmpty) {
      return null;
    }
    return lista.first;
  }

  Future<List<Map<String, dynamic>>> listarTabela(String tabela) async {
    if (!tabelasAdmin.contains(tabela)) {
      return [];
    }
    Database db = await _getDatabase();
    String colunas = tabela == 'usuarios' ? 'id, nome, email, telefone' : '*';
    return await db.rawQuery('SELECT $colunas FROM $tabela ORDER BY id DESC');
  }

  Future<void> excluir(String tabela, int id) async {
    if (!tabelasAdmin.contains(tabela)) {
      return;
    }
    Database db = await _getDatabase();
    await db.delete(tabela, where: 'id = ?', whereArgs: [id]);
  }
}

class ControlSessao {
  Future<void> salvar(String perfil, int id, String nome, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('perfil', perfil); //padrinho ou instituicao
    await prefs.setInt('id', id);
    await prefs.setString('nome', nome);
    await prefs.setString('email', email);
  }

  Future<Map<String, dynamic>?> ler() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? perfil = prefs.getString('perfil');
    if (perfil == null) {
      return null;
    }
    return {
      'perfil': perfil,
      'id': prefs.getInt('id') ?? 0,
      'nome': prefs.getString('nome') ?? '',
      'email': prefs.getString('email') ?? '',
    };
  }

  Future<void> limpar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class CepService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://viacep.com.br/ws/',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  Future<Cep?> buscarCep(String cep) async {
    try {
      final response = await _dio.get('$cep/json/');
      if (response.statusCode == 200) {
        if (response.data['erro'] == true) {
          return null;
        }
        return Cep.fromJson(response.data);
      }
    } catch (e) {
      developer.log('Erro ao buscar o CEP: $e');
    }
    return null;
  }
}

String digitos(String valor) {
  return valor.replaceAll(RegExp(r'\D'), '');
}

bool emailValido(String email) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
}

String formatarTelefone(String telefone) {
  String n = digitos(telefone);
  if (n.length == 11) {
    return "(${n.substring(0, 2)}) ${n.substring(2, 3)} ${n.substring(3, 7)}-${n.substring(7)}";
  }
  if (n.length == 10) {
    return "(${n.substring(0, 2)}) ${n.substring(2, 6)}-${n.substring(6)}";
  }
  return telefone;
}

String formatarData(String? valor) {
  if (valor == null || valor.length < 16) {
    return valor ?? '';
  }
  return "${valor.substring(8, 10)}/${valor.substring(5, 7)}/${valor.substring(0, 4)} ${valor.substring(11, 16)}";
}

String formatarValor(dynamic valor) {
  if (valor == null) {
    return '—';
  }
  return "R\$ ${(valor as num).toStringAsFixed(2).replaceAll('.', ',')}";
}

void abreOutraTela(BuildContext ctx, Widget page) {
  Navigator.push(ctx, MaterialPageRoute(builder: (context) => page));
}

void abreTelaSubstituindo(BuildContext ctx, Widget page) {
  Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (context) => page));
}
