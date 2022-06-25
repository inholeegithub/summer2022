!234567890
      implicit none
      include 'mpif.h'
      integer, allocatable :: isend(:), irecv(:)
      integer, allocatable :: ircnt(:), idisp(:)
      integer ierr,nproc,myid
      integer i,iscnt
      integer ndsize

      call MPI_INIT(ierr)
      call MPI_COMM_SIZE(MPI_COMM_WORLD,nproc,ierr)
      call MPI_COMM_RANK(MPI_COMM_WORLD,myid,ierr)

      ndsize=10
      allocate(isend(ndsize),irecv(nproc*ndsize))
      allocate(ircnt(0:nproc-1),idisp(0:nproc-1))


      ircnt=ndsize
      idisp(0)=0
      do i=1,nproc-1
      idisp(i)=idisp(i-1)+ircnt(i)
      enddo

      do i=1,ndsize           ! node specific data with a data-size ndsize
      isend(i)=myid+1
      enddo

      iscnt=ndsize
      call MPI_GATHERV(isend, iscnt, MPI_INTEGER, irecv, ircnt, idisp, MPI_INTEGER,0, MPI_COMM_WORLD, ierr)


      if(myid == 0)then
      print*, 'irecv= ',irecv
      endif

      deallocate(ircnt,idisp)
      deallocate(isend,irecv)
      call MPI_FINALIZE(ierr)
      stop
      end
