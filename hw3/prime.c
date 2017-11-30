#include <stdio.h>
#include <stdlib.h>
#include "mpi.h"
#include <math.h>

int isprime(long long int n) {
    long long int i,squareroot;
    if (n>10) {
    squareroot = (long long int) sqrt(n);
    for (i=3; i<=squareroot; i=i+2)
        if ((n%i)==0)
        return 0;
    return 1;
    }
    else
    return 0;
}

int main(int argc, char *argv[])
{
    long long int pc,       /* prime counter */
        foundone; /* most recent prime found */
    long long int n, limit,part;
    int rank,size;

    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    pc = 0;
    foundone = 0;

    if(rank == 0){
        sscanf(argv[1],"%llu",&limit);
        printf("Starting. Numbers to be scanned= %lld\n",limit);
        pc=4;     /* Assume (2,3,5,7) are counted here */
        part = limit/size;
    }
    MPI_Bcast(&part, 1, MPI_LONG_LONG_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(&limit, 1, MPI_LONG_LONG_INT, 0, MPI_COMM_WORLD);
    
    long long int start = rank * part;
    long long int end = start + part;
    if(rank == size -1) end = limit+1;
    if(start % 2 == 0) start++;
    for (; start<end; start+=2) {
        if (isprime(start)) {
            pc++;
            foundone = start;
        }			
    }
    long long int pcSum,primeMax;
    MPI_Reduce(&pc, &pcSum, 1, MPI_LONG_LONG_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    MPI_Reduce(&foundone, &primeMax, 1, MPI_LONG_LONG_INT, MPI_MAX, 0,MPI_COMM_WORLD);

    if(rank == 0)
        printf("Done. Largest prime is %lld Total primes %lld\n",primeMax,pcSum);

    MPI_Finalize();
    return 0;
} 