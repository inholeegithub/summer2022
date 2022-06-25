c________________________________________________________________
c
c
c   Message-Passing Toolkit for Structured Grid Communications 
c
c                     Communications Routines
c
c---------------------------------------------------------------
c
c   Contents:
c-----------
c
c
c
c   MSG_enable - gives the configuration information 
c
c   MSG_disable - disables the message-passing environment 
c
c   MSG_nproc - gives the number of processors involved
c   
c   MSG_myproc - gives my processor number (from 1 to MAX_PROCS)
c
c   MSG_set_comm_parent - sets the parent communicator
c
c   MSG_tbdx_send - boundary information exchange routine which makes use of
c                   repeated communication patterns (a "half channel" option)
c                   for a tensor product grid;
c                   it sends the boundary data out
c
c   MSG_tbdx_receive - receives the boundary data
c
c   MSG_tbdx_close - closes the communication pattern (channel)
c  
c   MSG_tbdx_gather - gathers boundary data in a single buffer
c
c   MSG_tbdx_scatter - places the boundary data into the local array
c
c---------------------------------------------------------------
c
c   written by A. Malevsky, last modified:  May 16, 1997 
c
c   record of updates to this version:
c
c       MSG_COMM_PARENT_FLAG added to mpi_param_fort.h
c       to signal a modification of the default parent communicator
c       in odrer to fix the problem with some compilers whcih do not
c       take multiple initialisations with DATA in common blocks
c       May 14, 1997
c
c       MSG_tbdx_send, MSG_tbdx_receive, and MSG_tbdx_close
c       exit immediately if the number of adjacent processors is 0
c       May 16, 1997
c________________________________________________________________
c
c

#ifdef DOUBLE
#define FLOAT_PRECISION MPI_DOUBLE_PRECISION
#define FLOAT real*8
#else
#define FLOAT_PRECISION MPI_REAL
#define FLOAT real
#endif


      subroutine MSG_enable(MyProc, NumProc)
c-----------------------------------------------------------------
c
c   MSG_enable initiates a separate message-passing environment
c   for the MSG data transfer functions and obtains information
c   on the number of processors in the system and the current 
c   the current processor's number 
c
c____________________________ OUTPUT _____________________________
c
c   MyProc - my processor number (from 1 to NumProc)
c   NumProc - number of available processors
c
c-----------------------------------------------------------------
      implicit none
      include 'geom_param_fort.h'
      include 'mpi_param_fort.h' 
      include 'MSG.h'
      integer ierror, MyProc, NumProc
      logical flag
      MSG_VERSION = 2
c
c     initialize the MPI if it has not been already initialized
c
#ifndef DEBUG
      call MPI_initialized(flag, ierror)
      if(.not.flag) call MPI_init(ierror)   
c
c     create a new communicator to separate the MSG communications
c
      if(MSG_COMM_PARENT_FLAG.ne.MSG_COMM_PARENT_MODIFIED) then
c        no parent communicator has been specified
         MSG_COMM_PARENT = MPI_COMM_WORLD 
         call MPI_COMM_DUP(MPI_COMM_WORLD, MSG_COMM, ierror)
      else
c        a parent communicator has been specified 
         call MPI_COMM_DUP(MSG_COMM_PARENT, MSG_COMM, ierror)
      endif
      MSG_COMM_PARENT_FLAG = 0
      call MPI_COMM_RANK(MSG_COMM, MyProc, ierror)
      MyProc = MyProc + 1 
      call MPI_COMM_SIZE(MSG_COMM, NumProc, ierror)
#else
      print *,' Debugging: enter MyProc:'
      read (*,*) MyProc
      print *,' Debugging: enter NumProc:'
      read (*,*) NumProc 
