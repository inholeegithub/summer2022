      program jacobi2D
c       uses MSG2.0
      implicit none
      include 'mpif.h'
      include 'MSG.h'
      integer MAX_LOCAL
      parameter (MAX_LOCAL=256)
      integer MyProc, NumProc, ierror, Niter, N_Proc, MSGMyProc
      integer Nglobal, Nlocal, iproc, jproc, ibuf(2), iter 
      real h, time_e, time_i
      real u(0:MAX_LOCAL+1,0:MAX_LOCAL+1),
     &     f(MAX_LOCAL,MAX_LOCAL),
     &     w(MAX_LOCAL,MAX_LOCAL),
     &     s(MAX_LOCAL,MAX_LOCAL)
c
c     initialize the MPI
c
#ifndef DEBUG
      call MPI_init(ierror)
#endif
c
c     initialize the MSG
c
      call MSG_enable(MSGMyProc, NumProc)
      MyProc = MSGMyProc - 1 
      if(MyProc .eq. 0) then
         print *,' Enter the number of iterations:'
         read *,Niter
         print *,' Enter the global grid size:'
         read *,NGlobal
      endif
c
c     broadcast Niter and NGlobal to all the processors
c
      ibuf(1) = Niter
      ibuf(2) = NGlobal
#ifndef DEBUG
      call MPI_BCAST(ibuf, 2, MPI_INTEGER, 0, MPI_COMM_WORLD, ierror)
#endif
      Niter = ibuf(1)
      NGlobal = ibuf(2)
c
c     find the coordinates of my processor on the processors grid
c
      N_Proc = sqrt(real(NumProc))
      Nlocal = (NGlobal-2)/N_Proc
      if(mod((NGlobal-2),N_Proc).ne.0   .or. 
     &   NLocal.gt.MAX_LOCAL .or. N_Proc*N_Proc.ne.NumProc) then
         print *,' Wrong size of problem. Exiting'
#ifndef DEBUG
         call MPI_Finalize(ierror)
#endif
         stop
      endif
c
      jproc = MyProc/N_Proc
      iproc = MyProc - N_Proc*jproc
c
c     set the initial values
c
      h = 1./(Nglobal-1)
      call set_init(u, f, h, Nlocal, iproc, jproc)
c
c     get the initial time
c
#ifndef DEBUG
      time_i = MPI_Wtime()
#endif
      do iter=1,Niter
         call jacobi(u, f, h, w, Nlocal, N_Proc)
      enddo 
c
c     get the execution time
c
#ifndef DEBUG
      call MPI_barrier(MPI_COMM_WORLD,ierror)
      time_e = MPI_Wtime() - time_i
#endif
      if(MyProc.eq.0) print *,' wallclock time (sec) =',time_e
      call compare(u, h, NLocal, iproc, jproc, Niter, MyProc, NGlobal)
      call MSG_disable(iter)
#ifndef DEBUG
      call MPI_FINALIZE(ierror) 
#endif
      end

      subroutine compare(u, h, nloc, iproc, jproc, Niter, 
     &                   MyProc, NGlobal)
      implicit none
      include "mpif.h"
      integer nloc, iproc, jproc, Niter, MyProc, NGlobal
      real u(0:nloc+1,0:nloc+1)
      integer i, j, ierror
      real x, y, pi, max_error, errv, l2_error, h
      data pi/3.1415927/,max_error/0./,l2_error/0./
      y = h + jproc*nloc*h
      do j=1,nloc
         x = h + iproc*nloc*h 
         do i=1,nloc
            errv = abs(u(i,j)-sin(pi*x)*sin(pi*y))
            l2_error = l2_error + errv*errv
            if(max_error.le.errv) max_error=errv
            x = x + h
         enddo
         y = y + h
      enddo
c
c     calculate the root mean square error
c
      errv = l2_error
#ifndef DEBUG
      call MPI_REDUCE(errv, l2_error, 1, MPI_REAL, 
     &               MPI_SUM, 0, MPI_COMM_WORLD, ierror)    
#endif
c
c     calculate the maximal error
c
      errv = max_error
