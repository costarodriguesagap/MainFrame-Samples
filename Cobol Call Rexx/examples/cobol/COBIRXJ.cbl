       IDENTIFICATION DIVISION.
       PROGRAM-ID. COBIRXJ.
       AUTHOR. EXEMPLO IRXJCL.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-EXEC-NAME             PIC X(8)  VALUE 'RXJTEST '.
       01  WS-ARG-TEXT              PIC X(80).
       01  WS-RET-CODE              PIC S9(9) COMP VALUE 0.
       01  WS-API-RC                PIC S9(9) COMP VALUE 0.

       PROCEDURE DIVISION.
       MAIN-LOGIC.
           MOVE 'ARG1=HELLO ARG2=WORLD FROM COBOL' TO WS-ARG-TEXT

           DISPLAY 'COBIRXJ: CALL IRXJCL START'
           DISPLAY 'COBIRXJ: EXEC=' WS-EXEC-NAME
           DISPLAY 'COBIRXJ: ARGS=' WS-ARG-TEXT

           CALL 'IRXJCL' USING
                WS-EXEC-NAME
                WS-ARG-TEXT
                WS-RET-CODE
                WS-API-RC
           END-CALL

           DISPLAY 'COBIRXJ: IRXJCL API-RC=' WS-API-RC
           DISPLAY 'COBIRXJ: REXX RETURN-CODE=' WS-RET-CODE

           IF WS-API-RC NOT = 0
              MOVE 12 TO RETURN-CODE
              DISPLAY 'COBIRXJ: FALHA NA API IRXJCL'
              GOBACK
           END-IF

           MOVE WS-RET-CODE TO RETURN-CODE
           GOBACK.
