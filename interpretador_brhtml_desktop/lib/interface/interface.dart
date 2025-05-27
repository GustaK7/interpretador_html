import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import '../logica/interpretador.dart';
import '../download_helper.dart';
import '../download_helper_web.dart' if (dart.library.io) '../download_helper_io.dart' show importarArquivoBrdartWeb, downloadFileWeb;
import '../interface/syntax_highlighting_editor.dart'; // Importando o componente separado

class InterpretadorHome extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  const InterpretadorHome({super.key, required this.isDark, required this.onToggleTheme});

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
            _CustomMenuBar(
              onImport: () async {
                final conteudo = await importarArquivoBrdart();
                if (conteudo != null) {
                  setState(() {
                    _controller.text = conteudo;
                  });
                }
              },
              onExport: () async {
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
              onCopy: () {
                final selection = _controller.selection;
                if (!selection.isCollapsed) {
                  final selectedText = _controller.text.substring(selection.start, selection.end);
                  Clipboard.setData(ClipboardData(text: selectedText));
                }
              },
              onPaste: () async {
                final data = await Clipboard.getData('text/plain');
                if (data?.text != null) {
                  final selection = _controller.selection;
                  final newText = _controller.text.replaceRange(selection.start, selection.end, data!.text!);
                  _controller.value = _controller.value.copyWith(
                    text: newText,
                    selection: TextSelection.collapsed(offset: selection.start + data.text!.length),
                  );
                }
              },
              onCut: () {
                final selection = _controller.selection;
                if (!selection.isCollapsed) {
                  final selectedText = _controller.text.substring(selection.start, selection.end);
                  Clipboard.setData(ClipboardData(text: selectedText));
                  final newText = _controller.text.replaceRange(selection.start, selection.end, '');
                  _controller.value = _controller.value.copyWith(
                    text: newText,
                    selection: TextSelection.collapsed(offset: selection.start),
                  );
                }
              },
              onSelectAll: () {
                _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
              },
              onSearch: () {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    final searchController = TextEditingController();
                    return AlertDialog(
                      title: const Text('Pesquisar no código'),
                      content: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(hintText: 'Digite a palavra para pesquisar'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            final query = searchController.text;
                            if (query.isNotEmpty) {
                              final text = _controller.text;
                              final index = text.indexOf(query);
                              if (index != -1) {
                                _controller.selection = TextSelection(baseOffset: index, extentOffset: index + query.length);
                              }
                            }
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Pesquisar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancelar'),
                        ),
                      ],
                    );
                  },
                );
              },
              onToggleTheme: widget.onToggleTheme,
              isDark: widget.isDark,
              onShowHelp: _alternarAjuda,
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.play_arrow, size: 32, color: Colors.green),
              tooltip: 'Executar código',
              onPressed: _executarComando,
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
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Editor', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7FA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: SyntaxHighlightingEditor(
                            controller: _controller,
                            hintText: 'Digite seus comandos BRDart aqui...',
                            maxLines: null,
                            minLines: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          // Saída à direita
          Expanded(
            flex: 2,
            child: Container(
              color: Theme.of(context).canvasColor,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _saida.length,
                          itemBuilder: (context, index) => Text(
                            _saida[index],
                            style: TextStyle(fontFamily: 'Fira Mono', fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        ),
                        if (_widgetsDinamicos.isNotEmpty)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ..._widgetsDinamicos,
                              ],
                            ),
                          ),
                        if (_ajudaAberta)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 350,
                              color: Theme.of(context).dialogBackgroundColor,
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  children: [
                                    Container(
                                      color: Theme.of(context).appBarTheme.backgroundColor,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Ajuda BRDart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).appBarTheme.foregroundColor)),
                                          IconButton(
                                            icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
                                            onPressed: _alternarAjuda,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(height: 1, color: Theme.of(context).dividerColor),
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
      bottomNavigationBar: Container(
        width: double.infinity,
        color: Theme.of(context).canvasColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Terminal', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color)),
                  ..._mensagens.map((msg) => Text(msg, style: TextStyle(fontFamily: 'Fira Mono', color: Theme.of(context).brightness == Brightness.dark ? Colors.greenAccent : Colors.green[800], fontSize: 14))),
                ],
              ),
            ),
            Tooltip(
              message: 'Limpar terminal',
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Limpar terminal',
                onPressed: _limparSaida,
              ),
            ),
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
    ); // Corrigido: fecha com parêntese e ponto e vírgula
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

class _CustomMenuBar extends StatelessWidget {
  final VoidCallback onImport;
  final VoidCallback onExport;
  final VoidCallback onCopy;
  final VoidCallback onPaste;
  final VoidCallback onCut;
  final VoidCallback onSelectAll;
  final VoidCallback onSearch;
  final VoidCallback onToggleTheme;
  final bool isDark;
  final VoidCallback onShowHelp;

  const _CustomMenuBar({
    required this.onImport,
    required this.onExport,
    required this.onCopy,
    required this.onPaste,
    required this.onCut,
    required this.onSelectAll,
    required this.onSearch,
    required this.onToggleTheme,
    required this.isDark,
    required this.onShowHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MenuTab(
          title: 'Arquivo',
          items: [
            _MenuItem('Importar', onImport),
            _MenuItem('Exportar', onExport),
          ],
        ),
        _MenuTab(
          title: 'Editar',
          items: [
            _MenuItem('Copiar', onCopy),
            _MenuItem('Colar', onPaste),
            _MenuItem('Cortar', onCut),
          ],
        ),
        _MenuTab(
          title: 'Seleção',
          items: [
            _MenuItem('Selecionar tudo', onSelectAll),
            _MenuItem('Pesquisar', onSearch),
          ],
        ),
        _MenuTab(
          title: 'Exibir',
          items: [
            _MenuItem(isDark ? 'Modo claro' : 'Modo escuro', onToggleTheme),
          ],
        ),
        _MenuTab(
          title: 'Ajuda',
          items: [
            _MenuItem('Ajuda', onShowHelp),
          ],
        ),
      ],
    );
  }
}

class _MenuTab extends StatefulWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuTab({required this.title, required this.items});

  @override
  State<_MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<_MenuTab> {
  OverlayEntry? _overlayEntry;
  bool _expanded = false;

  void _showMenu() {
    if (_expanded) return;
    _expanded = true;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + renderBox.size.height,
        child: MouseRegion(
          onExit: (_) => _hideMenu(),
          child: Material(
            elevation: 4,
            color: Theme.of(context).canvasColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.items.map((item) => InkWell(
                onTap: () {
                  item.onTap();
                  _hideMenu();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(item.label),
                ),
              )).toList(),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() {});
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _expanded = false;
    setState(() {});
  }

  @override
  void dispose() {
    _hideMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _expanded ? _hideMenu() : _showMenu(),
      child: Tooltip(
        message: widget.title,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final VoidCallback onTap;

  _MenuItem(this.label, this.onTap);
}

class _CustomMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _CustomMenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}