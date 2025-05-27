import 'package:flutter/material.dart';

class SyntaxHighlightingEditor extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int? maxLines;
  final int? minLines;

  const SyntaxHighlightingEditor({
    super.key,
    required this.controller,
    this.hintText = 'Digite seus comandos BRDart aqui...',
    this.maxLines,
    this.minLines = 5,
  });

  @override
  State<SyntaxHighlightingEditor> createState() => _SyntaxHighlightingEditorState();
}

class _SyntaxHighlightingEditorState extends State<SyntaxHighlightingEditor> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  // Cores do tema (baseado no VS Code Dark Theme)
  static const Color _backgroundColor = Color(0xFF1E1E1E);
  static const Color _textColor = Color(0xFFD4D4D4);
  static const Color _keywordColor = Color(0xFF569CD6);
  static const Color _stringColor = Color(0xFFCE9178);
  static const Color _numberColor = Color(0xFFB5CEA8);
  static const Color _commentColor = Color(0xFF6A9955);
  static const Color _operatorColor = Color(0xFFD4D4D4);
  static const Color _functionColor = Color(0xFFDCDCAA);
  static const Color _variableColor = Color(0xFF9CDCFE);
  static const Color _braceColor = Color(0xFFDA70D6);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      // Força rebuild para atualizar o syntax highlighting
    });
  }

  List<TextSpan> _highlightText(String text) {
    if (text.isEmpty) return [];

    List<TextSpan> spans = [];
    // Regex para capturar diferentes tipos de tokens
    final RegExp tokenRegex = RegExp(
      r'("(?:[^"\\]|\\.)*")|'  // Strings entre aspas
      r'(\b\d+\.?\d*\b)|'      // Números
      r'(//.*)|'                   // Comentários
      r'(\b(?:define|mostre|diga|repita|Se|se|senao|box|texto|text|cor\.box|cor\.texto)\b)|' // Keywords
      r'(\b(?:soma|subtrai|multiplica|divide|resto)\b)|' // Functions
      r'(\b(?:azul|verde|vermelho|amarelo|preto|branco|cinza|laranja|roxo|rosa)\b)|' // Colors
      r'([{}();])|'                // Delimitadores especiais
      r'(==|!=|>=|<=|>|<|=)|'      // Operadores
      r'(\b[a-zA-Z_][a-zA-Z0-9_]*\b)' // Variáveis/identificadores
    );

    text.splitMapJoin(
      tokenRegex,
      onMatch: (Match match) {
        String matchedText = match.group(0)!;
        Color color = _textColor;
        FontWeight fontWeight = FontWeight.normal;

        if (match.group(1) != null) {
          // String
          color = _stringColor;
        } else if (match.group(2) != null) {
          // Number
          color = _numberColor;
        } else if (match.group(3) != null) {
          // Comment
          color = _commentColor;
          fontWeight = FontWeight.w300;
        } else if (match.group(4) != null) {
          // Keyword
          color = _keywordColor;
          fontWeight = FontWeight.bold;
        } else if (match.group(5) != null) {
          // Function
          color = _functionColor;
          fontWeight = FontWeight.w600;
        } else if (match.group(6) != null) {
          // Color names
          color = _stringColor;
        } else if (match.group(7) != null) {
          // Braces and delimiters
          color = _braceColor;
          fontWeight = FontWeight.bold;
        } else if (match.group(8) != null) {
          // Operators
          color = _operatorColor;
          fontWeight = FontWeight.bold;
        } else if (match.group(9) != null) {
          // Variables/identifiers
          color = _variableColor;
        }

        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(
            color: color,
            fontWeight: fontWeight,
            fontFamily: 'Fira Code',
            fontSize: 14,
          ),
        ));
        return matchedText;
      },
      onNonMatch: (String nonMatch) {
        if (nonMatch.isNotEmpty) {
          spans.add(TextSpan(
            text: nonMatch,
            style: const TextStyle(
              color: _textColor,
              fontFamily: 'Fira Code',
              fontSize: 14,
            ),
          ));
        }
        return nonMatch;
      },
    );

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final lineCount = widget.controller.text.split('\n').length;
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3C3C3C)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gutter de números de linha
          Container(
            width: 40,
            color: const Color(0xFF252526),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                lineCount,
                (index) => Container(
                  height: 20,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF858585),
                      fontFamily: 'Fira Code',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Editor de texto com syntax highlight
          Expanded(
            child: Stack(
              children: [
                TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  style: const TextStyle(
                    color: Colors.transparent,
                    fontFamily: 'Fira Code',
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  cursorColor: Colors.white,
                  scrollController: _scrollController,
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: widget.controller.text.isEmpty
                            ? Text(
                                widget.hintText,
                                style: const TextStyle(
                                  color: Color(0xFF6A6A6A),
                                  fontFamily: 'Fira Code',
                                  fontSize: 14,
                                ),
                              )
                            : RichText(
                                text: TextSpan(
                                  children: _highlightText(widget.controller.text),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}