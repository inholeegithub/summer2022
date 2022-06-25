      module fmpi
!DEC$ NOFREEFORM
      include "mpif.h"
!DEC$ FREEFORM
      end module
! This program shows how to use fmpi_Alltoallv.  Each processor 
! send/rec a different and random amount of data to/from other
! processors.  
! We use fmpi_Alltoall to tell how much data is going to be sent.

module global
	integer numnodes,myid,mpi_err
	integer, parameter :: my_root=0
end module
subroutine init
    use fmpi
    use global
    implicit none
! do the mpi init stuff
    call MPI_INIT( mpi_err )
    call MPI_COMM_SIZE( MPI_COMM_WORLD, numnodes, mpi_err )
    call MPI_Comm_rank(MPI_COMM_WORLD, myid, mpi_err)
end subroutine init

program test1
! poe a.out -procs 3 -rmpool 1
	use fmpi
	use global
	implicit none
	integer, allocatable :: sray(:),rray(:)
	integer, allocatable :: sdisp(:),scounts(:),rdisp(:),rcounts(:)
	integer ssize,rsize,i,k,j
	real z
	call init	
! counts and displacement arrays
	allocate(scounts(0:numnodes-1))
	allocate(rcounts(0:numnodes-1))
	allocate(sdisp(0:numnodes-1))
	allocate(rdisp(0:numnodes-1))
! set counts to send to other processors
! seed the random number generator with a
! different number on each processor
    call seed_random
	do i=0,numnodes-1
		call random_number(z)
		scounts(i)=nint(10.0*z)+1
	enddo
! tell the other processors how much data is coming
	write(*,*)"myid= ",myid," scounts= ",scounts
	call MPI_alltoall(	scounts,1,MPI_INTEGER, &
						rcounts,1,MPI_INTEGER, &
	                 	MPI_COMM_WORLD,mpi_err)
	write(*,*)"myid= ",myid," rcounts= ",rcounts
! calculate displacements and the size of the arrays
	sdisp(0)=0
	do i=1,numnodes-1
		sdisp(i)=scounts(i-1)+sdisp(i-1)
	enddo
	rdisp(0)=0
	do i=1,numnodes-1
		rdisp(i)=rcounts(i-1)+rdisp(i-1)
	enddo
	ssize=sum(scounts)
	rsize=sum(rcounts)
! allocate send and rec arrays
	allocate(sray(0:ssize-1))
	allocate(rray(0:rsize-1))
	sray=myid
! send/rec different amounts of data to/from each processor 
	call MPI_alltoallv(	sray,scounts,sdisp,MPI_INTEGER, &
						rray,rcounts,rdisp,MPI_INTEGER, &
	                 	MPI_COMM_WORLD,mpi_err)
	                
	write(*,*)"myid= ",myid,"    rray= ",rray
	call mpi_finalize(mpi_err)
end program

!typical output
! myid=  0  scounts=  1 5 2
! myid=  0  rcounts=  1 1 1
! myid=  0     rray=  0 1 2
  
! myid=  1  scounts=  1 7 3
! myid=  1  rcounts=  5 7 5
! myid=  1     rray=  0 0 0 0 0 1 1 1 1 1 1 1 2 2 2 2 2
  
! myid=  2  scounts=  1 5 10
! myid=  2  rcounts=  2 3 10
! myid=  2     rray=  0 0 1 1 1 2 2 2 2 2 2 2 2 2 2

              
subroutine seed_random
	use global
	implicit none
	integer the_size,j
	integer, allocatable :: seed(:)
	real z
	call random_seed(size=the_size) ! how big is the intrisic seed? 
    allocate(seed(the_size))        ! allocate space for seed 
    do j=1,the_size                 ! create the seed 
    	seed(j)=abs(myid*10)+(j*myid*myid)+100  ! abs is generic 
    enddo 
    call random_seed(put=seed)      ! assign the seed 
    deallocate(seed)
end subroutine

	
