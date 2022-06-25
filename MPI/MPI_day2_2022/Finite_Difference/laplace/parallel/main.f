      program main
c
      implicit none
      include 'mpif.h'
c
      integer nx, ny, np, nyp
      parameter (nx=16,ny=16,np=4,nyp=4)
      integer i, j
      double precision u(0:nx+1,0:nyp+1), unew(0:nx+1,0:nyp+1)
      double precision eps, anormp, anorm
c
      integer ierr, irank, status(MPI_STATUS_SIZE), ndest
c
      character*8 fname
c-----------------------------------------------------------------------
c  tolerance 
c-----------------------------------------------------------------------
      eps = 1.d-5
c-----------------------------------------------------------------------
c  MPI initialization
c-----------------------------------------------------------------------
      call MPI_INIT(ierr)
      call MPI_COMM_RANK(MPI_COMM_WORLD,irank,ierr)
c-----------------------------------------------------------------------
c  initialization of u
c-----------------------------------------------------------------------
      do 10 j=0,nyp+1
      do 10 i=0,nx+1
         u(i,j) = 0.d0
  10  continue
c-----------------------------------------------------------------------
c  Gauss iteration
c-----------------------------------------------------------------------
 100  continue
c-----------------------------------------------------------------------
c  boundary condition
c-----------------------------------------------------------------------
      call bound (nx,nyp,u,irank,np)
      do 20 j=1,nyp
      do 20 i=1,nx
         unew(i,j) = 0.25d0*(u(i-1,j)+u(i+1,j)+u(i,j-1)+u(i,j+1))
  20  continue
c-----------------------------------------------------------------------
c  Compute a norm of difference between u and unew
c-----------------------------------------------------------------------
      anormp = 0.d0
      do 30 j=1,nyp
      do 30 i=1,nx
         anormp = anormp + abs(unew(i,j)-u(i,j))
  30  continue
      call MPI_REDUCE(anormp,anorm,1,MPI_DOUBLE_PRECISION,MPI_SUM,0,
     &                MPI_COMM_WORLD,ierr)
      call MPI_BCAST(anorm,1,MPI_DOUBLE_PRECISION,0,
     &               MPI_COMM_WORLD,ierr)
c-----------------------------------------------------------------------
c  Update u
c-----------------------------------------------------------------------
      do 40 j=1,nyp
      do 40 i=1,nx
         u(i,j) = unew(i,j)
  40  continue
c-----------------------------------------------------------------------
c  boundary condition between processors
c-----------------------------------------------------------------------
c-----------------------------------------------------------------------
c  from i-th ranked process to (i+1)-th ranked process 
c-----------------------------------------------------------------------
      if (irank .eq. (np-1)) then
         ndest = 0
      else
         ndest = irank+1
      endif
c
      call MPI_SEND (u(1,nyp),nx,MPI_DOUBLE_PRECISION,
     &               ndest,irank,MPI_COMM_WORLD,ierr)
c
      call MPI_BARRIER (MPI_COMM_WORLD,ierr)
c
      call MPI_RECV (u(1,0),nx,MPI_DOUBLE_PRECISION,
     &               MPI_ANY_SOURCE,MPI_ANY_TAG,
     &               MPI_COMM_WORLD,status,ierr)
c-----------------------------------------------------------------------
c  from i-th ranked process to (i-1)-th ranked process 
c-----------------------------------------------------------------------
      if (irank .eq. 0) then
         ndest = np-1
      else
         ndest = irank-1
      endif
c
      call MPI_SEND (u(1,1),nx,MPI_DOUBLE_PRECISION,
     &               ndest,irank,MPI_COMM_WORLD,ierr)
c
      call MPI_BARRIER (MPI_COMM_WORLD,ierr)
c
      call MPI_RECV (u(1,nyp+1),nx,MPI_DOUBLE_PRECISION,
     &               MPI_ANY_SOURCE,MPI_ANY_TAG,
     &               MPI_COMM_WORLD,status,ierr)
c-----------------------------------------------------------------------
c  boundary condition
c-----------------------------------------------------------------------
      call bound (nx,nyp,u,irank,np)
c-----------------------------------------------------------------------
c  Gauss iteration
c-----------------------------------------------------------------------
      if (anorm .gt. eps) go to 100
c-----------------------------------------------------------------------
c  write output
c-----------------------------------------------------------------------
      write(fname,900) 'u',irank,'.dat'
c
 900  format (a1,i3.3,a4)
c
      open(unit=10,file=fname)
c
      do 50 j=1,nyp
         write(10,200) (u(i,j),i=1,nx)
  50  continue
c
 200  format(16f5.2)
c-----------------------------------------------------------------------
c  MPI finalization
c-----------------------------------------------------------------------
      call MPI_FINALIZE(ierr)
c-----------------------------------------------------------------------
c  end
c-----------------------------------------------------------------------
      stop
      end