#ifndef DEBUG
      call MPI_REDUCE(errv, max_error, 1, MPI_REAL, 
     &               MPI_MAX, 0, MPI_COMM_WORLD, ierror)
#endif
c   
      iF(MyProc.eq.0) then
         l2_error = sqrt(l2_error/NGlobal**2)
         print *,' grid size = ',NGlobal,' by ',NGlobal
         print *,' number of iterations = ',Niter
         print *,' root mean squared error = ',l2_error
         print *,' maximal error = ',max_error
      endif
      return
      end

      subroutine set_init(u, f, h, nloc, iproc, jproc)
      implicit none
      integer nloc, iproc, jproc
      real u(0:nloc+1,0:nloc+1), f(nloc,nloc)
      real h
      integer i,j,iunit
      real x,y,pi
      data pi/3.1415927/
      y = h + jproc*nloc*h 
      do j=1,nloc
         x = h + iproc*nloc*h 
         do i=1,nloc
            u(i,j)=sin(pi*x)*sin(pi*y)+0.3*sin(8.*pi*x)*sin(8.*pi*y)
            f(i,j)=-2.*pi*pi*sin(pi*x)*sin(pi*y)
            x = x + h
         enddo
         y = y + h
      enddo
      do j=0,nloc
         u(0,j)=0.
         u(nloc+1,j)=0.
      enddo
      do i=0,nloc
         u(i,0)=0.
         u(i,nloc+1)=0.
      enddo
      return
      end

      subroutine jacobi(u, f, h, w, Nlocal, N_Proc)
      implicit none
      include 'MSG.h'
      integer MAX_LOCAL 
      parameter (MAX_LOCAL=256)
      integer MAX_NEIGHBORS
      parameter (MAX_NEIGHBORS=4)
      integer MAX_TOTAL_PROCS
      parameter (MAX_TOTAL_PROCS=9)
      integer Nlocal, N_Proc
      real u(0:NLocal+1,0:NLocal+1), 
     &     f(NLocal,NLocal),
     &     w(NLocal,NLocal), h
c       local data
      real h2, buf(2*(MAX_LOCAL+2)) 
      integer iunit, i, j, NumProc, MyProc, GlobalGridSize(3), 
     &        ProcGridSize(3), IfPeriodic(3), Overlap(3), ptrn, ier
      integer N_Neighbors, proc(MAX_NEIGHBORS), 
     &        ipr(2*MAX_NEIGHBORS+1), index(4*(MAX_LOCAL+2))
      integer gc_ld(6, MAX_TOTAL_PROCS),
     &        gc_eid(6, MAX_TOTAL_PROCS),
     &        la_size(3, MAX_TOTAL_PROCS),
     &        eid_s(3, MAX_TOTAL_PROCS), mpx, mpy, iproc 
      logical FirstCall
      save FirstCall, h2, N_Neighbors, proc, ipr, index
      data FirstCall/.true./, IfPeriodic/3*0/, Overlap/1,1,0/
      ptrn = 1
c
      if(FirstCall) then
         if(NLocal+2.gt.MAX_LOCAL) then
            print *,' Local grid is too large'
            call MSG_disable(i)
#ifndef DEBUG
            call MPI_FINALIZE()
#endif
            stop
         endif
         h2 = h*h 
         FirstCall = .false.
         MyProc = MSG_myproc()
         NumProc = MSG_nproc()
         GlobalGridSize(1) = N_Proc*NLocal 
         GlobalGridSize(2) = N_Proc*NLocal 
         GlobalGridSize(3) = 1
         ProcGridSize(1) = N_Proc
         ProcGridSize(2) = N_Proc
         ProcGridSize(3) = 1 
         do iproc=1,NumProc
            la_size(1,iproc) = NLocal+2
            la_size(2,iproc) = NLocal+2
            la_size(3,iproc) = 1
            mpy = (iproc-1)/ProcGridSize(1)+1
            mpx = iproc - (mpy-1)*ProcGridSize(1)
            gc_ld(1,iproc) = (mpx-1)*NLocal+1
            gc_ld(2,iproc) = mpx*NLocal
            gc_ld(3,iproc) = (mpy-1)*NLocal+1
            gc_ld(4,iproc) = mpy*NLocal
            gc_ld(5,iproc) = 1
            gc_ld(6,iproc) = 1
         enddo
