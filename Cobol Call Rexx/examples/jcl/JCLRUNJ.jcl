//JCLRUNJ  JOB (ACCT),'IRXJCL TEST',CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//* -------------------------------------------------------------------
//* Executa COBIRXJ em batch via IKJEFT01.
//* COBIRXJ chama REXX RXJTEST usando IRXJCL.
//* -------------------------------------------------------------------
//STEP1    EXEC PGM=IKJEFT01,DYNAMNBR=20
//STEPLIB  DD DISP=SHR,DSN=HLQ.COBOL.LOAD
//SYSEXEC  DD DISP=SHR,DSN=HLQ.REXX.EXEC
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//SYSTSIN  DD *
  QUEUE
  RUN PROGRAM(COBIRXJ)
/*
