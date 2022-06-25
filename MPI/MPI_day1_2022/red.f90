      program write_individual_pointer
      use mpi
      implicit none
      integer ier,nproc,myid,ifile,intsize
      integer mode,info,ietype,ifiletype
      integer istatus(MPI_STATUS_SIZE)
      integer (kind=MPI_OFFSET_KIND) :: idisp
      integer, parameter :: kount=100
      integer ibuf(kount)
      integer i,itest
      real*8 aa1,aa2

      call MPI_INIT(ier)
      call MPI_COMM_RANK(MPI_COMM_WORLD, myid, ier)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, nproc, ier)

      mode=MPI_MODE_RDONLY
      info=0

      call MPI_TYPE_EXTENT(MPI_INTEGER,intsize,ier)
       
      aa1=MPI_WTIME()
      do i=1,kount
      ibuf(i)=myid*kount+i
      enddo

      

      CALL MPI_FILE_OPEN(MPI_COMM_WORLD, 'test',mode, info, ifile, ier)
      idisp=myid* kount* intsize
      ietype=MPI_INTEGER
      ifiletype=MPI_INTEGER
      CALL MPI_FILE_SET_VIEW(ifile,idisp,ietype,ifiletype,'native',info, ier)
      CALL MPI_FILE_READ(ifile,itest,1,MPI_INTEGER,istatus, ier)

      write(6,*) 'hello form myid',myid,'i read:', itest,'.'

      CALL MPI_FILE_CLOSE(ifile,ier)

      aa2=MPI_WTIME()

      call MPI_FINALIZE(ier)
      end program write_individual_pointer
