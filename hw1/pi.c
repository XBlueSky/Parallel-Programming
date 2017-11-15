#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>

long long int numInCircle = 0,numOfTosses;
long threadNum;
pthread_mutex_t mutex1;

void* calculate_pi(void* thread){
    //srand(time(NULL));
    unsigned int seed = time(NULL);
    long long int t = numOfTosses/threadNum;
    double min = -1.0;
    double max = 1.0;
    long long int i,tossesSum = 0;
    for(i=0;i<t;i++){
	    double x = (max - min)*rand_r(&seed)/(RAND_MAX + 1.0) +min;
        double y = (max - min)*rand_r(&seed)/(RAND_MAX + 1.0) +min;
        double distSqared = x*x + y*y;
        if(distSqared <= 1){
                tossesSum++;
            }  
    }
    pthread_mutex_lock(&mutex1);
    numInCircle += tossesSum;
    pthread_mutex_unlock(&mutex1);
    
//    long rank = (long) thread;
  //  printf("thread %ld",rank);

    return NULL;
}    


int main(int argc,char* argv[]){
    numOfTosses = strtoull(argv[2], NULL, 10);
    
    threadNum = strtol(argv[1], NULL, 10);
    pthread_t* thread_handles;
    thread_handles = (pthread_t*) malloc (threadNum * sizeof(pthread_t));

    long i;
    double piEstimate;
    pthread_mutex_init(&mutex1,NULL);

    for (i=0;i<threadNum;i++){
        pthread_create(&thread_handles[i], NULL, &calculate_pi, (void*)i);
    }
    for (i=0;i<threadNum;i++){
        pthread_join(thread_handles[i],NULL);    
    }
    piEstimate = 4*numInCircle/((double) numOfTosses);
    printf("pi = %lf",piEstimate);

    pthread_mutex_destroy(&mutex1);
    free(thread_handles);
    return 0;

}
