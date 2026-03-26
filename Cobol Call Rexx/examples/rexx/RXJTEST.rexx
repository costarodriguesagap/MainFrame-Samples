/* RXJTEST - Exec REXX para fluxo IRXJCL                               */
/* Recebe uma unica string de argumentos e devolve RC numerico.         */

PARSE ARG allArgs
SAY 'RXJTEST: argumentos recebidos=['allArgs']'

IF allArgs = '' THEN DO
  SAY 'RXJTEST: sem argumentos, RC=4'
  EXIT 4
END

IF POS('ERRO', allArgs) > 0 THEN DO
  SAY 'RXJTEST: gatilho de erro controlado, RC=8'
  EXIT 8
END

SAY 'RXJTEST: execucao ok, RC=0'
EXIT 0
