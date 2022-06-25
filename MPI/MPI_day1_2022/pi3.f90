!      Written by In-Ho Lee, KRISS, February (2011)
       program pi_parallel2
       implicit none
       include 'mpif.h'
       real*8  f, a, dx, x, asum, tmp, pi
       integer nx, ix
       integer n1,n2,istart,ifinish
       integer ierr, nproc, myid
       real*8 t1,t2


       f(a) = 4.d0 / (1.d0 + a*a)


       call MPI_INIT(ierr)
       call MPI_COMM_SIZE(MPI_COMM_WORLD,nproc,ierr)
       call MPI_COMM_RANK(MPI_COMM_WORLD,myid,ierr)
       if(myid == 0 .and. nproc > 1) print *,  nproc," processes are alive"
       if(myid == 0 .and. nproc ==1) print *,  nproc," process is alive"

       if(myid == 0) then     ! -------=== { process id =0
       print*, 'number of intervals:'
       read(*,*) nx
                     endif    ! -------=== } process id =0

       t1=MPI_Wtime()
       call MPI_BCAST(nx,1,MPI_INTEGER,0,MPI_COMM_WORLD,ierr)
       dx = 1.0d0 / dfloat(nx)

       asum = 0.0d0
       n1=1 ; n2=nx
       call equal_load(n1,n2,nproc,myid,istart,ifinish)
       do 10 ix = istart, ifinish
         x = dx*(dfloat(ix)-0.5d0)
         asum = asum + f(x)
  10   continue
       tmp = dx*asum

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
       end program pi_parallel2
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
