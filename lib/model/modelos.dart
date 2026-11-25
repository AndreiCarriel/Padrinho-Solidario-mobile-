//MODEL: classes que representam as tabelas (aula 14) e o CEP (aula 13)

//tabela usuarios
class Usuario {
  //atributos da classe
  String nome;
  String email;
  String senha;
  String telefone;

  //construtor da classe
  Usuario(this.nome, this.email, this.senha, this.telefone);

  //converte o objeto em map para gravar no SQLite
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'senha': senha,
      'telefone': telefone,
    };
  }
}

//tabela padrinho
class Padrinho {
  String cpf;
  double renda;
  String endereco;
  int? idUsuario; //preenchido depois que o usuario for gravado

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

//tabela instituicao
class Instituicao {
  String cep;
  String responsavel;
  String necessidades;
  int? idUsuario; //preenchido depois que o usuario for gravado

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

//tabela apadrinhado (a crianca). status: 1 = ativo e 0 = inativo
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

//tabela doacoes
class Doacao {
  int idPadrinho;
  int idApadrinhado;
  int idInstituicao;
  String tipo;
  double? valor; //so existe quando o tipo for Dinheiro
  String descricao;
  String dataDoacao;
  String status; //Informada, Recebida ou Não Recebida

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

//modelo do CEP (aula 13 - consumo de API)
class Cep {
  //os atributos final podem ser nulos, mas nao podem ser modificados
  final String? cep;
  final String? logradouro;
  final String? complemento;
  final String? bairro;
  final String? localidade;
  final String? uf;

  //construtor
  Cep({this.cep, this.logradouro, this.complemento, this.bairro,
      this.localidade, this.uf});

  //factory: usado porque os dados vem de fora (json), cada atributo do json
  //e passado para o nosso objeto
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
