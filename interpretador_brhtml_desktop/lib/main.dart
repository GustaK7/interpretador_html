import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  runApp(const InterpretadorBrApp());
}

class InterpretadorBrApp extends StatelessWidget {
  const InterpretadorBrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INTERPRETADOR BRHTML',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF165924),
          primary: const Color(0xFF165924),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const InterpretadorBrHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InterpretadorBrHomePage extends StatefulWidget {
  const InterpretadorBrHomePage({super.key});

  @override
  State<InterpretadorBrHomePage> createState() => _InterpretadorBrHomePageState();
}

class _InterpretadorBrHomePageState extends State<InterpretadorBrHomePage> {
  final TextEditingController _controller = TextEditingController(
    text: "<corpo>\n  <titulo>Olá, mundo</titulo>\n  <paragrafo>Vamos começar?</paragrafo>\n</corpo>"
  );
  String _saida = "";
  bool _mostraHTML = false;

  String interpretarBrHTML(String codigo) {
    Map<String, String> tags = {
      "titulo": "h1",
      "subtitulo": "h2",
      "secao": "h3",
      "paragrafo": "p",
      "link": "a",
      "imagem": "img",
      "lista1": "ul",
      "lista2": "ol",
      "item": "li",
      "tabela": "table",
      "linha": "tr",
      "celula": "td",
      "cabecalhotab": "th",
      "formulario": "form",
      "campo": "input",
      "botao": "button",
      "legenda": "label",
      "bloco": "div",
      "texto": "span",
      "negrito": "strong",
      "italico": "em",
      "quebra": "br",
      "separador": "hr",
      "incorporado": "iframe",
      "codigo": "script",
      "recurso": "link",
      "informacao": "meta",
      "cabeca": "head",
      "corpo": "body",
      "tituloPagina": "title",
      "navegacao": "nav",
      "secaoBloco": "section",
      "artigo": "article",
      "barraLateral": "aside",
      "rodape": "footer",
      "cabecalho": "header",
      "principal": "main",
      "figura": "figure",
      "legendaFigura": "figcaption",
      "telaGrafica": "canvas",
      "audio": "audio",
      "video": "video",
      "fonteMidia": "source",
      "faixaLegenda": "track",
      "semScript": "noscript",
      "estilo": "style",
      "molde": "template",
      "listaDados": "datalist",
      "grupoOpcoes": "optgroup",
      "opcao": "option",
      "seletor": "select",
      "areaTexto": "textarea",
      "grupoCampos": "fieldset",
      "legendaGrupo": "legend",
      "progresso": "progress",
      "medidor": "meter",
      "saida": "output",
      "detalhes": "details",
      "resumo": "summary",
      "marcado": "mark",
      "abreviacao": "abbr",
      "codigoInline": "code",
      "preFormatado": "pre",
      "teclado": "kbd",
      "exemploSaida": "samp",
      "variavel": "var",
      "removido": "del",
      "inserido": "ins",
      "citacao": "cite",
      "citacaoCurta": "q",
      "negritoVisual": "b",
      "italicoVisual": "i",
      "sublinhado": "u",
      "pequeno": "small",
      "subscrito": "sub",
      "sobrescrito": "sup",
      "isolamentoBiDi": "bdi",
      "direcaoTexto": "bdo",
      "quebraPossivel": "wbr",
      "incorporar": "embed",
      "objeto": "object",
      "parametro": "param"
    };

    // Primeiro, lidar com tags com atributos
    // Exemplo: <link href="..."> ou <imagem src="...">
    final regexAberturaComAtributos = RegExp(r'<(\w+)(\s+[^>]+)>');
    codigo = codigo.replaceAllMapped(regexAberturaComAtributos, (match) {
      final tagBr = match.group(1)!;
      final atributos = match.group(2)!;
      
      if (tags.containsKey(tagBr)) {
        return '<${tags[tagBr]}$atributos>';
      } else {
        return match.group(0)!; // Mantém como está se não encontrar
      }
    });

    // Depois, substituir tags simples (sem atributos)
    tags.forEach((br, html) {
      codigo = codigo.replaceAll('<$br>', '<$html>');
      codigo = codigo.replaceAll('</$br>', '</$html>');
    });

    return codigo;
  }

  @override
  void initState() {
    super.initState();
    // Inicializa a saída com o texto predefinido para mostrar um exemplo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _saida = interpretarBrHTML(_controller.text);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'INTERPRETADOR BRHTML',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF165924),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Editor de código
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade800, width: 3),
                color: Colors.white,
              ),
              margin: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  fontFamily: 'Courier New',
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                  hintText: 'Digite seu código BRHTML aqui...',
                ),
              ),
            ),
          ),
          
          // Barra de botões
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botão para limpar o editor
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                      _saida = "";
                    });
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Limpar', style: TextStyle(color: Colors.red)),
                ),
                const Spacer(),
                // Botão RUN com ícone de play
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _saida = interpretarBrHTML(_controller.text);
                      _mostraHTML = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Visualizar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                // Botão Código fonte
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _saida = interpretarBrHTML(_controller.text);
                      _mostraHTML = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  icon: const Text('</>', style: TextStyle(fontWeight: FontWeight.bold)),
                  label: const Text('Ver HTML', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          // Área de saída
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade800, width: 3),
                color: Colors.white,
              ),
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(16.0),
              child: _mostraHTML
                ? // Mostrar HTML
                  SingleChildScrollView(
                    child: SelectableText(
                      _saida,
                      style: const TextStyle(
                        fontFamily: 'Courier New',
                        fontSize: 16,
                      ),
                    ),
                  )
                : // Mostrar renderização
                  _saida.isEmpty
                    ? const Center(child: Text("Execute o código para ver o resultado."))
                    : SingleChildScrollView(
                        child: Html(
                          data: _saida,
                          style: {
                            "body": Style(margin: Margins.zero//, padding: EdgeInsets.zero
                            ),
                          },
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}