#endif
      return
      end

      subroutine MSG_set_comm_parent(comm)
      implicit none
      include 'geom_param_fort.h'
      include 'mpi_param_fort.h'
      integer comm
      MSG_COMM_PARENT_FLAG = MSG_COMM_PARENT_MODIFIED
      MSG_COMM_PARENT = comm
      return
      end 
      

      integer function MSG_myproc()
      implicit none
      include 'geom_param_fort.h'
      include 'mpi_param_fort.h'
      integer ierror, MyProc
#ifndef DEBUG
      call MPI_COMM_RANK(MSG_COMM, MyProc, ierror)
      MSG_myproc = MyProc + 1
#else
      print *,' Debugging: enter MyProc:'
      read (*,*) MyProc 
      MSG_myproc = MyProc
#endif
      return
      end


      integer function MSG_nproc()
      implicit none
      include 'geom_param_fort.h'
      include 'mpi_param_fort.h'
      integer ierror, NumProc
#ifndef DEBUG
      call MPI_COMM_SIZE(MSG_COMM, NumProc, ierror)
#else
      print *,' Debugging: enter NumProc:'
      read (*,*) NumProc
#endif
      MSG_nproc = NumProc 
      return
      end


      subroutine MSG_disable(ierror)
      implicit none
      include 'geom_param_fort.h'
      include 'mpi_param_fort.h'
      integer ierror
#ifndef DEBUG
      call MPI_BARRIER(MSG_COMM, ierror)
      call MPI_COMM_FREE(MSG_COMM, ierror)
#endif
      return
      end


      subroutine MSG_tbdx_send(x,y,nproc,proc,ipr,index,ptrn,ierr)
      implicit none 
      integer nproc,ptrn,ierr
      integer proc(nproc), ipr(*), index(*)
      FLOAT x(*), y(*)
c-----------------------------------------------------------------------
c     interface information exchange routine for a repeated
c     communication pattern on a tensor product grid
c     MSG version 2.0 
c
c-----------------------------------------------------------------------
c
c     
c arguments:
c------------ 
c
c     x     = input array (a multidimensional prism), its boundaries
c             will be updated with the data from the other processors
c     y     = work array of the size of at least two times 
c             the maximal boundary segment 
c     nproc = number of adjacent processors (input)
c     proc  = array of size nproc containing the numbers (IDs)  
c             of neighboring processors (input).
c     ipr   = array containing pointers to the beginnings
c             of each segment in the array of indices index (input)
c     index = array of indices of boundary elements (input)
c             a negative index of the first element of a segment
c             indicates that the segment is contiguous and will
c             be processed in place
c     ptrn  = indicates a pattern to use;
c             ptrn must be between 1 and MAX_PATTERNS,
c             Only a limited number of patterns can be allocated.
c             A pattern must be explicitly deallocated if it is not 
c             needed anymore. Another pattern can be later opened
c             with the same ptrn.  
c
c return code: 
c-------------
c
c       ierr =     0 --- boundary information has been sent,
c                        pattern stays open 
c                 -1 --- error opening the channels
c                 -2 --- the number of pattern specified 
c                        is zero or larger than the maximum
c                        allowed - increase MAX_PATTERNS and
c                        recompile                  
c                 -3 --- the specified number of adjacent processors is
c                        wrong, either it is larger than the allowed
c                        maximum (increase MAX_PROCS and recompile)
c                        or is less than 0
c                 >0 --- error in MPI functions (see MPI error codes)
c
c-----------------------------------------------------------------------
c     local variables
      include 'geom_param_fort.h'
      include 'mpi_param_fort.h'
      integer iproc, InSegmentStart, InSegmentSize,
     &        OutSegmentSize, OutSegmentStart
      logical first_call
      data first_call/.true./
      save first_call
c
      ierr = 0
      if(nproc.eq.0) return
      if( ptrn.gt.MAX_PATTERNS.or.ptrn.le.0 ) then
          ierr = -2
          return
      endif 
      if( nproc.gt.MAX_PROCS.or.nproc.lt.0) then
          ierr = -3
          return
      endif
      if(first_call) then
         do iproc=1,MAX_PATTERNS
            MSG_sendid(1,iproc)=0
            MSG_recvid(1,iproc)=0
         enddo
         first_call = .false.
      endif
      if(MSG_sendid(1,ptrn).eq.0.and.MSG_recvid(1,ptrn).eq.0) then
