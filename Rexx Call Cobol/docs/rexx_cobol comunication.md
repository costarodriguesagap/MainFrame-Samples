## Comunicação REXX ↔ COBOL em z/OS (CALL clássico por referência)

Este documento descreve, de forma prática e detalhada, como implementar uma comunicação **REXX → COBOL → REXX** em z/OS usando um **CALL clássico por referência**, em que:

- O REXX constrói uma **área de 200 bytes** em memória.
- Os **primeiros 100 bytes** são considerados **parâmetros de entrada** para o COBOL.
- Os **últimos 100 bytes** são considerados **parâmetros de saída**, preenchidos pelo COBOL.
- Depois da chamada, o REXX lê de volta a **mesma variável** e obtém os valores de saída nos bytes 101–200.

A ideia é idêntica a um *call by reference* entre programas mainframe (COBOL/Assembler), mas com o REXX a participar como chamador.

> ⚠️ Importante: este modelo parte do pressuposto de que o ambiente (LINKMVS/ATTACHMVS) está configurado para passar a variável REXX **por referência** ao módulo COBOL, e que o COBOL pode alterar essa área de memória diretamente.

---

## Layout lógico da área de parâmetros

### Visão conceptual (200 bytes)

- `PARM-BLOCK` (200 bytes):
  - `PARM-IN`  – bytes 1–100  (entrada: REXX → COBOL)
  - `PARM-OUT` – bytes 101–200 (saída: COBOL → REXX)

No COBOL, este layout é expresso na `LINKAGE SECTION`.  
No REXX, é expresso como uma única variável de 200 bytes (string), construída por concatenação.

Não usamos, neste modelo, um campo de comprimento (`S9(4) COMP`) à frente da área – o contrato é puramente “**200 bytes fixos**”.

---

## Programa COBOL – definição da LINKAGE e uso de entrada/saída

### Objetivo do programa COBOL

- Receber um bloco de 200 bytes.
- Interpretar os primeiros 100 bytes (`PARM-IN`) como dados de entrada.
- Preencher os últimos 100 bytes (`PARM-OUT`) com dados de saída que serão lidos pelo REXX após o retorno.

### Código COBOL (exemplo explicativo)

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PGMCOB1.

       DATA DIVISION.
       LINKAGE SECTION.
       01  PARM-BLOCK.
           05 PARM-IN   PIC X(100).   *> Entrada  (bytes   1–100)
           05 PARM-OUT  PIC X(100).   *> Saída    (bytes 101–200)

       PROCEDURE DIVISION USING PARM-BLOCK.

       MAIN-SECTION.
           ****************************************************************
           * PARM-IN:
           *   - Contém os 100 bytes iniciais enviados pelo REXX.
           *   - Ex.: campos de código, tipo de operação, datas, etc.
           *
           * PARM-OUT:
           *   - Será preenchido pelo COBOL com informação de saída.
           *   - O REXX lerá estes 100 bytes após o retorno do GOBACK.
           ****************************************************************

           ****************************************************************
           * Exemplo de processamento
           * (substitua por lógica real de negócio)
           ****************************************************************

           *> Limpar a área de saída para evitar lixo residual
           MOVE SPACES        TO PARM-OUT.

           *> Exemplo simples:
           *> - Copiar os primeiros 20 bytes de PARM-IN para o início de PARM-OUT
           MOVE PARM-IN(1:20) TO PARM-OUT(1:20).

           *> - Colocar uma marca textual para demonstrar que o COBOL alterou a área
           MOVE 'OK-DO-COBOL' TO PARM-OUT(21:11).

           *> Neste ponto, os bytes 101–200 (PARM-OUT) já estão atualizados
           *> e serão visíveis para o REXX quando o programa retornar.

           GOBACK.
