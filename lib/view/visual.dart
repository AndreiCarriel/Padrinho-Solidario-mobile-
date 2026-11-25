import 'package:flutter/material.dart';
import '../widgets/buttons.dart';
import '../widgets/input.dart';

//VISUAL: cores e funcoes de apoio para deixar todas as telas com o mesmo estilo.
//Sao metodos que retornam widgets (como na aula 03), sem criar classes novas.
//Mudou uma cor aqui? Muda no app inteiro.

// ---------------- CORES (mesma paleta do site em PHP) ----------------
const Color corPrimaria = Color(0xFFB95F3E);
const Color corEscura = Color(0xFF5B2A1A);
const Color corFundo = Color(0xFFFBF3EC);
const Color corTexto = Color(0xFF3A2A22);
const Color corSuave = Color(0xFF8C7A70);
const Color corVerde = Color(0xFF2E7D5B);
const Color corAmarelo = Color(0xFFC77B12);
const Color corVermelho = Color(0xFFB3382C);

// ---------------- ESTILOS DE TEXTO ----------------
const TextStyle estiloTitulo =
    TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: corTexto);
const TextStyle estiloSecao =
    TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: corTexto);
const TextStyle estiloNormal = TextStyle(fontSize: 14, color: corTexto);
const TextStyle estiloSuave = TextStyle(fontSize: 12, color: corSuave);

// ---------------- DECORACOES ----------------

//cartao branco com cantos redondos e sombra suave
BoxDecoration decoCartao() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Color(0x1F5B2A1A),
        blurRadius: 14,
        offset: Offset(0, 6),
      ),
    ],
  );
}

//cor do selo de status (Pendente, Aprovado, etc.)
Color corStatus(String status) {
  if (status == 'Aprovado' || status == 'Recebida' || status == 'Ativo' ||
      status == 'Ativa' || status == 'Disponível') {
    return corVerde;
  }
  if (status == 'Recusado' || status == 'Cancelado' ||
      status == 'Não Recebida' || status == 'Inativada') {
    return corVermelho;
  }
  return corAmarelo; //Pendente e Informada
}

// ---------------- PEQUENOS BLOCOS ----------------

//espaco em branco entre os widgets
Widget espaco(double largura, double altura) {
  return Container(width: largura, height: altura);
}

//selo colorido com o status
Widget chipStatus(String texto) {
  Color cor = corStatus(texto);
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: cor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      texto,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: cor),
    ),
  );
}

//bolinha colorida com um icone dentro
Widget iconeCirculo(IconData icone, Color cor) {
  return Container(
    width: 44,
    height: 44,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: cor.withValues(alpha: 0.12),
      shape: BoxShape.circle,
    ),
    child: Icon(icone, color: cor, size: 22),
  );
}

//topo de um cartao: icone, titulo, subtitulo e (opcional) selo de status
Widget cabecalhoCartao(IconData icone, Color cor, String titulo, String subtitulo,
    {String? status}) {
  return Row(
    children: <Widget>[
      iconeCirculo(icone, cor),
      espaco(12, 1),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(titulo, style: estiloTitulo),
            if (subtitulo != '') Text(subtitulo, style: estiloSuave),
          ],
        ),
      ),
      if (status != null) chipStatus(status),
    ],
  );
}

//uma linha com icone pequeno e texto
Widget linhaInfo(IconData icone, String texto) {
  return Container(
    margin: EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icone, size: 16, color: corSuave),
        espaco(8, 1),
        Expanded(child: Text(texto, style: estiloNormal)),
      ],
    ),
  );
}

//rotulo pequeno em cima e valor embaixo
Widget rotuloValor(String rotulo, String valor) {
  return Container(
    margin: EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(rotulo, style: estiloSuave),
        Text(valor == '' ? '—' : valor, style: estiloNormal),
      ],
    ),
  );
}

