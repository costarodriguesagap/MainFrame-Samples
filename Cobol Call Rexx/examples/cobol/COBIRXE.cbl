       IDENTIFICATION DIVISION.
       PROGRAM-ID. COBIRXE.
       AUTHOR. EXEMPLO IRXEXEC.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-EXEC-NAME             PIC X(8) VALUE 'RXETEST '.
       01  WS-API-RC                PIC S9(9) COMP VALUE 0.
       01  WS-REXX-RC               PIC S9(9) COMP VALUE 0.

       *> Control blocks simplificados para documentar o fluxo IRXEXEC.
       01  WS-EXEC-BLOCK.
           05 WS-EBLK-LEN           PIC S9(9) COMP VALUE 256.
           05 WS-EBLK-FLAGS         PIC S9(9) COMP VALUE 0.
           05 WS-EBLK-RESERVED      PIC X(248) VALUE SPACES.

       01  WS-EVAL-BLOCK.
           05 WS-EVBK-LEN           PIC S9(9) COMP VALUE 256.
           05 WS-EVBK-RET-LEN       PIC S9(9) COMP VALUE 0.
           05 WS-EVBK-RET-TEXT      PIC X(240) VALUE SPACES.

       01  WS-ARG-COUNT             PIC S9(4) COMP VALUE 3.
       01  WS-ARG-TABLE.
           05 WS-ARG-1              PIC X(32) VALUE 'CLIENTE=ANTONIO'.
           05 WS-ARG-2              PIC X(32) VALUE 'PRODUTO=SEGURO'.
           05 WS-ARG-3              PIC X(32) VALUE 'CANAL=BATCH'.

       PROCEDURE DIVISION.
       MAIN-LOGIC.
           DISPLAY 'COBIRXE: CALL IRXEXEC START'
           DISPLAY 'COBIRXE: EXEC=' WS-EXEC-NAME
           DISPLAY 'COBIRXE: ARG-COUNT=' WS-ARG-COUNT
           DISPLAY 'COBIRXE: ARG1=' WS-ARG-1
           DISPLAY 'COBIRXE: ARG2=' WS-ARG-2
           DISPLAY 'COBIRXE: ARG3=' WS-ARG-3

           CALL 'IRXEXEC' USING
                WS-EXEC-BLOCK
                WS-EXEC-NAME
                WS-ARG-COUNT
                WS-ARG-TABLE
                WS-EVAL-BLOCK
                WS-REXX-RC
                WS-API-RC
           END-CALL

           DISPLAY 'COBIRXE: IRXEXEC API-RC=' WS-API-RC
           DISPLAY 'COBIRXE: REXX RETURN-CODE=' WS-REXX-RC
           DISPLAY 'COBIRXE: RET-LEN=' WS-EVBK-RET-LEN
           DISPLAY 'COBIRXE: RET-TEXT=' WS-EVBK-RET-TEXT(1:80)

           IF WS-API-RC NOT = 0
              MOVE 12 TO RETURN-CODE
              DISPLAY 'COBIRXE: FALHA NA API IRXEXEC'
              GOBACK
           END-IF

           MOVE WS-REXX-RC TO RETURN-CODE
           GOBACK.
