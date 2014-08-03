/**
 * @file distancias.c
 * 
 * @author AAFR
 * 
 */

#include "cac2.h"
#include <math.h>


double dist(Recurso p1, Recurso p2);
double distLR(PLocalidad ploc,PRecurso prec);


double RT = 6378390.00;

/**
 * @brief Distancia entre 2 puntos sobre la superficie terrestre y en linea geodesica (radianes)
 * @param p1 Primer punto
 * @param p2 Segundo Punto
 * @return 
 */
double dist(Recurso p1, Recurso p2){
    double daux=0.0;
    
    
    daux=sin(p1.lat)*sin(p2.lat);
    
    daux+=cos(p1.lat)*cos(p1.lon)*cos(p2.lat)*cos(p2.lon);
    
    daux+=cos(p1.lat)*sin(p1.lon)*cos(p2.lat)*sin(p2.lon);
    
    
    daux=RT*acos(daux);
    
    return daux;
}

/**
 * @brief Función que calcula la distancia geodesica entre una localidad y un recurso cultural
 * 
 * 
 * 
 * @param ploc
 * @param prec
 * @return 
 * 
 * @see Localidad
 */
double distLR(PLocalidad ploc,PRecurso prec){
    double daux=0.0;
    
    daux=sin(ploc->lat)*sin(prec->lat);
    
    daux+=cos(ploc->lat)*cos(ploc->lon)*cos(prec->lat)*cos(prec->lon);
    
    daux+=cos(ploc->lat)*sin(ploc->lon)*cos(prec->lat)*sin(prec->lon);
    
    
    daux=RT*acos(daux);
    
    return daux;
    
}