//caixa de mensagem (sucesso, erro ou informacao)
Widget caixaAviso(String texto, Color cor, IconData icone) {
  return Container(
    margin: EdgeInsets.only(top: 12),
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: cor.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: cor.withValues(alpha: 0.5)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icone, color: cor, size: 20),
        espaco(10, 1),
        Expanded(child: Text(texto, style: TextStyle(color: corTexto, fontSize: 13))),
      ],
    ),
  );
}

//tela sem nada para mostrar
Widget vazio(IconData icone, String texto) {
  return Container(
    margin: EdgeInsets.only(top: 24),
    padding: EdgeInsets.all(20),
    alignment: Alignment.center,
    child: Column(
      children: <Widget>[
        Icon(icone, size: 44, color: corSuave),
        espaco(1, 8),
        Text(texto, textAlign: TextAlign.center, style: estiloSuave),
      ],
    ),
  );
}

//faixa colorida no topo das areas logadas
Widget bannerTopo(String titulo, String subtitulo, IconData icone) {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [corPrimaria, Color(0xFF8E3F25)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(titulo,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              espaco(1, 4),
              Text(subtitulo,
                  style: TextStyle(fontSize: 13, color: Color(0xCCFFFFFF))),
            ],
          ),
        ),
        espaco(12, 1),
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Color(0x33FFFFFF), shape: BoxShape.circle),
          child: Icon(icone, color: Colors.white, size: 28),
        ),
      ],
    ),
  );
}

//titulo de secao dentro da tela (fora de cartao)
Widget tituloSecao(String texto) {
  return Container(
    margin: EdgeInsets.only(top: 20),
    child: Text(texto, style: estiloSecao),
  );
}

//cartao branco com titulo e icone, para agrupar campos de formulario
Widget cartaoSecao(String titulo, IconData icone, List<Widget> filhos) {
  return Container(
    margin: EdgeInsets.only(top: 16),
    padding: EdgeInsets.all(16),
    decoration: decoCartao(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icone, color: corPrimaria, size: 20),
            espaco(8, 1),
            Text(titulo, style: estiloSecao),
          ],
        ),
        ...filhos,
      ],
    ),
  );
}

//cartao branco simples para itens de lista
Widget cartaoSimples(List<Widget> filhos) {
  return Container(
    margin: EdgeInsets.only(top: 12),
    padding: EdgeInsets.all(16),
    decoration: decoCartao(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filhos,
    ),
  );
}

//usa o SEU widget Input, so acrescenta um espaco em cima
Widget campo(String label, String hint, TextEditingController controller) {
  return Container(
    margin: EdgeInsets.only(top: 14),
    child: Input(label, hint, controller: controller),
  );
}

//campo de senha: o Input original nao tem obscureText, entao aqui usamos o mesmo
//TextFormField dele com obscureText: true (os pontinhos no lugar das letras)
Widget campoSenha(String label, String hint, TextEditingController controller) {
  return Container(
    margin: EdgeInsets.only(top: 14),
    child: TextFormField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(hintText: hint, labelText: label),
    ),
  );
}

//usa o SEU widget Buttons, so acrescenta um espaco em cima
Widget botao(String texto, void Function() onClick) {
  return Container(
    margin: EdgeInsets.only(top: 16),
    child: Buttons(texto, onClick: onClick),
  );
}

//abas no topo da tela (mesma ideia do InkWell da aula de Firebase, que da o clique)
Widget abas(List<String> nomes, int atual, void Function(int) aoTocar) {
  return Container(
    margin: EdgeInsets.only(top: 16),
    padding: EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Color(0xFFF0E1D6),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: <Widget>[
        for (int i = 0; i < nomes.length; i++)
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                aoTocar(i);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == atual ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  nomes[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: i == atual ? corPrimaria : corSuave,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

//opcao do Radio (aula 06): bolinha + texto, e o texto tambem seleciona
Widget opcaoRadio<T>(String texto, T valor, void Function() aoTocar) {
  return InkWell(
    onTap: aoTocar,
    child: Row(
      children: <Widget>[
        Radio<T>(value: valor),
        Expanded(child: Text(texto, style: estiloNormal)),
      ],
    ),
  );
}
