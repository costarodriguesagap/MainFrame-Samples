//JCLRUNE  JOB (ACCT),'IRXEXEC TEST',CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//* -------------------------------------------------------------------
//* Executa COBIRXE em batch via IKJEFT01.
//* COBIRXE chama REXX RXETEST usando IRXEXEC.
//* -------------------------------------------------------------------
//STEP1    EXEC PGM=IKJEFT01,DYNAMNBR=20
//STEPLIB  DD DISP=SHR,DSN=HLQ.COBOL.LOAD
//SYSEXEC  DD DISP=SHR,DSN=HLQ.REXX.EXEC
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//SYSTSIN  DD *
  QUEUE
  RUN PROGRAM(COBIRXE)
/*