c
c        open the communication channels
c
c        set the type of data transfer for this pattern
c
         if(proc(1).lt.0) then
            MSG_TRANSFER_TYPE(ptrn) = 1
            proc(1) = -proc(1)
         else
            MSG_TRANSFER_TYPE(ptrn) = 0
         endif
c
c        find the maximal size of outgoing segment in order to
c        find a "safe" place within the array y to put the
c        buffer for the incoming data
c
         MSGSegment(ptrn) = 0
         do iproc = 1, nproc
            OutSegmentSize = ipr(2*iproc) - ipr(2*iproc-1)
            if(MSGSegment(ptrn).lt.OutSegmentSize) 
     &         MSGSegment(ptrn) = OutSegmentSize
         enddo
         MSGSegment(ptrn) = MSGSegment(ptrn) + 1
c
c        open up channels
c
         do iproc = 1, nproc
            OutSegmentSize = ipr(2*iproc) - ipr(2*iproc-1) 
            OutSegmentStart = ipr(2*iproc-1)
            if(OutSegmentSize.gt.0) then
              if(index(OutSegmentStart).ge.0) then
c              noncontiguous memory segment: give the buffer's address
#ifndef DEBUG
               call MPI_send_init(y, OutSegmentSize, 
     *                            FLOAT_PRECISION, 
     *                            proc(iproc)-1, ptrn, MSG_COMM,
     *                            MSG_sendid(iproc,ptrn), ierr)
               if(ierr.ne.MPI_SUCCESS) return 
#endif
              else
c              contiguous memory segment: give the data address
#ifndef DEBUG
               call MPI_send_init(x(-index(OutSegmentStart)),
     *                            OutSegmentSize, 
     *                            FLOAT_PRECISION,
     *                            proc(iproc)-1, ptrn, MSG_COMM,
     *                            MSG_sendid(iproc,ptrn), ierr)
               if(ierr.ne.MPI_SUCCESS) return
#endif
              endif
            endif
            InSegmentSize = ipr(2*iproc+1) - ipr(2*iproc)
            InSegmentStart = ipr(2*iproc)
            if(InSegmentSize.gt.0) then
              if(index(InSegmentStart).ge.0) then
c              noncontiguous memory segment: give the buffer's address
#ifndef DEBUG
               call MPI_recv_init(y(MSGSegment(ptrn)), InSegmentSize, 
     *                            FLOAT_PRECISION,
     *                            proc(iproc)-1, ptrn, MSG_COMM,
     *                            MSG_recvid(iproc,ptrn), ierr)
               if(ierr.ne.MPI_SUCCESS) return
#endif
              else
c              contiguous memory segment: give the data address
#ifndef DEBUG
               call MPI_recv_init(x(-index(InSegmentStart)),
     *                            InSegmentSize, 
     *                            FLOAT_PRECISION,
     *                            proc(iproc)-1, ptrn, MSG_COMM,
     *                            MSG_recvid(iproc,ptrn), ierr)
               if(ierr.ne.MPI_SUCCESS) return
#endif
              endif
            endif
         enddo
      endif 
c
      if(MSG_TRANSFER_TYPE(ptrn).eq.1) then
c
c     exchange data through the channels using all to all
c
c        send all the messages out one by one 
         do iproc = 1, nproc
            OutSegmentSize = ipr(2*iproc) - ipr(2*iproc-1)
            if(OutSegmentSize.gt.0) then
c              gather the outgoing data in the outgoing buffer
               call MSG_tbdx_gather(x, y, iproc, ipr, index)
c              start sending the outgoing data to iproc
#ifndef DEBUG
               call MPI_start(MSG_sendid(iproc,ptrn), ierr)
               if(ierr.ne.MPI_SUCCESS) return
               call MPI_wait(MSG_sendid(iproc,ptrn), SendStatus, ierr)
               if(ierr.ne.MPI_SUCCESS) return
