//JCLSETUP JOB (ACCT),'SETUP COB/REXX',CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//* -------------------------------------------------------------------
//* Setup base:
//* 1) Copia membros REXX para HLQ.REXX.EXEC
//* 2) Compila/Link COBIRXJ e COBIRXE para HLQ.COBOL.LOAD
//* Ajustar HLQ, PROC names e bibliotecas do seu ambiente.
//* -------------------------------------------------------------------
//COPYREXX EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD DISP=SHR,DSN=HLQ.SOURCE.REXX(RXJTEST)
//SYSUT2   DD DISP=SHR,DSN=HLQ.REXX.EXEC(RXJTEST)
//SYSIN    DD DUMMY
//COPYREX2 EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD DISP=SHR,DSN=HLQ.SOURCE.REXX(RXETEST)
//SYSUT2   DD DISP=SHR,DSN=HLQ.REXX.EXEC(RXETEST)
//SYSIN    DD DUMMY
//*
//* Exemplo usando PROC local de compile/link COBOL (substituir conforme site)
//CBLJCL   EXEC PROC=IGYWCL,
//         INFILE='HLQ.SOURCE.COBOL(COBIRXJ)',
//         LODOUT='HLQ.COBOL.LOAD(COBIRXJ)'
//*
//CBLECL   EXEC PROC=IGYWCL,
//         INFILE='HLQ.SOURCE.COBOL(COBIRXE)',
//         LODOUT='HLQ.COBOL.LOAD(COBIRXE)'
