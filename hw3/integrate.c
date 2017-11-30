#include <stdio.h>
#include <math.h>
#include "mpi.h"

#define PI 3.1415926535

int main(int argc, char **argv) 
{
    long long i, num_intervals, part;
    double rect_width, area, sum, x_middle, sumTotal; 

    int rank,size;
    MPI_Init(&argc,&argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if(rank ==0){
        sscanf(argv[1],"%llu",&num_intervals);
        part = num_intervals/size;
    }
    MPI_Bcast(&part, 1, MPI_LONG_LONG, 0, MPI_COMM_WORLD);
    MPI_Bcast(&num_intervals, 1, MPI_LONG_LONG, 0, MPI_COMM_WORLD);

    rect_width = PI / num_intervals;

    long long start = rank * part + 1;
    long long end = start + part;
    if(rank == size -1) end = num_intervals + 1;
    sum = 0;
    sumTotal = 0;

    for(; start < end; start++) {

    /* find the middle of the interval on the X-axis. */ 

    x_middle = (start - 0.5) * rect_width;
    area = sin(x_middle) * rect_width; 
    sum = sum + area;
    } 
    MPI_Reduce(&sum, &sumTotal, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);
    
    if(rank ==0)
        printf("The total area is: %f\n", (float)sumTotal);

    return 0;
}   