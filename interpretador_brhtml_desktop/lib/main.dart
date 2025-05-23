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
        final resultado = _interpretador.interpretarBlocoSintaxeNova(texto, adicionarWidget: _adicionarWidget, adicionarMensagem: _adicionarMensagem);
        if (resultado.isNotEmpty) {
          _mensagens.add(resultado);
        }
      } catch (e) {
        _mensagens.add('Erro: $e');
      }
    });
    // Não limpar o controller para manter o texto digitado
    // _controller.clear();
  }

  void _adicionarWidget(Widget widget) {
    setState(() {
      // Não limpar, apenas adicionar para permitir múltiplos widgets
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
  void initState() {
    super.initState();
    _interpretador.setAdicionarMensagemGlobal(_adicionarMensagem);
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
      body: Row(
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
                        // Menu lateral de ajuda à direita
                        if (_ajudaAberta)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 350,
                              color: const Color(0xFF23272E),
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  children: [
                                    Container(
                                      color: const Color(0xFF181C20),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Ajuda BRDart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white70),
                                            onPressed: _alternarAjuda,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(height: 1, color: Colors.white12),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.all(16),
                                        child: _ajudaComandos(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
      // Terminal de mensagens estilo VS Code (agora ocupa toda a largura)
      bottomNavigationBar: Container(
        width: double.infinity,
        color: const Color(0xFF181818),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Terminal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            ..._mensagens.map((msg) => Text(msg, style: const TextStyle(fontFamily: 'Fira Mono', color: Colors.greenAccent, fontSize: 14))),
          ],
        ),
      ),
    );
  }

  Widget _ajudaComandos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          title: const Text('Comandos básicos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
          initiallyExpanded: true,
          children: [
            _ajudaItem('diga <mensagem>', 'Exibe uma mensagem.'),
            _ajudaItem('soma <a> <b>', 'Soma dois números.'),
            _ajudaItem('subtrai <a> <b>', 'Subtrai dois números.'),
            _ajudaItem('multiplica <a> <b>', 'Multiplica dois números.'),
            _ajudaItem('divide <a> <b>', 'Divide dois números.'),
            _ajudaItem('resto <a> <b>', 'Resto da divisão inteira.'),
            _ajudaItem('define <nome> = <valor>', 'Define uma variável.'),
            _ajudaItem('mostre <nome>', 'Mostra o valor de uma variável.'),
            _ajudaItem('repita <n> <comando>', 'Repete um comando n vezes.'),
            _ajudaItem('Se (condição) {bloco} senao {bloco}', 'Executa bloco se condição for verdadeira, senão executa o outro bloco.'),
            const SizedBox(height: 8),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Separação de comandos:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            ),
            const Text('Use ponto e vírgula (;) para separar comandos, inclusive dentro de blocos com chaves.', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          title: const Text('Widgets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.lightBlueAccent)),
          initiallyExpanded: true,
          children: [
            _ajudaItem('box{ ... }', 'Cria uma caixa. Pode conter outros widgets ou caixas aninhadas.'),
            _ajudaItem('texto{ ... } ou text{ ... }', 'Exibe um texto. Pode definir cor dentro do bloco.'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Cores disponíveis:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            ),
            const Text('azul, verde, vermelho, amarelo, preto, branco, cinza, laranja, roxo, rosa', style: TextStyle(fontSize: 13, color: Colors.white70)),
            const SizedBox(height: 8),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Exemplo de widget:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              child: const SelectableText(
                'box{\n  cor.box = verde;\n  texto{\n    cor.texto = branco;\n    "Esse é um widget";\n  }\n}',
                style: TextStyle(fontFamily: 'Fira Mono', fontSize: 13, color: Colors.lightGreenAccent),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ajudaItem(String comando, String descricao) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      title: Text(comando, style: const TextStyle(color: Colors.amber, fontFamily: 'Fira Mono', fontWeight: FontWeight.bold)),
      subtitle: Text(descricao, style: const TextStyle(color: Colors.white70)),
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
      final List<Widget> filhos = [];
      final List<String> mensagensPendentes = [];
      interpretarBlocoSintaxeNova(
        inner,
        adicionarWidget: (w) => filhos.add(w),
        adicionarMensagem: (msg) {
          if (msg.trim().isNotEmpty) mensagensPendentes.add(msg.trim());
        },
      );
      for (final msg in mensagensPendentes) {
        filhos.add(Text(msg, style: TextStyle(fontSize: 16, color: _corTexto)));
      }
      Widget? child;
      if (filhos.isNotEmpty) {
        child = filhos.length == 1 ? filhos.first : Column(crossAxisAlignment: CrossAxisAlignment.start, children: filhos);
      }
      final box = Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _corBox,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
      adicionarWidget?.call(box);
      return '';
    } else if (bloco.startsWith('text{') || bloco.startsWith('texto{')) {
      final inner = bloco.startsWith('text{')
          ? _extrairBloco(bloco.substring(4).trim())
          : _extrairBloco(bloco.substring(5).trim());
      final List<Widget> filhos = [];
      final List<String> mensagensPendentes = [];
      interpretarBlocoSintaxeNova(
        inner,
        adicionarWidget: (w) => filhos.add(w),
        adicionarMensagem: (msg) {
          if (msg.trim().isNotEmpty) mensagensPendentes.add(msg.trim());
        },
      );
      for (final msg in mensagensPendentes) {
        filhos.add(Text(msg, style: TextStyle(fontSize: 20, color: _corTexto)));
      }
      if (adicionarWidget != null) {
        if (filhos.isNotEmpty) {
          final widget = filhos.length == 1 ? filhos.first : Column(crossAxisAlignment: CrossAxisAlignment.start, children: filhos);
          adicionarWidget(widget);
        }
      }
      return '';
    } else {
      // Comandos simples e variáveis
      final resultado = interpretarLinha(bloco, adicionarWidget: adicionarWidget);
      if (adicionarMensagem != null && resultado.isNotEmpty) {
        adicionarMensagem(resultado);
      }
      return '';
    }
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
    final tokens = linha.trim().split(RegExp(r"\\s+"));
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
        // Se não reconhecido, trata como texto a ser exibido (como diga)
        return linha.trim();
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
      final List<Widget> filhos = [];
      interpretarBlocoSintaxeNova(
        inner,
        adicionarWidget: (w) => filhos.add(w),
        adicionarMensagem: (msg) {
          if (msg.trim().isNotEmpty) {
            if (_adicionarMensagemGlobal != null) _adicionarMensagemGlobal!(msg);
          }
        },
      );
      Widget? child;
      if (filhos.isNotEmpty) {
        child = filhos.length == 1 ? filhos.first : Column(crossAxisAlignment: CrossAxisAlignment.start, children: filhos);
      } else {
        child = const SizedBox.shrink();
      }
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _corBox,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
    } else if (input.startsWith('texto{')) {
      final inner = _extrairBloco(input.substring(5).trim());
      final List<Widget> filhos = [];
      interpretarBlocoSintaxeNova(
        inner,
        adicionarWidget: (w) => filhos.add(w),
        adicionarMensagem: (msg) {
          if (msg.trim().isNotEmpty) {
            if (_adicionarMensagemGlobal != null) _adicionarMensagemGlobal!(msg);
          }
        },
      );
      Widget? child;
      if (filhos.isNotEmpty) {
        child = filhos.length == 1 ? filhos.first : Column(crossAxisAlignment: CrossAxisAlignment.start, children: filhos);
      } else {
        child = const SizedBox.shrink();
      }
      return child;
    } else {
      throw 'Bloco desconhecido: $input';
    }
  }

  // Ponteiro global para adicionar mensagens ao terminal
  void Function(String)? _adicionarMensagemGlobal;

  void setAdicionarMensagemGlobal(void Function(String) fn) {
    _adicionarMensagemGlobal = fn;
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

  // Novo método para sintaxe com chaves e ponto e vírgula
  String interpretarBlocoSintaxeNova(String bloco, {void Function(Widget)? adicionarWidget, void Function(String)? adicionarMensagem}) {
    List<String> comandos = _splitComandosPorPontoEVirgula(bloco);
    String saida = '';
    for (var comando in comandos) {
      comando = comando.trim();
      if (comando.isEmpty) continue;
      if (comando.startsWith(RegExp(r'Se|se'))) {
        saida += _interpretarSeBloco(comando, adicionarWidget: adicionarWidget, adicionarMensagem: adicionarMensagem) + '\n';
      } else if (comando.startsWith('box{') || comando.startsWith('texto{') || comando.startsWith('text{')) {
        try {
          final widget = _parseWidget(comando);
          if (adicionarWidget != null) adicionarWidget(widget);
        } catch (e) {
          if (adicionarMensagem != null) adicionarMensagem('Erro ao interpretar widget: $e');
        }
      } else if (comando.startsWith('cor.box') || comando.startsWith('cor.texto')) {
        final resultado = interpretarLinha(comando);
        if (resultado.trim().isNotEmpty && adicionarMensagem != null) {
          adicionarMensagem(resultado);
        }
      } else if (comando.startsWith('diga')) {
        // Renderiza apenas se entre aspas
        String conteudo = comando.substring(4).trim();
        if (conteudo.startsWith('"') && conteudo.endsWith('"')) {
          conteudo = conteudo.substring(1, conteudo.length - 1);
          if (conteudo.isNotEmpty) {
            if (adicionarWidget != null) {
              adicionarWidget(Text(conteudo, style: TextStyle(fontSize: 16, color: _corTexto)));
            }
            if (adicionarMensagem != null) {
              adicionarMensagem(conteudo);
            }
          }
        }
        // Se não estiver entre aspas, não renderiza nada
      } else if (comando.startsWith('define') || comando.startsWith('mostre') || comando.startsWith('repita') || comando.startsWith('se ')) {
        final resultado = interpretarLinha(comando);
        if (resultado.trim().isNotEmpty && adicionarMensagem != null) {
          adicionarMensagem(resultado);
        }
      } else {
        // Não renderiza texto puro fora de diga
        // Se quiser permitir, descomente abaixo:
        // String conteudo = comando;
        // if (conteudo.startsWith('"') && conteudo.endsWith('"')) {
        //   conteudo = conteudo.substring(1, conteudo.length - 1);
        // }
        // if (conteudo.isNotEmpty) {
        //   if (adicionarWidget != null) {
        //     adicionarWidget(Text(conteudo, style: TextStyle(fontSize: 16, color: _corTexto)));
        //   }
        //   if (adicionarMensagem != null) {
        //     adicionarMensagem(conteudo);
        //   }
        // }
      }
    }
    return saida.trim();
  }

  List<String> _splitComandosPorPontoEVirgula(String texto) {
    List<String> comandos = [];
    int nivelChave = 0;
    StringBuffer atual = StringBuffer();
    for (int i = 0; i < texto.length; i++) {
      final c = texto[i];
      if (c == '{') nivelChave++;
      if (c == '}') nivelChave--;
      if (c == ';' && nivelChave == 0) {
        comandos.add(atual.toString());
        atual.clear();
      } else {
        atual.write(c);
      }
    }
    if (atual.isNotEmpty) comandos.add(atual.toString());
    return comandos;
  }

  String _interpretarSeBloco(String comando, {void Function(Widget)? adicionarWidget, void Function(String)? adicionarMensagem}) {
    // Parsing manual para suportar blocos aninhados e múltiplos comandos
    // Exemplo: Se (x == 3) {diga verdadeiro; diga funcionando} senao {diga falso}
    int i = 0;
    // 1. Encontrar início e fim da condição entre parênteses
    while (i < comando.length && comando[i].toLowerCase() != 's') i++; // Pula até 'S' ou 's'
    while (i < comando.length && comando[i] != '(') i++;
    if (i >= comando.length) return 'Erro: sintaxe do Se inválida.';
    int iniCond = i + 1;
    int nivelPar = 1;
    int fimCond = iniCond;
    while (fimCond < comando.length && nivelPar > 0) {
      if (comando[fimCond] == '(') nivelPar++;
      if (comando[fimCond] == ')') nivelPar--;
      fimCond++;
    }
    if (nivelPar != 0) return 'Erro: parênteses da condição não fechados.';
    String condicao = comando.substring(iniCond, fimCond - 1).trim();
    // 2. Encontrar bloco verdadeiro entre chaves
    while (fimCond < comando.length && comando[fimCond] != '{') fimCond++;
    if (fimCond >= comando.length) return 'Erro: bloco verdadeiro não encontrado.';
    int iniBlocoV = fimCond + 1;
    int nivelChave = 1;
    int fimBlocoV = iniBlocoV;
    while (fimBlocoV < comando.length && nivelChave > 0) {
      if (comando[fimBlocoV] == '{') nivelChave++;
      if (comando[fimBlocoV] == '}') nivelChave--;
      fimBlocoV++;
    }
    if (nivelChave != 0) return 'Erro: bloco verdadeiro não fechado.';
    String blocoVerdadeiro = comando.substring(iniBlocoV, fimBlocoV - 1).trim();
    // 3. Procurar por 'senao' após bloco verdadeiro
    int idxSenao = comando.toLowerCase().indexOf('senao', fimBlocoV);
    String blocoFalso = '';
    if (idxSenao != -1) {
      int iSenao = idxSenao + 5;
      while (iSenao < comando.length && comando[iSenao] != '{') iSenao++;
      if (iSenao >= comando.length) return 'Erro: bloco senao não encontrado.';
      int iniBlocoF = iSenao + 1;
      int nivelChaveF = 1;
      int fimBlocoF = iniBlocoF;
      while (fimBlocoF < comando.length && nivelChaveF > 0) {
        if (comando[fimBlocoF] == '{') nivelChaveF++;
        if (comando[fimBlocoF] == '}') nivelChaveF--;
        fimBlocoF++;
      }
      if (nivelChaveF != 0) return 'Erro: bloco senao não fechado.';
      blocoFalso = comando.substring(iniBlocoF, fimBlocoF - 1).trim();
    }
    // Avalia a condição
    bool resultadoCondicao = _avaliarCondicao(condicao);
    if (resultadoCondicao) {
      return interpretarBlocoSintaxeNova(blocoVerdadeiro, adicionarWidget: adicionarWidget, adicionarMensagem: adicionarMensagem);
    } else if (blocoFalso.isNotEmpty) {
      return interpretarBlocoSintaxeNova(blocoFalso, adicionarWidget: adicionarWidget, adicionarMensagem: adicionarMensagem);
    } else {
      return '';
    }
  }

  // Avalia uma condição simples do tipo 'x == 3', 'y > 2', etc.
  bool _avaliarCondicao(String condicao) {
    condicao = condicao.trim();
    // Suporta operadores ==, !=, >, <, >=, <=
    final operadores = ['==', '!=', '>=', '<=', '>', '<'];
    for (var op in operadores) {
      int idx = condicao.indexOf(op);
      if (idx != -1) {
        String esquerda = condicao.substring(0, idx).trim();
        String direita = condicao.substring(idx + op.length).trim();
        // Tenta converter para número, senão compara como string
        var valEsq = num.tryParse(esquerda) ?? variaveis[esquerda] ?? esquerda;
        var valDir = num.tryParse(direita) ?? variaveis[direita] ?? direita;
        switch (op) {
          case '==':
            return valEsq.toString() == valDir.toString();
          case '!=':
            return valEsq.toString() != valDir.toString();
          case '>':
            return (valEsq is num && valDir is num) ? valEsq > valDir : false;
          case '<':
            return (valEsq is num && valDir is num) ? valEsq < valDir : false;
          case '>=':
            return (valEsq is num && valDir is num) ? valEsq >= valDir : false;
          case '<=':
            return (valEsq is num && valDir is num) ? valEsq <= valDir : false;
        }
      }
    }
    // Se não encontrou operador, tenta avaliar como booleano
    if (variaveis.containsKey(condicao)) {
      return variaveis[condicao] == true || variaveis[condicao] == 'verdadeiro' || variaveis[condicao] == 'true';
    }
    return condicao.toLowerCase() == 'verdadeiro' || condicao == 'true';
  }
}
