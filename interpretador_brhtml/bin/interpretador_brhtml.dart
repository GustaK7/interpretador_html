//import 'package:interpretador_html/interpretador_html.dart' as interpretador_html;

void main(){
  String brhtml = """
   <titulo> Bem-vindo ao interpretador BRHTML </titulo>
   <paragrafo> Este é um interpretador de HTML simples, desenvolvido em Dart. </paragrafo>
   <paragrafo> Você pode usar tags como <titulo>, <paragrafo>, <negrito>, <itálico> e <sublinhado>. </paragrafo>
   <negrito> Este texto está em negrito. </negrito>
   <itálico> Este texto está em itálico. </itálico>
   <sublinhado> Este texto está sublinhado. </sublinhado>
""";
 final String html_convertido = interpretadorbrhtml(brhtml);

 print("Segue abaixo o código convertido de BRHTML para HTML:");
 print(html_convertido);

}

String interpretadorbrhtml(String codigo){
  Map<String, String> tags = {
    "<titulo>": "<h1>",
    "<paragrafo>": "<p>",
    "<negrito>": "<storng>",
    "<itálico>": "<em>",
    "<sublinhado>": "<u>",
  };

  tags.forEach((br, html){
    codigo = codigo.replaceAll('<$br>', '<$html>');
    codigo = codigo.replaceAll('<$br>', '</$html>');
  });

  return codigo;

}