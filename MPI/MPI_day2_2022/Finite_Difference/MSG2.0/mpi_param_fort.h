c_______________________________________________________
c
c      MSG 2.0 include file 
c   
c      version May 14, 1997
c_______________________________________________________
c
c
c     include the standard MPI definitions
c
      include 'mpif.h'
c
c   status tables for MPI non blocking routines
c
      integer SendStatus(MPI_STATUS_SIZE),
     &        RecvStatus(MPI_STATUS_SIZE)
c
c   arrays sendid and recvid contain the IDs
c   used for channel communications
c
      integer MSG_sendid(MAX_PROCS, MAX_PATTERNS),
     &        MSG_recvid(MAX_PROCS, MAX_PATTERNS)
c
c   MSGSegment is the pointer to the receive buffer within
c   the array allocated for a buffer
c
      integer MSGSegment(MAX_PATTERNS)
c
c   MSG_COMM identifies the communicator to be used for the MSG
c
      integer MSG_COMM
c
c   MSG_COMM_PARENT identifies the communicator given by the
c   caller (MSG_COMM_WORLD by default)
c 
      integer MSG_COMM_PARENT
c
c   MSG_COMM_PARENT_FLAG tells whether the parent communicator has
c   been changed from the default MSG_COMM_WORLD
c
      integer MSG_COMM_PARENT_FLAG
      integer MSG_COMM_PARENT_MODIFIED
      parameter (MSG_COMM_PARENT_MODIFIED = 12345678)   
c
c   MSG_TRANSFER_TYPE indicates algorithm of data transfer:
c   1 stands for "all to all" transfer
c   0 stands for "series of shifts" transfer
c
      integer MSG_TRANSFER_TYPE(MAX_PATTERNS)
c-----------------------------------------------------------
      common /MSG_sendrec/ MSG_sendid, MSG_recvid, 
     &                     SendStatus, RecvStatus,
     &                     MSGSegment, MSG_COMM,
     &                     MSG_COMM_PARENT, MSG_COMM_PARENT_FLAG,
     &                     MSG_TRANSFER_TYPE
c
