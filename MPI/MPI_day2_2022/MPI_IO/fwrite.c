#include <stdio.h>

#define SIZE (1024*1024)

int main (int argc, char **argv)
{
  FILE * pf;
  int i, buffer[SIZE];
  for (i=0; i<SIZE; i++) buffer[i] = i;
  pf = fopen ("/home/guest/jskim/datafile", "wb");
  fwrite (buffer , sizeof(int), sizeof(buffer), pf);
  fclose (pf);
  return 0;
}
