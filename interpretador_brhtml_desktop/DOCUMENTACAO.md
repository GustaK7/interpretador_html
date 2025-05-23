# Documentação da Linguagem BRDart

## Introdução
A linguagem BRDart é uma linguagem interpretada, inspirada em pseudocódigo e voltada para fins didáticos e prototipagem rápida de lógica e interface. Ela permite a definição de variáveis, operações matemáticas, condicionais, repetição e widgets visuais (caixas e textos coloridos).

---

## Sintaxe Básica

### 1. Definição de Variáveis
```
define nome = valor;
```
Exemplo:
```
define x = 5;
define y = 3;
define resultado = soma x y;
```

### 2. Operações Matemáticas
- `soma <a> <b>`: Soma dois valores
- `subtrai <a> <b>`: Subtrai o segundo valor do primeiro
- `multiplica <a> <b>`: Multiplica dois valores
- `divide <a> <b>`: Divide o primeiro valor pelo segundo
- `resto <a> <b>`: Resto da divisão inteira

Exemplo:
```
define total = soma x y;
```

### 3. Exibir Mensagens
- `diga "mensagem";` — Exibe uma mensagem
- Suporta concatenação: `diga "Resultado: " resultado;`

### 4. Mostrar Valor de Variável
- `mostre nome;` — Exibe o valor de uma variável

### 5. Estruturas de Decisão
```
Se (condição) {
  comandos;
} senao {
  comandos;
}
```
- Operadores suportados: `==`, `!=`, `>`, `<`, `>=`, `<=`
- Exemplo:
```
Se (resultado > 7) {
  diga "Maior que 7";
} senao {
  diga "Não é maior que 7";
}
```

### 6. Estruturas de Repetição
- `repita <n> <comando>;` — Repete o comando n vezes

Exemplo:
```
repita 3 diga "Oi!";
```

---

## Widgets Visuais

### 1. Caixa (box)
Cria uma caixa colorida que pode conter outros widgets ou textos.
```
box{
  cor.box verde;
  texto{
    cor.texto branco;
    "Texto dentro da caixa";
  }
}
```

### 2. Texto (texto/text)
Exibe um texto, podendo definir a cor dentro do bloco.
```
texto{
  cor.texto amarelo;
  "Mensagem colorida";
}
```

#### Cores disponíveis
- azul, verde, vermelho, amarelo, preto, branco, cinza, laranja, roxo, rosa

---

## Observações
- Use ponto e vírgula (;) para separar comandos, inclusive dentro de blocos com chaves.
- Comandos podem ser aninhados em widgets e condicionais.
- O interpretador aceita tanto `texto{}` quanto `text{}`.

---

## Exemplo Completo
```
define x = 2;
define y = 6;
define resultado = soma x y;
diga "O resultado de x + y é: ";
diga "resultado = " resultado;

Se (resultado > 7) {
  box{
    cor.box verde;
    texto{
      cor.texto branco;
      "O resultado é maior que 7";
    }
  }
} senao {
  box{
    cor.box vermelho;
    texto{
      cor.texto branco;
      "O resultado NÃO é maior que 7";
    }
  }
}
```

---

## Erros Comuns
- Esquecer o ponto e vírgula entre comandos.
- Não fechar blocos com chaves corretamente.
- Usar nomes de variáveis não definidos.
- Sintaxe incorreta em condicionais ou widgets.

---

## Licença
Este interpretador é fornecido para fins educacionais e prototipagem.
