      module fmpi
!DEC$ NOFREEFORM
      include "mpif.h"
!DEC$ FREEFORM
      end module
! This program shows how to use fmpi_Gatherv.  Each processor sends a
! different amount of data to the root processor.  We use fmpi_Gather
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
	integer, allocatable :: myray(:),displacements(:),counts(:),allray(:)
	integer size,mysize,i
	call init
	mysize=myid+1
	allocate(myray(mysize))
	myray=myid+1
! counts and displacement arrays are only required on the root
	if(myid == my_root)then
		allocate(counts(0:numnodes-1))
		allocate(displacements(0:numnodes-1))
	endif
! we gather the counts to the root
	call MPI_Gather(myray(1),1,MPI_INTEGER, &
					counts,  1,MPI_INTEGER, &
					my_root,               &
					MPI_COMM_WORLD,mpi_err)
! calculate displacements and the size of the recv array
	if(myid == my_root)then
		displacements(0)=0
		do i=1,numnodes-1,1
			displacements(i)=counts(i-1)+displacements(i-1)
		enddo
		size=sum(counts)
		allocate(allray(size))
	endif
! different amounts of data from each processor 
! is gathered to the root
	call MPI_Gatherv(myray, mysize,              MPI_INTEGER, &
	                 allray,counts,displacements,MPI_INTEGER, &
	                 my_root,                                &
	                 MPI_COMM_WORLD,mpi_err)
	                
	if(myid == my_root)then
		write(*,*)allray
	endif
	call mpi_finalize(mpi_err)
end program
