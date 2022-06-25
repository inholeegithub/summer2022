!      Written by In-Ho Lee, KRISS, February (2011)
       program pi_parallel3
       implicit none
       include 'mpif.h'
       real*8  f, x, tmp, pi
       integer nx, ix
       integer nn1,nn2,istart,ifinish,m1
       integer ierr, nproc, myid
       real*8 t1,t2
       real*8 aa,bb
       real*8 a1,b1
       external func


       call MPI_INIT(ierr)
       call MPI_COMM_SIZE(MPI_COMM_WORLD,nproc,ierr)
       call MPI_COMM_RANK(MPI_COMM_WORLD,myid,ierr)
       if(myid == 0 .and. nproc > 1) print *,  nproc," processes are alive"
       if(myid == 0 .and. nproc ==1) print *,  nproc," process is alive"

       if(myid == 0) then     ! -------=== { process id =0
       print*, 'Simpson s rule'
       print*, 'number of intervals:'
       read(*,*) nx
                     endif    ! -------=== } process id =0

       t1=MPI_Wtime()
       call MPI_BCAST(nx,1,MPI_INTEGER,0,MPI_COMM_WORLD,ierr)
       aa=0.d0
       bb=1.d0

       nn1=1 ; nn2=nx
       call equal_load(nn1,nn2,nproc,myid,istart,ifinish)

       m1=0
       do ix=istart,ifinish
       m1=m1+1
       enddo
       a1=aa+(bb-aa)/float(nx-1)*float(istart-1)
       b1=aa+(bb-aa)/float(nx-1)*float(ifinish-1)
       call simpson(func,m1,a1,b1,tmp)

       call MPI_REDUCE(tmp,pi,1,MPI_DOUBLE_PRECISION,MPI_SUM,0,MPI_COMM_WORLD,ierr)
       if(myid == 0) then     ! -------=== { process id =0
       print*, pi
                     endif    ! -------=== } process id =0

       t2=MPI_Wtime()
       if(myid == 0) then     ! -------=== { process id =0
       print*, t2-t1,' sec '
                     endif    ! -------=== } process id =0

       call MPI_FINALIZE(ierr)
       stop
       end program pi_parallel3


!234567890
       subroutine equal_load(n1,n2,nproc,myid,istart,ifinish)
!      Written by In-Ho Lee, KRISS, September (2006)
       implicit none
       integer nproc,myid,istart,ifinish,n1,n2
       integer iw1,iw2
       iw1=(n2-n1+1)/nproc ; iw2=mod(n2-n1+1,nproc)
       istart=myid*iw1+n1+min(myid,iw2)
       ifinish=istart+iw1-1 ; if(iw2 > myid) ifinish=ifinish+1
!      print*, n1,n2,myid,nproc,istart,ifinish
       if(n2 < istart) ifinish=istart-1
       return
       end
       subroutine simpson(f,n,aa,bb,rslt)
!      Written by In-Ho Lee, KRISS, 2006
       implicit none
       real*8 f
       integer n
       real*8 rslt,aa,bb
       real*8 h,xx
       integer j
       logical lodd
       integer m

       m=2*n
       h=(bb-aa)/float(m)
       rslt=(f(aa)+f(bb))
       lodd=.true.
       do j=1,m-1
        xx=aa+h*float(j)
       if(lodd)then
       rslt=rslt+4.0d0*f(xx)
       else
         rslt=rslt+2.0d0*f(xx)
       endif
       lodd=(.not. lodd)
       enddo

       rslt=rslt*h/3.0d0
       return
       end

       real*8 function func(x)
       implicit none
       real*8 x

       func = 4.d0 / (1.d0 + x*x)
       return
       end