c
c        set the MSG communication tables (cross-shaped stencil)
c
         N_Neighbors = 0
c
c        set the communications along the x-axis
c
         do iproc=1,NumProc
            mpy = (iproc-1)/ProcGridSize(1)+1
            mpx = iproc - (mpy-1)*ProcGridSize(1)
            do i=1,6
               gc_eid(i,iproc) = gc_ld(i,iproc)
            enddo
            if(mpx.ne.1) gc_eid(1,iproc) = gc_ld(1,iproc) - 1
            if(mpx.ne.N_Proc) gc_eid(2,iproc) = gc_ld(2,iproc) + 1
            eid_s(1,iproc) = 2
            eid_s(2,iproc) = 2
            eid_s(3,iproc) = 1
            if(mpx.ne.1) eid_s(1,iproc) = 1 
         enddo
         call MSG_tp_setup(la_size, eid_s, gc_ld, gc_eid,
     &                     NumProc, MyProc, N_Neighbors, proc, ipr, 
     &                     index, 1, 1, ier)
         if(ier.lt.0) then
           print *,' Error in table setup', ier
           call MSG_disable(i)
#ifndef DEBUG
           call MPI_FINALIZE()
#endif
           stop
         endif
c
c        set the communications along the y-axis
c
         do iproc=1,NumProc
            mpy = (iproc-1)/ProcGridSize(1)+1
            mpx = iproc - (mpy-1)*ProcGridSize(1)
            do i=1,6
               gc_eid(i,iproc) = gc_ld(i,iproc)
            enddo
            if(mpy.ne.1) gc_eid(3,iproc) = gc_ld(3,iproc) - 1
            if(mpy.ne.N_Proc) gc_eid(4,iproc) = gc_ld(4,iproc) + 1
            eid_s(1,iproc) = 2
            eid_s(2,iproc) = 2
            eid_s(3,iproc) = 1
            if(mpy.ne.1) eid_s(2,iproc) = 1
         enddo
         call MSG_tp_setup(la_size, eid_s, gc_ld, gc_eid,
     &                     NumProc, MyProc, N_Neighbors, proc, ipr, 
     &                     index, 1, 1, ier)
         if(ier.lt.0) then
           print *,' Error in table setup', ier
           call MSG_disable(i)
#ifndef DEBUG
           call MPI_FINALIZE()
#endif
           stop
         endif
      endif
c
c     exchange the data
c
      call MSG_tbdx_send(u, buf, 
     &                   N_Neighbors, proc, ipr, index, ptrn, ier)
c
c     calculate the stencil at the internal points
c
      do j=2,NLocal-1
         do i=2,NLocal-1
            w(i,j)=0.25*(u(i-1,j)+u(i,j+1)+u(i,j-1)+u(i+1,j)-h2*f(i,j))
         enddo
      enddo
c
c     wait until all the messages arrive
c
      call MSG_tbdx_receive(u, buf,
     &                      N_Neighbors, proc, ipr, index, ptrn, ier)      
c
c     calculate the stencil at the subdomain boundary
c
      do j=1,NLocal
         i=1
         w(i,j)=0.25*(u(i-1,j)+u(i,j+1)+u(i,j-1)+u(i+1,j)-h2*f(i,j))
         i=NLocal
         w(i,j)=0.25*(u(i-1,j)+u(i,j+1)+u(i,j-1)+u(i+1,j)-h2*f(i,j)) 
      enddo
      do i=1,NLocal
         j=1
         w(i,j)=0.25*(u(i-1,j)+u(i,j+1)+u(i,j-1)+u(i+1,j)-h2*f(i,j))
         j=NLocal
         w(i,j)=0.25*(u(i-1,j)+u(i,j+1)+u(i,j-1)+u(i+1,j)-h2*f(i,j))
      enddo 
      do j=1,NLocal
         do i=1,NLocal
            u(i,j) = w(i,j)
         enddo
      enddo
      return
      end

