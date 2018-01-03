__kernel void histogram(
	__global unsigned int *image_data,
	unsigned int count,
	__global unsigned int *result_data)
{
	const int idx = get_global_id(0);
    int i;
    if(idx<256){
        for(i = 0;i < count; i++){
            if(i%3 == 0 && idx == image_data[i]){
                result_data[idx]++;
            }
        }
    }
    else if(256 <= idx && idx < 512){
        for(i = 0;i < count; i++){
            if(i%3 == 1 && (idx-256) == image_data[i]){
                result_data[idx]++;
            }
        }
    }
    else if(512 <= idx && idx < 768){
        for(i = 0;i < count; i++){
            if(i%3 == 2 && (idx-512) == image_data[i]){
                result_data[idx]++;
            }
        }
    }
}