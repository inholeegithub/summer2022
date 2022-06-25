! Shows a short cut method to create a collection of communicators.
! All processors with the "same color" will be in the same communicator.
! In this case the color is either 0 or 1 for even or odd processors.
! Index gives rank in new communicator.
      program comm_split
      include "mpif.h"
      integer color,zero_one
      call mpi_init( mpi_err )
      call mpi_comm_size( mpi_comm_world, numnodes, mpi_err )
      call mpi_comm_rank( mpi_comm_world, myid, mpi_err )
      color=mod(myid,2) !color is either 1 or 0
      call mpi_comm_split(mpi_comm_world,color,myid,new_comm,mpi_err)
      call mpi_comm_rank( new_comm, new_id, mpi_err )
      call mpi_comm_size( new_comm, new_nodes, mpi_err )
      zero_one = -1
      if(new_id==0)zero_one = color
      call mpi_bcast(zero_one,1,mpi_integer,0, new_comm,mpi_err)
      if(zero_one==0)then
       write(*,*)myid," part of even processor communicator ",new_id
      endif
      if(zero_one==1)then
       write(*,*)myid," part of odd processor communicator ",new_id
      endif
      write(*,*)"old_id=", myid, "new_id=", new_id
      call mpi_finalize(mpi_err)
      end program
      