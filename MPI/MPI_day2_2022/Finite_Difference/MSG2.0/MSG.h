c_____________________________________________
c
c    include file to describe the MSG functions 
c
c                 version 2.0 
c
c---------------------------------------------

      real*8 MSG_timer
      external MSG_timer 
      integer MSG_myproc
      external MSG_myproc
      integer MSG_nproc
      external MSG_nproc
      integer MSG_VERSION
      common /MSG_GLOBAL_DATA/ MSG_VERSION 
c
