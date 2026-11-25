class Usuario {
  String nome;
  String email;
  String senha;
  String telefone;

  Usuario(this.nome, this.email, this.senha, this.telefone);

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'senha': senha,
      'telefone': telefone,
    };
  }
}

class Padrinho {
  String cpf;
  double renda;
  String endereco;
  int? idUsuario; 

  Padrinho(this.cpf, this.renda, this.endereco);

  Map<String, dynamic> toMap() {
    return {
      'cpf': cpf,
      'renda': renda,
      'endereco': endereco,
      'id_usuario': idUsuario,
    };
  }
}

class Instituicao {
  String cep;
  String responsavel;
  String necessidades;
  int? idUsuario; 

  Instituicao(this.cep, this.responsavel, this.necessidades);

  Map<String, dynamic> toMap() {
    return {
      'cep': cep,
      'responsavel': responsavel,
      'necessidades': necessidades,
      'id_usuario': idUsuario,
    };
  }
}

class Apadrinhado {
  String nome;
  int idade;
  String sexo;
  String observacoes;
  int status;
  int idInstituicao;

  Apadrinhado(this.nome, this.idade, this.sexo, this.observacoes, this.status,
      this.idInstituicao);

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'idade': idade,
      'sexo': sexo,
      'observacoes_necessidades': observacoes,
      'status': status,
      'id_instituicao': idInstituicao,
    };
  }
}

class Doacao {
  int idPadrinho;
  int idApadrinhado;
  int idInstituicao;
  String tipo;
  double? valor; 
  String descricao;
  String dataDoacao;
  String status; 

  Doacao(this.idPadrinho, this.idApadrinhado, this.idInstituicao, this.tipo,
      this.valor, this.descricao, this.dataDoacao,
      {this.status = 'Informada'});

  Map<String, dynamic> toMap() {
    return {
      'padrinho_id': idPadrinho,
      'id_apadrinhado': idApadrinhado,
      'instituicao_id': idInstituicao,
      'tipo': tipo,
      'valor': valor,
      'descricao': descricao,
      'data_doacao': dataDoacao,
      'status': status,
    };
  }
}

class Cep {
  final String? cep;
  final String? logradouro;
  final String? complemento;
  final String? bairro;
  final String? localidade;
  final String? uf;

  Cep({this.cep, this.logradouro, this.complemento, this.bairro,
      this.localidade, this.uf});

  factory Cep.fromJson(Map<String, dynamic> json) {
    return Cep(
      cep: json['cep'],
      logradouro: json['logradouro'],
      complemento: json['complemento'],
      bairro: json['bairro'],
      localidade: json['localidade'],
      uf: json['uf'],
    );
  }
}
