#include "../cac3.h"

double RT = 6378390.00;


__global__ void distancia(const float ploc_lon,const float ploc_lat,const float prec_lon,const float prec_lat, float distancia){



    
    distancia=sin(ploc_lat)*sin(prec_lat);
    
    distancia+=cos(ploc_lat)*cos(ploc_lon)*cos(prec_lat)*cos(prec_lon);
    
    distancia+=cos(ploc_lat)*sin(ploc_lon)*cos(prec_lat)*sin(prec_lon);
    
    distancia=acos(distancia);


}

