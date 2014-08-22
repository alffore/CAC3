#include "../cac3.h"

double RT = 6378390.00;


__global__ void distancia(const float* ploc_lon,const float* ploc_lat,const float* prec_lon,const float* prec_lat, float* distancia){


int id=threadIdx.x + blockDim.x * blockIdx.x;

    
    distancia=sin(pl_lat[i])*sin(pr_lat);
    
    distancia+=cos(pl_lat[i])*cos(ploc_lon)*cos(prec_lat)*cos(prec_lon);
    
    distancia+=cos(pl_lat[i])*sin(ploc_lon)*cos(prec_lat)*sin(prec_lon);
    
    distancia=acos(distancia);


}

