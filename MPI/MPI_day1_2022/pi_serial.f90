     program main
     double precision  PI25DT
     parameter        (PI25DT = 3.141592653589793238462643d0)
     double precision  pi, h, sum, x, f, a
     integer n, i
!                                function to integrate
     f(a) = 4.d0 / (1.d0 + a*a)

     do
        print *, 'Enter the number of intervals: (0 quits) '
        read(*,*) n
!                                check for quit signal
        if (n .le. 0) exit
!                                calculate the interval size
        h = 1.0d0/n
        sum  = 0.0d0
        do i = 1, n
           x = h * (dble(i) - 0.5d0)
           sum = sum + f(x)
        enddo
!
        pi = h * sum
        print *, 'pi is ', pi, ' Error is', abs(pi - PI25DT)
!
     enddo
!
     end