```

### Explicação passo a passo do COBOL

- **`LINKAGE SECTION` / `PARM-BLOCK`**:
  - Declara a área de memória que **não pertence** ao programa COBOL, mas que lhe é “emprestada” pelo chamador.
  - `PARM-IN` e `PARM-OUT` são apenas duas visões lógicas sobre a mesma área de 200 bytes:
    - `PARM-IN` corresponde aos bytes 1–100.
    - `PARM-OUT` corresponde aos bytes 101–200.

- **`PROCEDURE DIVISION USING PARM-BLOCK`**:
  - Indica que o COBOL irá receber, por referência, um único parâmetro (`PARM-BLOCK`), vindo da rotina chamadora.

- **`MOVE SPACES TO PARM-OUT`**:
  - Zera os bytes 101–200, garantindo que não ficam restos de chamadas anteriores ou lixo de memória.

- **`MOVE PARM-IN(1:20) TO PARM-OUT(1:20)`**:
  - Exemplo didático: copia os primeiros 20 bytes de entrada para os primeiros 20 bytes de saída.
  - Na prática, aqui estaria a lógica de negócio que calcula os dados de saída.

- **`MOVE 'OK-DO-COBOL' TO PARM-OUT(21:11)`**:
  - Coloca um texto identificador dentro da área de saída, para ser visível no REXX.

- **`GOBACK`**:
  - Retorna ao chamador.
  - Como `PARM-BLOCK` é passado por referência, todas as modificações em `PARM-OUT` permanecem na mesma área de memória, que o REXX verá ao ler a variável original.

---

## Script REXX – construção da área, chamada ao COBOL e leitura da saída

### Objetivo do script REXX

- Construir uma variável com exatamente **200 bytes**:
  - `inputPart` (100 bytes) – parâmetros de entrada.
  - `outputPart` (100 bytes) – inicializado com espaços, será sobrescrito pelo COBOL.
- Invocar o programa COBOL (`PGMCOB1`) passando esta variável **por referência**.
- Após o retorno, ler os **bytes 101–200** da mesma variável para obter os parâmetros de saída.

### Código REXX (exemplo explicativo)

```rexx
/* REXX  PGMREXX  */

/* 1. Receber parâmetros de entrada vindos do JCL ou de outra origem       */
/*    Exemplo: o JCL chama PGMREXX com algo como PARM='PGMREXX ABCD'       */

PARSE ARG cod               /* 'cod' é apenas um exemplo de parâmetro     */

IF cod = '' THEN
  cod = 'VALOR-DEFAULT'     /* Valor por defeito se nada vier do JCL      */


/* 2. Construir a parte de entrada (100 bytes)                             */
/*    - inputPart deve ter exatamente 100 bytes                            */
/*    - usamos LEFT() para truncar ou completar com espaços                */

inputPart  = 'COD=' || cod              /* Ex.: 'COD=ABCD'                 */
inputPart  = LEFT(inputPart, 100, ' ')  /* Garante 100 bytes (X(100))      */


/* 3. Construir a parte de saída inicial (100 bytes)                       */
/*    - outputPart começa como 100 espaços e será sobrescrita pelo COBOL   */

outputPart = COPIES(' ', 100)           /* X(100) em branco                 */


/* 4. Construir o bloco total de 200 bytes                                 */
/*    - parmBlock = PARM-IN (bytes 1–100) || PARM-OUT (bytes 101–200)      */

parmBlock  = inputPart || outputPart    /* Total: 200 bytes                 */


/* 5. Chamar o programa COBOL                                              */
/*    - Usando LINKMVS (ou ATTACHMVS), de acordo com o ambiente            */
/*    - O importante é que a variável 'parmBlock' seja passada por ref.    */

SAY 'REXX: Vou chamar PGMCOB1 com 200 bytes de parâmetros.'

ADDRESS TSO "LINKMVS 'PGMCOB1' '"parmBlock"'" 

rcCobol = RC
SAY 'REXX: RC devolvido pelo COBOL = ' rcCobol

IF rcCobol <> 0 THEN DO
  SAY 'REXX: Erro no COBOL. Fim.'
  EXIT rcCobol
END


/* 6. Após o retorno, 'parmBlock' pode ter sido alterado pelo COBOL        */
/*    - Os bytes 1–100 (inputPart) podem ou não ter sido mudados           */
/*    - Os bytes 101–200 (outputPart) contêm agora a saída                 */

outPart = SUBSTR(parmBlock, 101, 100)   /* Extrai bytes 101–200            */


/* 7. Tratar a saída em REXX                                               */

SAY 'REXX: Saída (bytes 101–200) = "'outPart'"'

/* Exemplo de parse simples:
   - Suponha que o COBOL colocou: [primeiros 20 bytes] + 'OK-DO-COBOL'
*/

inEcho   = SUBSTR(outPart, 1, 20)       /* Eco dos dados de entrada         */
status   = SUBSTR(outPart, 21, 11)      /* Texto 'OK-DO-COBOL'              */

SAY 'REXX: Eco recebido   = "'inEcho'"'
SAY 'REXX: Status COBOL   = "'status'"'

