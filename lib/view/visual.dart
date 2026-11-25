import 'package:flutter/material.dart';
import '../widgets/buttons.dart';
import '../widgets/input.dart';

const Color corPrimaria = Color(0xFFB95F3E);
const Color corEscura = Color(0xFF5B2A1A);
const Color corFundo = Color(0xFFFBF3EC);
const Color corTexto = Color(0xFF3A2A22);
const Color corSuave = Color(0xFF8C7A70);
const Color corVerde = Color(0xFF2E7D5B);
const Color corAmarelo = Color(0xFFC77B12);
const Color corVermelho = Color(0xFFB3382C);

const TextStyle estiloTitulo =
    TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: corTexto);
const TextStyle estiloSecao =
    TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: corTexto);
const TextStyle estiloNormal = TextStyle(fontSize: 14, color: corTexto);
const TextStyle estiloSuave = TextStyle(fontSize: 12, color: corSuave);

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

Widget espaco(double largura, double altura) {
  return Container(width: largura, height: altura);
}

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

Widget tituloSecao(String texto) {
  return Container(
    margin: EdgeInsets.only(top: 20),
    child: Text(texto, style: estiloSecao),
  );
}

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

Widget campo(String label, String hint, TextEditingController controller) {
  return Container(
    margin: EdgeInsets.only(top: 14),
    child: Input(label, hint, controller: controller),
  );
}

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

Widget botao(String texto, void Function() onClick) {
  return Container(
    margin: EdgeInsets.only(top: 16),
    child: Buttons(texto, onClick: onClick),
  );
}

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
