      module fmpi
!DEC$ NOFREEFORM
      include "mpif.h"
!DEC$ FREEFORM
      end module
! This program shows how to use mpi_scatterv.  Each processor gets a
! different amount of data from the root processor.  We use mpi_Gather
! first to tell the root how much data is going to be sent.

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
	integer, allocatable :: sray(:),displacements(:),counts(:),allray(:)
	integer size,mysize,i
	call init
	mysize=myid+1
! calculate displacements and the size of the recv array
! we gather the counts to the root
! counts and displacement arrays are only required on the root
	if(myid == my_root)then
		allocate(counts(0:numnodes-1))
		allocate(displacements(0:numnodes-1))
	endif
	call MPI_Gather(mysize,1,MPI_INTEGER, &
					counts,  1,MPI_INTEGER, &
					my_root,               &
					MPI_COMM_WORLD,mpi_err)

	if(myid == my_root)then
		displacements(0)=0
		do i=1,numnodes-1,1
			displacements(i)=counts(i-1)+displacements(i-1)
		enddo
		size=sum(counts)
	    allocate(sray(size))
	    do i=1,size
	        sray(i)=i
	    enddo
	endif
! different amounts of data for each processor 
! is scattered from the root
    allocate(allray(mysize))
	call MPI_Scatterv(  sray, counts,displacements, MPI_INTEGER, &
	                  allray, mysize,               MPI_INTEGER, &
	                 my_root,                                &
	                 MPI_COMM_WORLD,mpi_err)
	                
	write(*,*)myid," allrray= ",allray
	call mpi_finalize(mpi_err)
end program
