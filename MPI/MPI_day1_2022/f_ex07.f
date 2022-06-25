      module fmpi
!DEC$ NOFREEFORM
      include "mpif.h"
!DEC$ FREEFORM
      end module
! This program shows how to use fmpi_Alltoall.  Each processor
! send/rec a different  random number to/from other processors.  

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
    call seed_random
! find  data to send
	do i=0,numnodes-1
		call random_number(z)
		scounts(i)=nint(10.0*z)+1
	enddo
	write(*,*)"myid= ",myid," scounts= ",scounts
! send the data
	call MPI_alltoall(	scounts,1,MPI_INTEGER, &
						rcounts,1,MPI_INTEGER, &
	                 	MPI_COMM_WORLD,mpi_err)
	write(*,*)"myid= ",myid," rcounts= ",rcounts
	call mpi_finalize(mpi_err)
end program

              
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

	
