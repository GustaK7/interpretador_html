//import "package:interpretador_html/interpretador_html.dart" as interpretador_html;
import 'dart:io' as io;
void main(){
  // Exemplo de código BRHTML (com tags em português)
  print('Digite ou cole seu BRHTML (finalize com Ctrl+D no Linux/macOS ou Ctrl+Z no Windows):');
  StringBuffer input = StringBuffer();

  String? line;
  while ((line = io.stdin.readLineSync()) != null) {
    input.writeln(line);
  }

  String brhtml = input.toString();
  print('\nConteúdo recebido:\n$brhtml');

  String html_convertido = interpretarbrhtml(brhtml);

 // Mostra o HTML convertido no terminal
 print("Segue abaixo o código convertido de BRHTML para HTML:");
 print(html_convertido);

}

/// Função que converte o código BRHTML para HTML
String interpretarbrhtml(String codigo){
  // Mapa com as conversões de tags
  Map<String, String> tags = {
    "titulo"        :  "h1",          
	  "subtitulo"     :  "h2", 	       
	  "secao"         :  "h3", 	       
	  "paragrafo"     :  "p",  	       
	  "link"          :  "a",  	     
	  "imagem"        :  "img",	       
	  "lista1"        :  "ul", 	       
	  "lista2"        :  "ol", 	       
	  "item"          :  "li", 	      
	  "tabela"        :  "table",      
	  "linha"         :  "tr",  
	  "celula"        :  "td",  
	  "cabecalhotab"  :  "th",  
	  "formulario"    :  "form",       
	  "campo"         :  "input",      
	  "botao"         :  "button",     
	  "legenda"       :  "label",      
	  "bloco"         :  "div",        
	  "texto"         :  "span",       
	  "negrito"       :  "strong",     
	  "italico"       :  "em", 	       
	  "quebra"        :  "br", 	       
	  "separador"     :  "hr", 	       
	  "incorporado"   :  "iframe",     
	  "codigo"        :  "script",     
	  "recurso"       :  "link",       
	  "informacao"    :  "meta",      
	  "cabeca"        :  "head",      
	  "corpo"         :  "body",      
	  "tituloPagina"  :  "title",     
	  "navegacao"     :  "nav",       
	  "secaoBloco"    :  "section",   
	  "artigo"        :  "article",   
	  "barraLateral"  :  "aside",     
	  "rodape"        :  "footer",    
	  "cabecalho"     :  "header",    
	  "principal"     :  "main",      
	  "figura"        :  "figure",    
	  "legendaFigura" :  "figcaption",
	  "telaGrafica"   :  "canvas",    
	  "audio"         :  "audio",     
	  "video"         :  "video",     
	  "fonteMidia"    :  "source",    
	  "faixaLegenda"  :  "track",     
	  "semScript"     :  "noscript",  
	  "estilo"        :  "style",     
	  "molde"         :  "template",  
	  "listaDados"    :  "datalist",  
	  "grupoOpcoes"   :  "optgroup",  
	  "opcao"         :  "option",    
	  "seletor"       :  "select",    
	  "areaTexto"     :  "textarea",  
	  "grupoCampos"   :  "fieldset",  
	  "legendaGrupo"  :  "legend",    
	  "progresso"     :  "progress",  
	  "medidor"       :  "meter",     
	  "saida"   	    :  "output",    
	  "detalhes"      :  "details",   
	  "resumo"        :  "summary",   
	  "marcado"       :  "mark",      
	  "abreviacao"    :  "abbr",      
	  "codigoInline"  :  "code",      
	  "preFormatado"  :  "pre",       
	  "teclado"       :  "kbd",       
	  "exemploSaida"  :  "samp",      
	  "variavel"      :  "var",       
	  "removido"      :  "del",       
	  "inserido"      :  "ins",       
	  "citacao"       :  "cite",      
	  "citacaoCurta"  :  "q",         
	  "negritoVisual" :  "b",         
	  "italicoVisual" :  "i",         
	  "sublinhado"    :  "u",         
	  "pequeno"   	  :  "small",     
	  "subscrito"     :  "sub",       
	  "sobrescrito"   :  "sup",       
	  "isolamentoBiDi":  "bdi",       
	  "direcaoTexto"  :  "bdo",       
	  "quebraPossivel":  "wbr",       
	  "incorporar"    :  "embed",     
	  "objeto"        :  "object",    
	  "parametro"     :  "param",        
    };

  // Para cada tag BRHTML, substituir pela tag HTML real
  tags.forEach((br, html){
    codigo = codigo.replaceAll("<$br>", "<$html>");
    codigo = codigo.replaceAll("</$br>", "</$html>");
  });

  return codigo;
}