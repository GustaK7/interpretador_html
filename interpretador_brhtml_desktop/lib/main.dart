import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'download_helper.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'download_helper_web.dart' if (dart.library.io) 'dart:io';

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
                  onPressed: () async {
                    // Pergunta o nome do arquivo ao usuário
                    String? nome = await showDialog<String>(
                      context: context,
                      builder: (ctx) {
                        final controller = TextEditingController(text: 'meu_projeto.brdart');
                        return AlertDialog(
                          title: const Text('Salvar código como'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: 'Nome do arquivo',
                              hintText: 'ex: meu_projeto.brdart',
                            ),
                            autofocus: true,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                String nome = controller.text.trim();
                                if (!nome.endsWith('.brdart')) nome += '.brdart';
                                Navigator.of(ctx).pop(nome);
                              },
                              child: const Text('Salvar'),
                            ),
                          ],
                        );
                      },
                    );
                    if (nome != null && nome.isNotEmpty) {
                      final codigo = _controller.text;
                      await downloadCodigoBrdart(codigo, nome);
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
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
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                String doc;
                try {
                  if (kIsWeb) {
                    doc = await rootBundle.loadString('DOCUMENTACAO.md');
                  } else {
                    final file = File('DOCUMENTACAO.md');
                    doc = await file.readAsString();
                  }
                } catch (_) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Erro'),
                      content: const Text('Arquivo DOCUMENTACAO.md não encontrado.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Fechar'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                // Diálogo para exportar apenas como TXT
                bool? confirmar = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Exportar documentação'),
                    content: const Text('Deseja exportar a documentação como arquivo TXT?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Exportar TXT'),
                      ),
                    ],
                  ),
                );
                if (confirmar == true) {
                  await downloadOrShowDoc(
                    doc,
                    showDialogDesktop: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Documentação BRDart'),
                          content: SizedBox(
                            width: 500,
                            height: 500,
                            child: SingleChildScrollView(
                              child: SelectableText(doc, style: const TextStyle(fontFamily: 'Fira Mono', fontSize: 13)),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Fechar'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
              icon: const Icon(Icons.menu_book),
              label: const Text('Ver documentação'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        const SizedBox(height: 8),
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

  Future<void> downloadCodigoBrdart(String codigo, String nomeArquivo) async {
    if (kIsWeb) {
      await downloadFileWeb(codigo, nomeArquivo);
    } else {
      final file = File(nomeArquivo);
      await file.writeAsString(codigo);
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Arquivo salvo'),
          content: Text('Arquivo salvo como: $nomeArquivo'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }
  }
}

class InterpretadorBR {
  final Map<String, String> variaveis = {};
  Color _corBox = Colors.blueGrey.shade900;
  Color _corTexto = Colors.amber;

  void setAdicionarMensagemGlobal(void Function(String) fn) {
    // Não faz nada, compatibilidade
  }

  // Corrige escopo: garantir que interpretarLinha está definido antes de ser usado
  String interpretarLinha(String linha, {void Function(Widget)? adicionarWidget}) {
    linha = linha.trim();
    if (linha.startsWith('cor.box')) {
      // Comando de mudança de cor para box
      String novaCor = linha.substring(8).trim();
      Color? cor = _parseCor(novaCor);
      if (cor != null) {
        _corBox = cor;
        return 'Cor da box alterada para $novaCor';
      } else {
        return 'Cor inválida: $novaCor';
      }
    } else if (linha.startsWith('cor.texto')) {
      // Comando de mudança de cor para texto
      String novaCor = linha.substring(10).trim();
      Color? cor = _parseCor(novaCor);
      if (cor != null) {
        _corTexto = cor;
        return 'Cor do texto alterada para $novaCor';
      } else {
        return 'Cor inválida: $novaCor';
      }
    } else if (linha.startsWith('define')) {
      // Comando de definição de variável
      final partes = linha.split('=');
      if (partes.length == 2) {
        final nome = partes[0].substring(6).trim();
        final valor = partes[1].trim();
        // Tenta avaliar expressão matemática ao definir variável
        dynamic valorAvaliado;
        try {
          valorAvaliado = _avaliarExpressao(valor);
        } catch (e) {
          valorAvaliado = valor;
        }
        variaveis[nome] = valorAvaliado.toString();
        return 'Variável $nome definida como ${variaveis[nome]}';
      } else {
        return 'Erro na definição da variável. Sintaxe: define <nome> = <valor>';
      }
    } else if (linha.startsWith('mostre')) {
      // Comando para mostrar valor de variável
      final nome = linha.substring(7).trim();
      if (variaveis.containsKey(nome)) {
        return 'Valor de $nome: ${variaveis[nome]}';
      } else {
        return 'Variável $nome não definida';
      }
    } else if (linha.startsWith('repita')) {
      // Comando de repetição
      final partes = linha.split(' ');
      if (partes.length >= 3) {
        final vezes = partes[1];
        final comando = partes.sublist(2).join(' ');
        return 'Repetindo $comando por $vezes vezes';
      } else {
        return 'Erro na sintaxe do comando repita. Exemplo: repita <n> <comando>';
      }
    } else if (linha.startsWith('diga')) {
      // Suporte a concatenação: diga "texto" variavel;
      String conteudo = linha.substring(4).trim();
      String resultado = '';
      final regex = RegExp(r'"([^"]*)"|([^\s]+)');
      final matches = regex.allMatches(conteudo);
      for (final match in matches) {
        if (match.group(1) != null) {
          resultado += match.group(1)!;
        } else if (match.group(2) != null) {
          final varName = match.group(2)!;
          resultado += variaveis.containsKey(varName) ? variaveis[varName]! : varName;
        }
      }
      if (adicionarWidget != null) {
        adicionarWidget(Text(resultado, style: TextStyle(fontSize: 16, color: _corTexto)));
      }
      return resultado;
    } else {
      // Comandos aritméticos e lógicos simples
      try {
        final resultado = _avaliarExpressao(linha);
        return 'Resultado: $resultado';
      } catch (e) {
        return 'Erro ao avaliar expressão: $e';
      }
    }
  }

  // Novo: interpreta blocos aninhados e comandos de cor
  String interpretarBloco(String bloco, {void Function(Widget)? adicionarWidget, void Function(String)? adicionarMensagem}) {
    bloco = bloco.trim();
    if (bloco.startsWith('box{')) {
      final inner = _extrairBloco(bloco.substring(3).trim());
      final widget = _interpretarWidgetBloco(inner: inner, cor: _corBox, isBox: true);
      adicionarWidget?.call(widget);
      return '';
    } else if (bloco.startsWith('text{') || bloco.startsWith('texto{')) {
      final inner = bloco.startsWith('text{')
          ? _extrairBloco(bloco.substring(4).trim())
          : _extrairBloco(bloco.substring(5).trim());
      final widget = _interpretarWidgetBloco(inner: inner, cor: _corTexto, isBox: false);
      if (adicionarWidget != null) {
        adicionarWidget(widget);
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

  // Refatoração: Função auxiliar para interpretar blocos de widget (box/texto)
  Widget _interpretarWidgetBloco({
    required String inner,
    required Color cor,
    required bool isBox,
  }) {
    final List<Widget> filhos = [];
    interpretarBlocoSintaxeNova(
      inner,
      adicionarWidget: (w) {
        // Só adiciona widgets visuais reais (ignora SizedBox.shrink)
        if (!(w is SizedBox && w.width == 0 && w.height == 0)) {
          filhos.add(w);
        }
      },
      adicionarMensagem: (msg) {},
    );
    Widget? child;
    if (filhos.isNotEmpty) {
      child = filhos.length == 1 ? filhos.first : Column(crossAxisAlignment: CrossAxisAlignment.start, children: filhos);
    } else {
      child = const SizedBox.shrink();
    }
    if (isBox) {
      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
    } else {
      return child;
    }
  }  // Refatoração: Uso da função auxiliar no parseWidget
  Widget _parseWidget(String input) {
    input = input.trim();
    if (input.startsWith('box{')) {
      final inner = _extrairBloco(input.substring(3).trim());
      return _interpretarWidgetBloco(inner: inner, cor: _corBox, isBox: true);
    } else if (input.startsWith('texto{') || input.startsWith('text{')) {
      final inner = input.startsWith('texto{') 
          ? _extrairBloco(input.substring(5).trim())
          : _extrairBloco(input.substring(4).trim());
      
      // Procura por texto entre aspas e comandos de cor
      List<String> linhas = inner.split(';');
      Color? corTexto;
      String texto = '';
      
      for (var linha in linhas) {
        linha = linha.trim();
        if (linha.startsWith('cor.texto')) {
          String novaCor = linha.substring(9).trim();
          corTexto = _parseCor(novaCor);
        } else if (linha.startsWith('"') && linha.endsWith('"')) {
          texto = linha.substring(1, linha.length - 1);
        }
      }
      
      return Text(
        texto,
        style: TextStyle(
          fontSize: 16,
          color: corTexto ?? _corTexto,
        ),
      );
    } else {
      throw 'Bloco desconhecido: $input';
    }
  }

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
        }      } else {
        // Ignora texto puro que não seja parte do comando 'diga'
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
        
        // Obtém os valores das variáveis se existirem
        String valorEsquerda = variaveis.containsKey(esquerda) ? variaveis[esquerda]! : esquerda;
        String valorDireita = variaveis.containsKey(direita) ? variaveis[direita]! : direita;

        // Tenta converter para números se possível
        num? numEsq = num.tryParse(valorEsquerda);
        num? numDir = num.tryParse(valorDireita);
        
        // Se ambos são números, compara numericamente
        if (numEsq != null && numDir != null) {
          switch (op) {
            case '==': return numEsq == numDir;
            case '!=': return numEsq != numDir;
            case '>': return numEsq > numDir;
            case '<': return numEsq < numDir;
            case '>=': return numEsq >= numDir;
            case '<=': return numEsq <= numDir;
          }
        } else {
          // Se não são números, compara como strings
          switch (op) {
            case '==': return valorEsquerda == valorDireita;
            case '!=': return valorEsquerda != valorDireita;
            case '>': return valorEsquerda.compareTo(valorDireita) > 0;
            case '<': return valorEsquerda.compareTo(valorDireita) < 0;
            case '>=': return valorEsquerda.compareTo(valorDireita) >= 0;
            case '<=': return valorEsquerda.compareTo(valorDireita) <= 0;
          }
        }
      }
    }
    
    // Se não encontrou operador, tenta avaliar como booleano
    if (variaveis.containsKey(condicao)) {
      return variaveis[condicao] == true || variaveis[condicao] == 'verdadeiro' || variaveis[condicao] == 'true';
    }
    return condicao.toLowerCase() == 'verdadeiro' || condicao == 'true';
  }

  // Implementação dos comandos matemáticos e avaliação de expressões simples
  dynamic _avaliarExpressao(String linha) {
    final partes = linha.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty) throw 'Expressão vazia';
    String comando = partes[0].toLowerCase();
    num? valorA, valorB;
    // Função auxiliar para obter valor numérico ou variável
    num _parseValor(String s) {
      if (variaveis.containsKey(s)) {
        return num.tryParse(variaveis[s]!) ?? (throw 'Variável $s não é numérica');
      }
      return num.tryParse(s) ?? (throw 'Valor inválido: $s');
    }
    switch (comando) {
      case 'soma':
        if (partes.length < 3) throw 'Uso: soma <a> <b>';
        valorA = _parseValor(partes[1]);
        valorB = _parseValor(partes[2]);
        return valorA + valorB;
      case 'subtrai':
        if (partes.length < 3) throw 'Uso: subtrai <a> <b>';
        valorA = _parseValor(partes[1]);
        valorB = _parseValor(partes[2]);
        return valorA - valorB;
      case 'multiplica':
        if (partes.length < 3) throw 'Uso: multiplica <a> <b>';
        valorA = _parseValor(partes[1]);
        valorB = _parseValor(partes[2]);
        return valorA * valorB;
      case 'divide':
        if (partes.length < 3) throw 'Uso: divide <a> <b>';
        valorA = _parseValor(partes[1]);
        valorB = _parseValor(partes[2]);
        if (valorB == 0) throw 'Divisão por zero';
        return valorA / valorB;
      case 'resto':
        if (partes.length < 3) throw 'Uso: resto <a> <b>';
        valorA = _parseValor(partes[1]);
        valorB = _parseValor(partes[2]);
        if (valorB == 0) throw 'Divisão por zero';
        return valorA % valorB;
      default:
        throw 'Comando ou expressão desconhecida: $linha';
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
}