#endif
            endif
         enddo
      else
c
c     exchange data through the channels using shifts
c
      if(nproc.gt.1) then
        do iproc = 1, nproc - 1
         OutSegmentSize = ipr(2*iproc) - ipr(2*iproc-1)
         InSegmentSize = ipr(2*iproc+1) - ipr(2*iproc)
c        start receiving the incoming data from iproc
#ifndef DEBUG
         if(InSegmentSize.gt.0) then
            call MPI_start(MSG_recvid(iproc,ptrn), ierr)
            if(ierr.ne.MPI_SUCCESS) return
         endif
#endif
         if(OutSegmentSize.gt.0) then
c           gather the outgoing data in the outgoing buffer
            call MSG_tbdx_gather(x, y, iproc, ipr, index)
c           start sending the outgoing data to iproc
#ifndef DEBUG
            call MPI_start(MSG_sendid(iproc,ptrn), ierr)
            if(ierr.ne.MPI_SUCCESS) return
#endif
         endif 
         if(InSegmentSize.gt.0) then
c           wait for the incoming data to be received
#ifndef DEBUG
            call MPI_wait(MSG_recvid(iproc,ptrn), RecvStatus, ierr)
            if(ierr.ne.MPI_SUCCESS) return
#endif
c           place the incoming data into the local array
            call MSG_tbdx_scatter(x, y(MSGSegment(ptrn)), 
     &                            iproc, ipr, index)
         endif
c        wait for the outgoing data to be sent
#ifndef DEBUG
         if(OutSegmentSize.gt.0) then 
            call MPI_wait(MSG_sendid(iproc,ptrn), SendStatus, ierr)
            if(ierr.ne.MPI_SUCCESS) return
         endif
#endif
        enddo
      endif
      iproc = nproc
      OutSegmentSize = ipr(2*iproc) - ipr(2*iproc-1)
      InSegmentSize = ipr(2*iproc+1) - ipr(2*iproc)
c     start receiving the incoming data from nproc  
#ifndef DEBUG
      if(InSegmentSize.gt.0) then 
         call MPI_start(MSG_recvid(iproc,ptrn), ierr)
         if(ierr.ne.MPI_SUCCESS) return
      endif
#endif
      if(OutSegmentSize.gt.0) then
c        gather the outgoing data in the outgoing buffer
         call MSG_tbdx_gather(x, y, iproc, ipr, index)
c        start sending the outgoing data to nproc
#ifndef DEBUG
         call MPI_start(MSG_sendid(iproc,ptrn), ierr)
         if(ierr.ne.MPI_SUCCESS) return
#endif
      endif
c
      endif
      return
      end

      subroutine MSG_tbdx_close(x,y,nproc,proc,ipr,index,ptrn,ierr)
      implicit none
      integer nproc,ptrn,ierr
      integer proc(nproc),ipr(*),index(*)
      FLOAT x(*),y(*)
c-----------------------------------------------------------------------
c
c   deallocates a communication pattern (closes a channel)
c   for a tensor product grid
c   for the details, see MSG_tdbx_send
c   MPI version 2.0 
c
c-----------------------------------------------------------------------
c
c     local variables
      include 'geom_param_fort.h'
      include 'mpi_param_fort.h'
      integer ii
      ierr = 0
      if(nproc.eq.0) return
#ifndef DEBUG
      do ii=1,nproc
         if(MSG_sendid(ii,ptrn).ne.0) then
            call MPI_request_free(MSG_sendid(ii,ptrn), ierr)
            if(ierr.ne.MPI_SUCCESS) return
         endif
         if(MSG_recvid(ii,ptrn).ne.0) then
            call MPI_request_free(MSG_recvid(ii,ptrn), ierr)
            if(ierr.ne.MPI_SUCCESS) return
         endif
      enddo
