c http://www.new-npac.org/projects/cdroms/cewes-1999-06-vol2/cps615course/cps615fall96/examples/pi.f
c**********************************************************************
c     This program calculates the value of pi, using numerical integration
c     with parallel processing.  The user selects the number of points of
c     integration.  By selecting more points you get more accurate results
c     at the expense of additional computation
c     
c     This version is written using p4 calls to handle message passing
c     It should run without changes on most workstation clusters and MPPs.
c     
c     Each node: 
c     1) receives the number of rectangles used in the approximation.
c     2) calculates the areas of it's rectangles.
c     3) Synchronizes for a global summation.
c     Node 0 prints the result.
c     
c     Constants:
c     
c     SIZETYPE    initial message to the cube
c     ALLNODES    used to load all nodes in cube with a node process
c     INTSIZ      four bytes for an integer
c     DBLSIZ      eight bytes for double precision
c     
c     Variables:
c     
c     pi  the calculated result
c     n   number of points of integration.  
c     x           midpoint of each rectangle's interval
c     f           function to integrate
c     sum,pi      area of rectangles
c     tmp         temporary scratch space for global summation
c     i           do loop index
c****************************************************************************
      program main

      include 'mpif.h'

      double precision  PI25DT
      parameter        (PI25DT = 3.141592653589793238462643d0)

      integer   INTSIZ , DBLSIZ,  ALLNODES,   ANYNODE
      parameter(INTSIZ=4,DBLSIZ=8,ALLNODES=-1,ANYNODE=-1)

      double precision  pi, h, sum, x, f, a, temp
      integer n, myid, numnodes, i, rc
      integer sumtype, sizetype, masternode
      integer status(3)

c     function to integrate
      f(a) = 4.d0 / (1.d0 + a*a)

      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numnodes, ierr )
c     print *, "Process ", myid, " of ", numnodes, " is alive"

      sizetype   = 10
      sumtype    = 17
      masternode =  0
      
 10      if ( myid .eq. 0 ) then

         write(6,98)
 98            format('Enter the number of intervals: (0 quits)')
         read(5,99)n
 99            format(i10)

         do i=1,numnodes-1
            call MPI_SEND(n,1,MPI_INTEGER,i,sizetype,MPI_COMM_WORLD,rc)
         enddo

      else
         
         call MPI_RECV(n,1,MPI_INTEGER,masternode,sizetype,
     +        MPI_COMM_WORLD,status,rc)

      endif

c     check for quit signal
      if ( n .le. 0 ) goto 30

c     calculate the interval size
      h = 1.0d0/n

      sum  = 0.0d0
      do 20 i = myid+1, n, numnodes
         x = h * (dble(i) - 0.5d0)
         sum = sum + f(x)
 20         continue
      pi = h * sum

      if (myid .ne. 0) then

         call MPI_SEND(pi,1,MPI_DOUBLE_PRECISION,masternode,sumtype,
     +        MPI_COMM_WORLD,rc)

      else

         do i=1,numnodes-1
            call MPI_RECV(temp,1,MPI_DOUBLE_PRECISION,i,sumtype,
     +           MPI_COMM_WORLD,status,rc)
            pi = pi + temp
         enddo
      endif

c     node 0 prints the answer.
      if (myid .eq. 0) then
         write(6, 97) pi, abs(pi - PI25DT)
 97            format('  pi is approximately: ', F18.16,
     +        '  Error is: ', F18.16)
      endif

      goto 10

 30      call MPI_FINALIZE(rc)
      end

