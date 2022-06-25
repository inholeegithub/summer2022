      program main
      integer MAX_ROWS, MAX_COLS, rows, cols
      parameter (MAX_ROWS = 1000, MAX_COLS = 1000)
      double precision a(MAX_ROWS,MAX_COLS), b(MAX_COLS), c(MAX_ROWS)

      integer i, j

      rows   = 100
      cols   = 100

      do j = 1,cols
         b(j) = 1.0
         do i = 1,rows
            a(i,j) = i
         enddo
      enddo

      do i=1,rows
         c(i) = 0.0
         do j=1,cols
            c(i) = c(i) + a(i,j)*b(j)
         enddo
         print*, i, c(i)
      enddo

      end