#endif
      MSG_sendid(1,ptrn) = 0
      MSG_recvid(1,ptrn) = 0
      ierr = 0
      return
      end


      subroutine MSG_tbdx_receive(x,y,nproc,proc,ipr,index,ptrn,ierr)
      implicit none
      integer nproc,ptrn,ierr
      integer proc(nproc), ipr(*), index(*)
      FLOAT x(*), y(*)
c-----------------------------------------------------------------------
c
c     interface information exchange routine for a repeated
c     communication pattern and a tensor product grid
c     for the details, see MSG_tdbx_send
c     MSG version 2.0 
c
c arguments:
c------------
c
c     x     = output vector (a multidimensional prism), its boundaries
c             will be updated with the data from the other processors
c     y     = input array containing the boundary information 
c     nproc = number of adjacent processors (input)
c     proc  = array of size nproc containing the numbers (IDs)
c             of neighboring processors (input).
c     ipr   = array containing pointers to the beginnings
c             of each segment in the buffer y (input)
c     index = array of indices of boundary elements(input)
c     ptrn  = indicates a pattern to use;
c             ptrn must be between 1 and MAX_PATTERNS,
c             Only a limited number of patterns can be allocated.
c             A pattern must be explicitly deallocated if it is not
c             needed anymore. Another pattern can be later opened
c             with the same ptrn.
c     ierr  = error code produced by the MPI routines (0 if success)
c             (output)
c
c-----------------------------------------------------------------------
c
c     local variables
      include 'geom_param_fort.h'
      include 'mpi_param_fort.h'
      integer OutSegmentSize, InSegmentSize, iproc
c 
      ierr = 0
      if(nproc.eq.0) return
      if(MSG_TRANSFER_TYPE(ptrn).eq.1) then
c
c        use "all to all" mode
c
         do iproc = 1, nproc
            InSegmentSize = ipr(2*iproc+1) - ipr(2*iproc)
            if(InSegmentSize.gt.0) then
#ifndef DEBUG
               call MPI_start(MSG_recvid(iproc,ptrn), ierr)
               if(ierr.ne.MPI_SUCCESS) return
               call MPI_wait(MSG_recvid(iproc,ptrn), RecvStatus, ierr)
               if(ierr.ne.MPI_SUCCESS) return
#endif
c              scatter the incoming data
               call MSG_tbdx_scatter(x, y(MSGSegment(ptrn)),
     &                               iproc, ipr, index)
            endif
         enddo
      else
c
c     use the "series of shifts" mode
c 
      OutSegmentSize = ipr(2*nproc) - ipr(2*nproc-1)
      InSegmentSize = ipr(2*nproc+1) - ipr(2*nproc)
c
c     wait until the exchange with the last processor on the
c     neighbors list is completed and
c     reset the channels for the next transaction 
c
      if(InSegmentSize.gt.0) then
#ifndef DEBUG
        call MPI_wait(MSG_recvid(nproc,ptrn), RecvStatus, ierr)
        if(ierr.ne.MPI_SUCCESS) return
#endif
        call MSG_tbdx_scatter(x, y(MSGSegment(ptrn)), 
     &                        nproc, ipr, index)
      endif
#ifndef DEBUG
      if(OutSegmentSize.gt.0) then
        call MPI_wait(MSG_sendid(nproc,ptrn), SendStatus, ierr)
        if(ierr.ne.MPI_SUCCESS) return
      endif
#endif
      endif
      return 
      end 


      subroutine MSG_tbdx_gather(x, y, iproc, ipr, index)
      implicit none
      integer iproc, ipr(*), index(*)
      FLOAT x(*), y(*)
