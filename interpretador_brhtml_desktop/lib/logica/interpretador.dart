import 'package:flutter/material.dart';

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
      String novaCor = linha.substring(8).trim().replaceAll('=', '').trim();
      Color? cor = _parseCor(novaCor);
      if (cor != null) {
        _corBox = cor;
        return 'Cor da box alterada para $novaCor';
      } else {
        return 'Cor inválida: $novaCor';
      }
    } else if (linha.startsWith('cor.texto')) {
      // Comando de mudança de cor para texto
      String novaCor = linha.substring(10).trim().replaceAll('=', '').trim();
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
      
      // Se o conteudo não está entre aspas, não faz nada
      if (!conteudo.startsWith('"') || !conteudo.endsWith('"')) {
        return ''; // Retorna vazio para não mostrar no terminal
      }
      
      String resultado = conteudo.substring(1, conteudo.length - 1); // Remove aspas
      
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
        return ''; // Não retorna erro para evitar mensagens desnecessárias
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
      adicionarMensagem: (msg) {}, // Não adiciona mensagens aqui
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
  }

  // Refatoração: Uso da função auxiliar no parseWidget
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
          String novaCor = linha.substring(9).trim().replaceAll('=', '').trim();
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
        // Comando Se/se - só adiciona mensagem se houver resultado
        String resultado = _interpretarSeBloco(comando, adicionarWidget: adicionarWidget, adicionarMensagem: adicionarMensagem);
        if (resultado.trim().isNotEmpty) {
          saida += resultado + '\n';
        }
      } else if (comando.startsWith('box{') || comando.startsWith('texto{') || comando.startsWith('text{')) {
        // Widgets - não adiciona mensagem no terminal
        try {
          final widget = _parseWidget(comando);
          if (adicionarWidget != null) adicionarWidget(widget);
        } catch (e) {
          if (adicionarMensagem != null) adicionarMensagem('Erro ao interpretar widget: $e');
        }
      } else if (comando.startsWith('cor.box') || comando.startsWith('cor.texto')) {
        // Comandos de cor - só adiciona mensagem se houver resultado válido
        final resultado = interpretarLinha(comando);
        if (resultado.trim().isNotEmpty && !resultado.startsWith('Cor inválida') && adicionarMensagem != null) {
          adicionarMensagem(resultado);
        }
      } else if (comando.startsWith('diga')) {
        // Comando diga - só renderiza se entre aspas
        String conteudo = comando.substring(4).trim();
        if (conteudo.startsWith('"') && conteudo.endsWith('"')) {
          conteudo = conteudo.substring(1, conteudo.length - 1);
          if (conteudo.isNotEmpty) {
            if (adicionarWidget != null) {
              adicionarWidget(Text(conteudo, style: TextStyle(fontSize: 16, color: _corTexto)));
            }
            // NÃO adiciona mensagem no terminal para comando diga
          }
        }
        // Se não estiver entre aspas, não faz nada
      } else if (comando.startsWith('define') || comando.startsWith('mostre') || comando.startsWith('repita')) {
        // Comandos que devem aparecer no terminal
        final resultado = interpretarLinha(comando);
        if (resultado.trim().isNotEmpty && adicionarMensagem != null) {
          adicionarMensagem(resultado);
        }
      } else if (comando.startsWith('"') && comando.endsWith('"')) {
        // Texto puro entre aspas - ignora
        continue;
      } else {
        // Outros comandos - tenta interpretar mas não mostra erro no terminal
        final resultado = interpretarLinha(comando);
        // Só adiciona no terminal se for um resultado válido (não vazio e não erro)
        if (resultado.trim().isNotEmpty && 
            !resultado.startsWith('Erro') && 
            resultado.startsWith('Resultado:') && 
            adicionarMensagem != null) {
          adicionarMensagem(resultado);
        }
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
      return variaveis[condicao] == 'true' || variaveis[condicao] == 'verdadeiro';
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