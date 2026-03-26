/* RXETEST - Exec REXX para fluxo IRXEXEC                               */
/* Recebe multiplos argumentos e devolve string no evaluation block.     */

PARSE ARG p1 p2 p3

SAY 'RXETEST: P1='p1
SAY 'RXETEST: P2='p2
SAY 'RXETEST: P3='p3

retTxt = 'OK|' || p1 || '|' || p2 || '|' || p3
retTxt = LEFT(retTxt, 240, ' ')

/* Atribuicao da func result para ser lida no evaluation block */
RETURN retTxt
