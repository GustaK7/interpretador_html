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
  final InterpretadorBR _interpretador = InterpretadorBR();

  void _executarComando() {
    final texto = _controller.text;
    if (texto.trim().isEmpty) return;
    setState(() {
      final resultado = _interpretador.interpretarLinha(texto);
      _saida.add("> $texto");
      _saida.add(resultado);
    });
    _controller.clear();
  }

  void _limparSaida() {
    setState(() {
      _saida.clear();
    });
  }

  void _mostrarAjuda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda - Exemplos de comandos BRDart'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('diga Olá Mundo!'),
              SizedBox(height: 8),
              Text('soma 2 3'),
              SizedBox(height: 8),
              Text('subtrai 10 4'),
              SizedBox(height: 8),
              Text('multiplica 3 5'),
              SizedBox(height: 8),
              Text('divide 10 2'),
              SizedBox(height: 8),
              Text('resto 10 3'),
              SizedBox(height: 8),
              Text('define nome = João'),
              SizedBox(height: 8),
              Text('mostre nome'),
              SizedBox(height: 8),
              Text('repita 3 diga Olá'),
              SizedBox(height: 8),
              Text('se 2 > 1 diga Verdadeiro'),
              SizedBox(height: 8),
              Text('se nome == João diga Bem-vindo'),
              SizedBox(height: 8),
              Text('se 2 > 3 diga Não senao diga Sim'),
              SizedBox(height: 8),
              Text('se (condição) { comando } senao { comando }  // estrutura moderna'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _leiaVariavel(String nome) async {
    String valor = '';
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _inputController = TextEditingController();
        return AlertDialog(
          title: Text('Digite o valor para "$nome"'),
          content: TextField(
            controller: _inputController,
            autofocus: true,
            decoration: InputDecoration(hintText: 'Valor para $nome'),
            onSubmitted: (_) => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      valor = (ModalRoute.of(context)?.settings.arguments as String?) ?? '';
    });
    setState(() {
      _interpretador.variaveis[nome] = valor;
      _saida.add("Variável '$nome' definida com valor '$valor'.");
    });
  }

  Future<void> _executarComandoTerminal(String texto) async {
    if (texto.trim().isEmpty) return;
    if (texto.trim().startsWith('leia ')) {
      final nome = texto.trim().substring(5).trim();
      await _leiaVariavel(nome);
    } else {
      setState(() {
        final resultado = _interpretador.interpretarLinha(texto);
        _saida.add("> $texto");
        if (resultado.isNotEmpty) _saida.add(resultado);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interpretador BRDart')),
      body: Row(
        children: [
          // Editor de comandos à esquerda
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF1E1E1E),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Editor', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(fontFamily: 'Fira Mono'),
                        decoration: const InputDecoration(
                          hintText: 'Digite seus comandos BRDart aqui...\nExemplo: diga Olá Mundo!',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Color(0xFF252526),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Saída à direita
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF1E1E1E),
              child: Column(
                children: [
                  // Botões no topo
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _executarComando,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Executar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _limparSaida,
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpar'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _mostrarAjuda,
                          icon: const Icon(Icons.help_outline),
                          label: const Text('Ajuda'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Terminal de saída
                  Expanded(
                    child: Container(
                      color: const Color(0xFF1E1E1E),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _saida.length,
                        itemBuilder: (context, index) => Text(
                          _saida[index],
                          style: const TextStyle(fontFamily: 'Fira Mono', fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InterpretadorBR {
  final Map<String, String> variaveis = {};

  String interpretarLinha(String linha) {
    // Suporte a blocos e múltiplos comandos com ponto e vírgula
    List<String> comandos = _splitComandos(linha);
    if (comandos.length > 1) {
      String saida = '';
      for (final cmd in comandos) {
        final resultado = interpretarLinha(cmd);
        // Só adiciona à saída se não for uma atribuição de variável
        if (resultado.isNotEmpty && !resultado.startsWith("Variável ")) {
          if (saida.isNotEmpty) saida += "\n";
          saida += resultado;
        }
      }
      return saida;
    }
    linha = comandos[0].trim();
    // Suporte a blocos entre chaves isolados: { ... }
    if (linha.startsWith('{') && linha.endsWith('}')) {
      // Remove as chaves externas e executa o bloco
      return _splitComandos(linha.substring(1, linha.length - 1)).map(interpretarLinha).where((r) => r.isNotEmpty).join("\n");
    }
    // Novo: suporte ao comando 'se (condicao) { ... } senao { ... }'
    if (linha.startsWith('se ')) {
      // Regex melhorada para blocos aninhados e ponto e vírgula
      final regex = RegExp(r"^se\s*\(([^)]*)\)\s*\{((?:[^{}]|\{[^{}]*\})*)\}(?:\s*senao\s*\{((?:[^{}]|\{[^{}]*\})*)\})?\s*", dotAll: true);
      final match = regex.firstMatch(linha);
      if (match != null) {
        String condicaoStr = match.group(1)?.trim() ?? "";
        String blocoSe = match.group(2)?.trim() ?? "";
        String blocoSenao = match.group(3)?.trim() ?? "";
        // Suporte a variáveis na condição
        final condRegex = RegExp(r"^(.+?)\s*(==|!=|>=|<=|>|<)\s*(.+)");
        final condMatch = condRegex.firstMatch(condicaoStr);
        bool condicao = false;
        if (condMatch != null) {
          String v1 = condMatch.group(1)?.trim() ?? "";
          String op = condMatch.group(2) ?? "";
          String v2 = condMatch.group(3)?.trim() ?? "";
          if (variaveis.containsKey(v1)) v1 = variaveis[v1]!;
          if (variaveis.containsKey(v2)) v2 = variaveis[v2]!;
          final num1 = double.tryParse(v1);
          final num2 = double.tryParse(v2);
          if (num1 != null && num2 != null) {
            switch (op) {
              case '==': condicao = num1 == num2; break;
              case '!=': condicao = num1 != num2; break;
              case '>': condicao = num1 > num2; break;
              case '<': condicao = num1 < num2; break;
              case '>=': condicao = num1 >= num2; break;
              case '<=': condicao = num1 <= num2; break;
            }
          } else {
            switch (op) {
              case '==': condicao = v1 == v2; break;
              case '!=': condicao = v1 != v2; break;
            }
          }
        } else {
          return "Erro: condição inválida.";
        }
        if (condicao) {
          return _splitComandos(blocoSe).map(interpretarLinha).where((r) => r.isNotEmpty).join("\n");
        } else if (blocoSenao.isNotEmpty) {
          return _splitComandos(blocoSenao).map(interpretarLinha).where((r) => r.isNotEmpty).join("\n");
        } else {
          return "";
        }
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
        final a = double.tryParse(tokens[1]);
        final b = double.tryParse(tokens[2]);
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
      // Suporte a atribuição direta: x = 3
      case "x":
        if (tokens.length == 3 && tokens[1] == "=") {
          variaveis["x"] = tokens[2];
          return "Variável 'x' definida com valor '${tokens[2]}'";
        }
        break;

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

      case "leia":
        if (tokens.length != 2) return "Erro: use 'leia nome'.";
        final nomeVariavel = tokens[1];
        return "Aguardando entrada para '$nomeVariavel'. Use o método apropriado para definir o valor.";

      default:
        return "Comando desconhecido: $comando";
    }
    return "";
  }

  List<String> _splitComandos(String linha) {
    List<String> comandos = [];
    int nivel = 0;
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < linha.length; i++) {
      final char = linha[i];
      if (char == '{') {
        nivel++;
        buffer.write(char);
      } else if (char == '}') {
        nivel--;
        buffer.write(char);
      } else if (char == ';' && nivel == 0) {
        comandos.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    if (buffer.isNotEmpty) {
      comandos.add(buffer.toString().trim());
    }
    return comandos;
  }
}