c-----------------------------------------------------------------------
c
c     gathers the outgoing boundary information into a single buffer
c
c-----------------------------------------------------------------------
c
c
c arguments:
c------------
c
c     x     = input array (local data - a multidimensional prism)
c     y     = buffer to be filled 
c     iproc = index of the adjacent procesor within the neighbors list
c             (input)
c     ipr   = array containing pointers to the beginnings
c             of each segment in the buffer y (input)
c     index = array of indices of boundary elements(input)
c             if the first index of the segment is negative
c             then the data is processed in place
c
c-----------------------------------------------------------------------
c
c     local variables
      integer OutSegmentStart, OutSegmentEnd, OutSegmentSize, j, k
      OutSegmentStart = ipr(2*iproc-1)
      if(index(OutSegmentStart).lt.0) return
      OutSegmentSize = ipr(2*iproc) - ipr(2*iproc-1) 
      OutSegmentEnd = OutSegmentStart + OutSegmentSize - 1 
      k=1
      do j = OutSegmentStart, OutSegmentEnd 
         y(k)=x(index(j))
         k = k + 1
      enddo
      return
      end


      subroutine MSG_tbdx_scatter(x, y, iproc, ipr, index)
      implicit none
      integer iproc, ipr(*), index(*)
      FLOAT x(*), y(*)
c-----------------------------------------------------------------------
c
c     places boundary information into the local array
c
c
c arguments:
c------------
c
c     x     = output array (local data - a multidimensional prism)
c     y     = address of the buffer for incoming data
c     iproc = index of the adjacent procesor within the neighbors list
c             (input)
c     ipr   = array containing pointers to the beginnings
c             of each segment in the buffer y
c     index = array of indices of boundary elements(input)
c             if the first index of a segment is negative than
c             the segment is processed in place
c
c-----------------------------------------------------------------------
c
c     local variables
      integer InSegmentSize, InSegmentStart, InSegmentEnd, j, k
      InSegmentStart = ipr(2*iproc)
      if(index(InSegmentStart).lt.0) return
      InSegmentSize = ipr(2*iproc+1) - ipr(2*iproc) 
      InSegmentEnd = InSegmentStart + InSegmentSize - 1 
      k=1
      do j = InSegmentStart, InSegmentEnd 
         x(index(j))=y(k)
         k = k + 1
      enddo
      return
      end


      logical function MSG_shift_in_trouble(nproc, ipr, gc_eid, gc_ld,
     &                 FirstGlobalIndex, LastGlobalIndex, MyPeriodic)
      implicit none
      integer nproc, ipr(*), gc_eid(6), gc_ld(6),
     &        FirstGlobalIndex(3), LastGlobalIndex(3), MyPeriodic(3)
c     local data
c
      include 'geom_param_fort.h'
      include 'mpi_param_fort.h'
      integer MyEID(6), MyLDSize, MyEIDSize, MyHaloSize, ierr, 
     &        MyInSize, iproc, LocType, GlobalType
c
      MSG_shift_in_trouble = .false.
      LocType = 0
c 
c     find the size of the halo=eid-ld segment
c            
      MyLDSize = (gc_ld(2) - gc_ld(1) + 1)*
     &           (gc_ld(4) - gc_ld(3) + 1)*
     &           (gc_ld(6) - gc_ld(5) + 1)
      call MSG_to_contiguous(MyEID, gc_eid,
     &     FirstGlobalIndex, LastGlobalIndex, MyPeriodic)
      MyEIDSize = (MyEID(2) - MyEID(1) + 1)*
     &            (MyEID(4) - MyEID(3) + 1)*
     &            (MyEID(6) - MyEID(5) + 1)
      MyHaloSize = MyEIDSize - MyLDSize
c            
c     find the size of my incoming segment
c            
      MyInSize = 0
      do iproc=1,nproc
         MyInSize = MyInSize + ipr(2*iproc+1) - ipr(2*iproc) 
      enddo  
      if(MyHaloSize.gt.MyInSize) LocType = 1 
#ifndef DEBUG
      call MPI_Allreduce(LocType, GlobalType, 1, MPI_INTEGER,
     *                   MPI_MAX, MSG_COMM, ierr)
#else        
      GlobalType = LocType
#endif
      MSG_shift_in_trouble = GlobalType.eq.1 
      return
      end

