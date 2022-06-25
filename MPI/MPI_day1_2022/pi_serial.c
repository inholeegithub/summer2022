#include <stdio.h>
#include <math.h>

int main(int argc, char *argv[])
{
  int n, i;
  double PI25DT = 3.141592653589793238462643;
  double pi, h, sum, x;
  while (1) {
     printf("Enter the number of intervals: (0 quits) ");
     scanf("%d",&n);
     if (n == 0)
         break;
     else {
         h   = 1.0 / (double) n;
         sum = 0.0;
         for (i = 1; i <= n; i++) {
             x = h * ((double)i - 0.5);
             sum += (4.0 / (1.0 + x*x));
         }
         pi = h * sum;
         printf("pi is approximately %.16f, Error is %.16f\n",
                    pi, fabs(pi - PI25DT));
     }
  }
  return 0;
}
