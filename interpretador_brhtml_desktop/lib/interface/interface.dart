
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../logica/interpretador.dart';
import '../download_helper.dart';
import '../download_helper_web.dart';

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

  Future<String?> importarArquivoBrdart() async {
    if (kIsWeb) {
      return await importarArquivoBrdartWeb();
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['brdart']);
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        return await file.readAsString();
      }
      return null;
    }
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
                  onPressed: () async {
                    final conteudo = await importarArquivoBrdart();
                    if (conteudo != null) {
                      setState(() {
                        _controller.text = conteudo;
                      });
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Importar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
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