EXIT 0
```

### Explicação passo a passo do REXX

- **`PARSE ARG cod`**:
  - Recebe o(s) parâmetro(s) de entrada passados pelo JCL (ou chamador) para o REXX.
  - `cod` será incorporado na parte de entrada dos 200 bytes.

- **Construção de `inputPart`**:
  - `inputPart = 'COD=' || cod` cria uma string com um rótulo simples.
  - `LEFT(inputPart, 100, ' ')` garante que a string fica exatamente com 100 caracteres:
    - Se for maior que 100, é truncada.
    - Se for menor, é completada com espaços à direita.

- **Construção de `outputPart`**:
  - `outputPart = COPIES(' ', 100)` cria 100 espaços.
  - Esta área será sobrescrita pelo COBOL, mas precisa existir na variável para que o bloco total tenha 200 bytes.

- **Formação de `parmBlock`**:
  - `parmBlock = inputPart || outputPart` concatena as duas partes:
    - Bytes 1–100 = `inputPart` (entrada).
    - Bytes 101–200 = `outputPart` (saída).

- **Chamada ao COBOL com `LINKMVS`**:
  - `ADDRESS TSO "LINKMVS 'PGMCOB1' '"parmBlock"'"`:
    - Define o ambiente de comandos (`ADDRESS TSO`).
    - Executa `LINKMVS` carregando o módulo `PGMCOB1`.
    - Passa a variável `parmBlock` como parâmetro, que deverá ser tratada por referência pelo ambiente.
  - `rcCobol = RC` captura o código de retorno do programa COBOL.

- **Leitura da saída (`outPart`)**:
  - `outPart = SUBSTR(parmBlock, 101, 100)` extrai os bytes 101–200, que correspondem a `PARM-OUT` no COBOL.
  - A partir daqui, o REXX pode fazer `PARSE`, `SUBSTR`, `POS`, etc., para decompor a saída nos campos que precisar.

- **Tratamento de eco e status (exemplo)**:
  - `inEcho = SUBSTR(outPart, 1, 20)` lê uma parte de eco dos dados de entrada.
  - `status = SUBSTR(outPart, 21, 11)` lê o texto de status (`'OK-DO-COBOL'`).

---

## Considerações técnicas e boas práticas

- **Contrato fixo de tamanho**:
  - O contrato entre REXX e COBOL deve ser bem definido: neste exemplo, **200 bytes fixos**.
  - Qualquer alteração de tamanho (por exemplo, aumentar para 300 bytes) deve ser sincronizada em ambos os lados.

- **Mapeamento lógico da área**:
  - Mesmo que no REXX a área apareça como “apenas uma string”, é recomendável documentar:
    - Quais campos existem dentro dos 100 bytes de entrada.
    - Quais campos existem dentro dos 100 bytes de saída.
  - No COBOL, esses campos podem ser detalhados dentro de `PARM-IN`/`PARM-OUT` (com subcampos posicionais).

- **Codificação (EBCDIC)**:
  - Em z/OS, as strings estão tipicamente em EBCDIC; o REXX e o COBOL partilham essa codificação.
  - Se existir integração com sistemas ASCII/UTF-8 (por exemplo, via MQ, sockets, etc.), a conversão deve ser feita num dos lados.

- **Validação de conteúdo**:
  - O COBOL deve validar o que recebe em `PARM-IN` (tamanhos, formatos, códigos esperados).
  - O REXX deve validar o que lê em `PARM-OUT` (por exemplo, status numérico/textual) antes de tomar decisões.

- **Tratamento de erros**:
  - Use o `RETURN-CODE` do COBOL (`MOVE 0/4/8/12 TO RETURN-CODE`) para indicar sucesso/erro de alto nível.
  - Em `PARM-OUT`, pode incluir:
    - Código de erro detalhado.
    - Mensagem de texto.
    - Campos adicionais de diagnóstico.

---

## Resumo

- O REXX constrói uma **área de 200 bytes**: 100 para entrada, 100 para saída.
- O COBOL recebe essa área na `LINKAGE SECTION` como `PARM-BLOCK`, com `PARM-IN` (entrada) e `PARM-OUT` (saída).
- O COBOL lê `PARM-IN`, escreve em `PARM-OUT` e faz `GOBACK`.
- O REXX, após a chamada, lê da mesma variável os bytes 101–200 para obter os **parâmetros de saída**, tal como num **CALL clássico por referência** entre objectos mainframe.

