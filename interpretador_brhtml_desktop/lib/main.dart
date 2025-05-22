import 'package:flutter/material.dart';

void main() {
  runApp(const InterpretadorApp());
}

class InterpretadorApp extends StatelessWidget {
  const InterpretadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interpretador BR',
      theme: ThemeData.dark(),
      home: const InterpretadorHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InterpretadorHome extends StatefulWidget {
  const InterpretadorHome({super.key});

  @override
  State<InterpretadorHome> createState() => _InterpretadorHomeState();
}

class _InterpretadorHomeState extends State<InterpretadorHome> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _saida = [];
  final List<Widget> _widgetsDinamicos = [];
  final InterpretadorBR _interpretador = InterpretadorBR();
  final List<String> _mensagens = [];
  bool _ajudaAberta = false;

  void _executarComando() {
    final texto = _controller.text;
    if (texto.trim().isEmpty) return;
    setState(() {
      _saida.clear();
      _widgetsDinamicos.clear();
      _mensagens.clear();
      try {
        final resultado = _interpretador.interpretarBloco(texto, adicionarWidget: _adicionarWidget, adicionarMensagem: _adicionarMensagem);
        if (resultado.isNotEmpty) {
          _mensagens.add(resultado);
        }
      } catch (e) {
        _mensagens.add('Erro: $e');
      }
    });
    _controller.clear();
  }

  void _adicionarWidget(Widget widget) {
    setState(() {
      _widgetsDinamicos.clear();
      _widgetsDinamicos.add(widget);
    });
  }

  void _adicionarMensagem(String msg) {
    setState(() {
      _mensagens.add(msg);
    });
  }

  void _limparSaida() {
    setState(() {
      _saida.clear();
      _widgetsDinamicos.clear();
      _mensagens.clear();
    });
  }

