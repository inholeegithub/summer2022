      module fmpi
!DEC$ NOFREEFORM
      include "mpif.h"
!DEC$ FREEFORM
      end module
! This program is designed to show how to set up a new communicator. 
! We set up a communicator that includes all but one of the processors,
! The last processor is not part of the new communcator, TIMS_COMM_WORLD
! We use the routine MPI_Group_rank to find the rank within the new
! connunicator.  For the last processor the rank is MPI_UNDEFINED because
! it is not part of the communicator.  For this processor we call get_input
! The processors in TIMS_COMM_WORLD pass a token between themselves in the
! subroutine pass_token.  The remaining processor gets input, i, from the terminal
! and passes it to processor 1 of MPI_COMM_WORLD.  If i > 100 the program stops
! global variables
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
	integer, allocatable :: will_use(:)
	integer TIMS_COMM_WORLD
	integer ijk,new_group,old_group,num_used,used_id
	real z
	call init
! num_used is the # of processors that are part of the new communicator
! for this case hardwire to not include 1 processor
    num_used=numnodes-1
    if(numnodes .gt. num_used)then
! get our old group from MPI_COMM_WORLD
        call MPI_COMM_GROUP(MPI_COMM_WORLD,old_group,mpi_err)
! create a new group from the old group 
! that will contain a subset of the  processors
		allocate(will_use(0:num_used-1))
        do ijk=0,num_used-1
			will_use(ijk)=ijk
        enddo
        call MPI_GROUP_INCL(old_group,num_used,will_use,new_group    ,mpi_err)
! create the new communicator
        call MPI_COMM_CREATE(MPI_COMM_WORLD,new_group,TIMS_COMM_WORLD, mpi_err)
! test to see if I am part of new_group.
        call MPI_GROUP_RANK(new_group,used_id, mpi_err)
        if(used_id .eq. MPI_UNDEFINED)then
! if not part of the new group do keyboard i/o.
			call get_input
			call MPI_Barrier(MPI_COMM_WORLD ,mpi_err)
			call MPI_FINALIZE(mpi_err)
 			stop
        endif
    else
        call MPI_COMM_DUP( MPI_COMM_WORLD, TIMS_COMM_WORLD, mpi_err )
    endif
    call MPI_COMM_RANK( TIMS_COMM_WORLD, myid, mpi_err )
    call MPI_COMM_SIZE( TIMS_COMM_WORLD, numnodes, mpi_err )
    call pass_token(TIMS_COMM_WORLD)
    write(*,*)"back"
    call MPI_Barrier(MPI_COMM_WORLD ,mpi_err)
    call MPI_FINALIZE(mpi_err)
    stop
end program   
    
    
subroutine pass_token(THE_COMM_WORLD)
	use fmpi
	use global
	implicit none
	integer THE_COMM_WORLD
	integer my_tag,j,i,to,from,ierr,status(MPI_STATUS_SIZE)
	logical flag
    my_tag=1234
    j=0
    flag=.false.
    to=myid+1
    if(to .eq. numnodes)to=0
    from=myid-1
    if(from .lt. 0)from=numnodes-1
    i=0
	do while(i < 100)
		if(myid .eq. j)then
			call MPI_IPROBE(MPI_ANY_SOURCE,MPI_ANY_TAG, &
	    	                MPI_COMM_WORLD,flag,status,ierr)
	    	if(flag)then
	    		call MPI_RECV(i,1,MPI_INTEGER,MPI_ANY_SOURCE,MPI_ANY_TAG, &
	    		              MPI_COMM_WORLD,status,ierr)
	    	    write(*,*)"got i ",i
	    	endif
	    	call MPI_SEND(i,1, MPI_INTEGER,to,my_tag,THE_COMM_WORLD,ierr)
	    	j=-1
	    else
	    	call MPI_RECV(i,1,MPI_INTEGER,from,my_tag,THE_COMM_WORLD,status,ierr)
	    	j=myid
	    endif
    enddo
    if(myid .lt. numnodes-1) &
    	call MPI_SEND(i,1, MPI_INTEGER,to,my_tag,THE_COMM_WORLD,ierr)
end subroutine
    
subroutine get_input
   use fmpi
   use global
   implicit none
   integer to,my_tag,i,ierr
   to=0
   my_tag=0
   i=0
   open(12,file="ex10.in")
   do while(i < 100)
   		write(*,*)"waiting for input:"
   		read(12,*)i
   		write(*,*)"i =",i
   		call MPI_SEND(i,1, MPI_INTEGER,to,my_tag,MPI_COMM_WORLD,ierr)
   		enddo
   return
end subroutine
