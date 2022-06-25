      program contiguous
      use mpi
      implicit none
      integer ier,nproc,myid,ifile,intsize
      integer istatus(MPI_STATUS_SIZE)
      integer (kind=MPI_OFFSET_KIND) :: idisp
      integer, parameter :: kount=100
      integer ibuf(kount)
      integer i
      real*8 aa1,aa2

      call MPI_INIT(ier)
      call MPI_COMM_RANK(MPI_COMM_WORLD, myid, ier)
      call MPI_COMM_SIZE(MPI_COMM_WORLD, nproc, ier)
       
      aa1=MPI_WTIME()
      do i=1,kount
      ibuf(i)=myid*kount+i
      enddo


      CALL MPI_FILE_OPEN(MPI_COMM_WORLD, 'test',MPI_MODE_WRONLY+MPI_MODE_CREATE, MPI_INFO_NULL, ifile, ier)
      CALL MPI_TYPE_SIZE(MPI_INTEGER, intsize, ier)
      idisp=myid* kount* intsize
      CALL MPI_FILE_SEEK(ifile,idisp,MPI_SEEK_SET, ier)
      CALL MPI_FILE_WRITE(ifile,ibuf,kount,MPI_INTEGER,istatus, ier)
      CALL MPI_FILE_CLOSE(ifile,ier)

      aa2=MPI_WTIME()

      call MPI_FINALIZE(ier)
      end program contiguous