  void _alternarAjuda() {
    setState(() {
      _ajudaAberta = !_ajudaAberta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          title: const Text('Interpretador BRDart'),
          actions: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _executarComando,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Executar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _limparSaida,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _alternarAjuda,
                  icon: const Icon(Icons.help_outline),
                  label: const Text('Ajuda'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Editor de comandos à esquerda
                Expanded(
                  flex: _ajudaAberta ? 2 : 1,
                  child: Container(
                    color: const Color(0xFF1E1E1E),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Editor', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controller,
                            maxLines: null,
                            minLines: 5,
                            style: const TextStyle(fontFamily: 'Fira Mono'),
                            decoration: const InputDecoration(
                              hintText: 'Digite seus comandos BRDart aqui...}',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF252526),
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                  ),
                ),
                // Barra lateral de ajuda
                if (_ajudaAberta)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 350,
                      height: double.infinity,
                      color: const Color(0xFF23272E),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Ajuda BRDart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white70),
                                    onPressed: _alternarAjuda,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _ajudaComandos(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // Saída à direita
                Expanded(
                  flex: 2,
                  child: Container(
                    color: const Color(0xFF1E1E1E),
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              // Saída de texto (não usada, mas mantida para compatibilidade)
                              ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: _saida.length,
                                itemBuilder: (context, index) => Text(
                                  _saida[index],
                                  style: const TextStyle(fontFamily: 'Fira Mono', fontSize: 15),
                                ),
                              ),
                              // Widgets dinâmicos centralizados
                              if (_widgetsDinamicos.isNotEmpty)
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ..._widgetsDinamicos,
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Terminal de mensagens estilo VS Code (agora ocupa toda a largura)
          Container(
            width: double.infinity,
            color: const Color(0xFF181818),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Terminal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                ..._mensagens.map((msg) => Text(msg, style: const TextStyle(fontFamily: 'Fira Mono', color: Colors.greenAccent, fontSize: 14))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ajudaComandos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          title: const Text('Comandos básicos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          initiallyExpanded: true,
          children: [
            const ListTile(
              title: Text('diga <mensagem>', style: TextStyle(color: Colors.amber)),
              subtitle: Text('Exibe uma mensagem.'),
            ),
            const ListTile(
              title: Text('soma <a> <b>', style: TextStyle(color: Colors.amber)),
              subtitle: Text('Soma dois números.'),
            ),
            const ListTile(
              title: Text('subtrai <a> <b>', style: TextStyle(color: Colors.amber)),
              subtitle: Text('Subtrai dois números.'),
            ),
            const ListTile(
              title: Text('multiplica <a> <b>', style: TextStyle(color: Colors.amber)),
              subtitle: Text('Multiplica dois números.'),
            ),
            const ListTile(
              title: Text('divide <a> <b>', style: TextStyle(color: Colors.amber)),
              subtitle: Text('Divide dois números.'),
            ),
            const ListTile(
              title: Text('resto <a> <b>', style: TextStyle(color: Colors.amber)),
              subtitle: Text('Resto da divisão inteira.'),
            ),
            const ListTile(
              title: Text('define <nome> = <valor>', style: TextStyle(color: Colors.amber)),
              subtitle: Text('Define uma variável.'),
            ),
            const ListTile(
              title: Text('mostre <nome>', style: TextStyle(color: Colors.amber)),
              subtitle: Text('Mostra o valor de uma variável.'),
            ),
            const ListTile(
              title: Text('repita <n> <comando>', style: TextStyle(color: Colors.amber)),
              subtitle: Text('Repete um comando n vezes.'),
            ),
            const ListTile(
              title: Text('se <a> <op> <b> <comando> [senao <comando>]', style: TextStyle(color: Colors.amber)),
              subtitle: Text('Executa comando se condição for verdadeira.'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          title: Text('Widgets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.lightBlueAccent)),
          initiallyExpanded: true,
          children: [
            ListTile(
              title: Text('box{ ... }', style: TextStyle(color: Colors.lightBlueAccent)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Cria uma caixa. Pode conter outros widgets ou caixas aninhadas.'),
                  SizedBox(height: 8),
                  Text('Exemplo:'),
                  SizedBox(height: 4),
                  SelectableText('''box{
  cor.box = verde
  texto{
    cor.texto = branco
    "Esse é um widget"
  }
}''', style: TextStyle(fontFamily: 'Fira Mono', fontSize: 13)),
                ],
              ),
            ),
            ListTile(
              title: Text('texto{ ... } ou text{ ... }', style: TextStyle(color: Colors.lightBlueAccent)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Exibe um texto. Pode definir cor dentro do bloco.'),
                  SizedBox(height: 8),
                  Text('Exemplo:'),
                  SizedBox(height: 4),
                  SelectableText('''texto{
  cor.texto = vermelho
  "Olá mundo!"
}''', style: TextStyle(fontFamily: 'Fira Mono', fontSize: 13)),
                ],
              ),
            ),
            ListTile(
              title: Text('Cores disponíveis', style: TextStyle(color: Colors.lightBlueAccent)),
              subtitle: Text('azul, verde, vermelho, amarelo, preto, branco, cinza, laranja, roxo, rosa', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }
}

class InterpretadorBR {
  final Map<String, String> variaveis = {};
  Color _corBox = Colors.blueGrey.shade900;
  Color _corTexto = Colors.amber;

  // Novo: interpreta blocos aninhados e comandos de cor
  String interpretarBloco(String bloco, {void Function(Widget)? adicionarWidget, void Function(String)? adicionarMensagem}) {
    bloco = bloco.trim();
    if (bloco.startsWith('box{')) {
      final inner = _extrairBloco(bloco.substring(3).trim());
      Color corBox = _corBox;
      Widget? child;
      final filhos = <Widget>[];
      final linhas = _linhasBloco(inner);
      for (final linha in linhas) {
        final l = linha.trim();
        if (l.startsWith('cor.box')) {
          final partes = l.split('=');
          if (partes.length == 2) {
            final cor = _parseCor(partes[1].trim());
            if (cor != null) {
              corBox = cor;
              adicionarMensagem?.call('Cor da caixa definida.');
            } else {
              adicionarMensagem?.call('Cor de caixa desconhecida.');
            }
          }
        } else if (l.startsWith('text{') || l.startsWith('texto{')) {
          final widget = _interpretarBlocoWidget(l, adicionarMensagem: adicionarMensagem);
          if (widget != null) filhos.add(widget);
        } else if (l.startsWith('box{')) {
          final widget = _interpretarBlocoWidget(l, adicionarMensagem: adicionarMensagem);
          if (widget != null) filhos.add(widget);
        }
      }
      if (filhos.isNotEmpty) {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: filhos,
        );
      }
      final box = Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: corBox,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
      adicionarWidget?.call(box);
      return 'Widget box renderizado!';
    } else if (bloco.startsWith('text{') || bloco.startsWith('texto{')) {
      final inner = bloco.startsWith('text{')
          ? _extrairBloco(bloco.substring(4).trim())
          : _extrairBloco(bloco.substring(5).trim());
      Color corTexto = _corTexto;
      String conteudo = '';
      final linhas = _linhasBloco(inner);
      for (final linha in linhas) {
        final l = linha.trim();
        if (l.startsWith('cor.texto')) {
          final partes = l.split('=');
          if (partes.length == 2) {
            final cor = _parseCor(partes[1].trim());
            if (cor != null) {
              corTexto = cor;
              adicionarMensagem?.call('Cor do texto definida.');
            } else {
              adicionarMensagem?.call('Cor de texto desconhecida.');
            }
          }
        } else if (l.startsWith('"') && l.endsWith('"')) {
          conteudo = l.substring(1, l.length - 1);
        } else {
          conteudo = l;
        }
      }
      if (adicionarWidget != null) {
        adicionarWidget(Text(conteudo, style: TextStyle(fontSize: 20, color: corTexto)));
      }
      return 'Widget texto renderizado!';
    } else {
      // Comandos simples e variáveis
      final resultado = interpretarLinha(bloco, adicionarWidget: adicionarWidget);
      if (adicionarMensagem != null && resultado.isNotEmpty) {
        adicionarMensagem(resultado);
      }
      return '';
    }
  }

  Widget? _interpretarBlocoWidget(String bloco, {Color? corTexto, void Function(String)? adicionarMensagem}) {
    bloco = bloco.trim();
    if (bloco.startsWith('text{') || bloco.startsWith('texto{')) {
      final inner = bloco.startsWith('text{')
          ? _extrairBloco(bloco.substring(4).trim())
          : _extrairBloco(bloco.substring(5).trim());
      Color cor = corTexto ?? _corTexto;
      String conteudo = '';
      final linhas = _linhasBloco(inner);
      for (final linha in linhas) {
        final l = linha.trim();
        if (l.startsWith('cor.texto')) {
          final partes = l.split('=');
          if (partes.length == 2) {
            final corParsed = _parseCor(partes[1].trim());
            if (corParsed != null) {
              cor = corParsed;
              adicionarMensagem?.call('Cor do texto definida.');
            } else {
              adicionarMensagem?.call('Cor de texto desconhecida.');
            }
          }
        } else if (l.startsWith('"') && l.endsWith('"')) {
          conteudo = l.substring(1, l.length - 1);
        } else {
          conteudo = l;
        }
      }
      return Text(conteudo, style: TextStyle(fontSize: 20, color: cor));
    } else if (bloco.startsWith('box{')) {
      // Permite box aninhado
      final inner = _extrairBloco(bloco.substring(3).trim());
      Color corBox = _corBox;
      Widget? child;
      final filhos = <Widget>[];
      final linhas = _linhasBloco(inner);
      for (final linha in linhas) {
        final l = linha.trim();
        if (l.startsWith('cor.box')) {
          final partes = l.split('=');
          if (partes.length == 2) {
            final cor = _parseCor(partes[1].trim());
            if (cor != null) {
              corBox = cor;
              adicionarMensagem?.call('Cor da caixa definida.');
            } else {
              adicionarMensagem?.call('Cor de caixa desconhecida.');
            }
          }
        } else if (l.startsWith('text{') || l.startsWith('texto{')) {
          final widget = _interpretarBlocoWidget(l, adicionarMensagem: adicionarMensagem);
          if (widget != null) filhos.add(widget);
        } else if (l.startsWith('box{')) {
          final widget = _interpretarBlocoWidget(l, adicionarMensagem: adicionarMensagem);
          if (widget != null) filhos.add(widget);
        }
      }
      if (filhos.isNotEmpty) {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: filhos,
        );
      }
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: corBox,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
    }
    return null;
  }

  String interpretarLinha(String linha, {void Function(Widget)? adicionarWidget}) {
    final trimmed = linha.trim();
    // Controle de cor: cor.box = verde, cor.texto = branco
    if (trimmed.startsWith('cor.box')) {
      final partes = trimmed.split('=');
      if (partes.length == 2) {
        final cor = _parseCor(partes[1].trim());
        if (cor != null) {
          _corBox = cor;
          return 'Cor da caixa definida.';
        } else {
          return 'Cor de caixa desconhecida.';
        }
      }
    } else if (trimmed.startsWith('cor.texto')) {
      final partes = trimmed.split('=');
      if (partes.length == 2) {
        final cor = _parseCor(partes[1].trim());
        if (cor != null) {
          _corTexto = cor;
          return 'Cor do texto definida.';
        } else {
          return 'Cor de texto desconhecida.';
        }
      }
    } else if (trimmed.startsWith('box{')) {
      try {
        final widget = _parseWidget(trimmed);
        if (adicionarWidget != null) adicionarWidget(widget);
        return 'Widget box renderizado!';
      } catch (e) {
        return 'Erro ao interpretar box: $e';
      }
    } else if (trimmed.startsWith('texto{')) {
      try {
        final widget = _parseWidget(trimmed);
        if (adicionarWidget != null) adicionarWidget(widget);
        return 'Widget texto renderizado!';
      } catch (e) {
        return 'Erro ao interpretar texto: $e';
      }
    } else if (trimmed.startsWith('tela{')) {
      try {
        final widget = _parseTela(trimmed);
        if (adicionarWidget != null) adicionarWidget(widget);
        return 'Widget tela renderizado!';
      } catch (e) {
        return 'Erro ao interpretar tela: $e';
      }
    }
    final tokens = linha.trim().split(RegExp(r"\s+"));
    if (tokens.isEmpty) return "";
    final comando = tokens[0];
    switch (comando) {
      case "diga":
        return tokens.sublist(1).join(" ");

      case "soma":
        if (tokens.length < 3) return "Erro: argumentos insuficientes.";
        final a = double.tryParse(tokens[1].replaceAll(',', '.'));
        final b = double.tryParse(tokens[2].replaceAll(',', '.'));
        if (a == null || b == null) return "Erro na soma: argumentos inválidos.";
        return "${a + b}";

      case "subtrai":
        if (tokens.length < 3) return "Erro: argumentos insuficientes.";
        final a = double.tryParse(tokens[1]);
        final b = double.tryParse(tokens[2]);
        if (a == null || b == null) return "Erro na subtração: argumentos inválidos.";
        return "${a - b}";

      case "multiplica":
        if (tokens.length < 3) return "Erro: argumentos insuficientes.";
        final a = double.tryParse(tokens[1]);
        final b = double.tryParse(tokens[2]);
        if (a == null || b == null) return "Erro na multiplicação: argumentos inválidos.";
        return "${a * b}";

      case "divide":
        if (tokens.length < 3) return "Erro: argumentos insuficientes.";
        final a = double.tryParse(tokens[1]);
        final b = double.tryParse(tokens[2]);
        if (a == null || b == null) return "Erro na divisão: argumentos inválidos.";
        if (b == 0) return "Erro: divisão por zero.";
        return "${a / b}";

      case "resto":
        if (tokens.length < 3) return "Erro: argumentos insuficientes.";
        final a = int.tryParse(tokens[1]);
        final b = int.tryParse(tokens[2]);
        if (a == null || b == null) return "Erro no resto: argumentos inválidos.";
        if (b == 0) return "Erro: divisão por zero.";
        return "${a % b}";

      case "define":
        if (tokens.length < 4 || tokens[2] != "=") {
          return "Erro: use 'define nome = valor'.";
        }
        final nome = tokens[1];
        final valor = tokens.sublist(3).join(" ");
        variaveis[nome] = valor;
        return "Variável '$nome' definida com valor '$valor'.";

      case "mostre":
        final nome = tokens[1];
        return variaveis[nome] ?? "Variável '$nome' não definida.";

      case "repita":
        if (tokens.length < 3) return "Erro: use 'repita n comando ...'";
        final vezes = int.tryParse(tokens[1]);
        if (vezes == null || vezes < 1) return "Erro: número de repetições inválido.";
        final comandoRepetido = tokens.sublist(2).join(" ");
        final resultados = <String>[];
        for (int i = 0; i < vezes; i++) {
          resultados.add(interpretarLinha(comandoRepetido));
        }
        return resultados.join("\n");

      case "se":
        if (tokens.length < 5) return "Erro: use 'se valor1 operador valor2 comando ...'";
        final valor1 = tokens[1];
        final operador = tokens[2];
        final valor2 = tokens[3];
        bool condicao = false;
        final num1 = double.tryParse(valor1);
        final num2 = double.tryParse(valor2);
        if (num1 != null && num2 != null) {
          switch (operador) {
            case '==': condicao = num1 == num2; break;
            case '!=': condicao = num1 != num2; break;
            case '>': condicao = num1 > num2; break;
            case '<': condicao = num1 < num2; break;
            case '>=': condicao = num1 >= num2; break;
            case '<=': condicao = num1 <= num2; break;
            default: return "Erro: operador desconhecido '$operador'";
          }
        } else {
          switch (operador) {
            case '==': condicao = valor1 == valor2; break;
            case '!=': condicao = valor1 != valor2; break;
            default: return "Erro: operador '$operador' só suporta números.";
          }
        }
        // Procura por 'senao' nos tokens
        int senaoIndex = tokens.indexWhere((t) => t == 'senao', 4);
        if (condicao) {
          final comandoCondicional = senaoIndex == -1
              ? tokens.sublist(4).join(" ")
              : tokens.sublist(4, senaoIndex).join(" ");
          return interpretarLinha(comandoCondicional);
        } else if (senaoIndex != -1 && senaoIndex + 1 < tokens.length) {
          final comandoSenao = tokens.sublist(senaoIndex + 1).join(" ");
          return interpretarLinha(comandoSenao);
        } else {
          return "";
        }

      default:
        return "Comando desconhecido: $comando";
    }
  }

  Widget _parseTela(String input) {
    // Remove 'tela{' e '}' finais
    final inner = _extrairBloco(input.substring(4).trim());
    return _parseWidget(inner);
  }

  Widget _parseWidget(String input) {
    input = input.trim();
    if (input.startsWith('box{')) {
      final inner = _extrairBloco(input.substring(3).trim());
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _corBox,
          borderRadius: BorderRadius.circular(8),
        ),
        child: _parseWidget(inner),
      );
    } else if (input.startsWith('texto{')) {
      final inner = _extrairBloco(input.substring(5).trim());
      return Text(inner, style: TextStyle(fontSize: 20, color: _corTexto));
    } else {
      throw 'Bloco desconhecido: $input';
    }
  }

  Color? _parseCor(String cor) {
    switch (cor.toLowerCase()) {
      case 'azul': return Colors.blue;
      case 'verde': return Colors.green;
      case 'vermelho': return Colors.red;
      case 'amarelo': return Colors.yellow;
      case 'preto': return Colors.black;
      case 'branco': return Colors.white;
      case 'cinza': return Colors.grey;
      case 'laranja': return Colors.orange;
      case 'roxo': return Colors.purple;
      case 'rosa': return Colors.pink;
      default: return null;
    }
  }

  String _extrairBloco(String input) {
    // Extrai conteúdo entre { ... }
    int nivel = 0;
    int start = 0;
    int end = 0;
    for (int i = 0; i < input.length; i++) {
      if (input[i] == '{') {
        if (nivel == 0) start = i + 1;
        nivel++;
      } else if (input[i] == '}') {
        nivel--;
        if (nivel == 0) {
          end = i;
          break;
        }
      }
    }
    if (nivel != 0) throw 'Bloco não fechado corretamente';
    return input.substring(start, end).trim();
  }

  // Função utilitária para dividir blocos em linhas ignorando chaves aninhadas
  List<String> _linhasBloco(String bloco) {
    List<String> linhas = [];
    int nivel = 0;
    StringBuffer atual = StringBuffer();
    for (int i = 0; i < bloco.length; i++) {
      final c = bloco[i];
      if (c == '{') nivel++;
      if (c == '}') nivel--;
      if (c == '\n' && nivel == 0) {
        linhas.add(atual.toString());
        atual.clear();
      } else {
        atual.write(c);
      }
    }
    if (atual.isNotEmpty) linhas.add(atual.toString());
    return linhas;
  }
}
