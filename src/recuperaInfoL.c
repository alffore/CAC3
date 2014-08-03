/**
 * @file recuperaInfoL.c
 * @author AAFR
 */

#include "cac2.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>



int recuperaInfoLoc(char * sarchivo);


void liberaL(PLocalidad pr);
PLocalidad creaL(int estado_id, int municipio_id, int localidad_id, double lat, double lon, int pob);
PLocalidad insertaL(PLocalidad pl, int estado_id, int municipio_id, int localidad_id, double lat, double lon, int pob);


PLocalidad PLr = NULL;
int cuentaLoc;

/**
 * 
 * @param sarchivo
 * @return 
 */
int recuperaInfoLoc(char * sarchivo) {

    cuentaLoc = 0;
    PLocalidad pr = PLr;

    int edo_id, mun_id, loc_id, pob;
    double lat, lon;


    FILE *fh = fopen(sarchivo, "r");

    while (!feof(fh)) {
        if (fscanf(fh, "%d %d %d %lf %lf %d", &edo_id, &mun_id, &loc_id, &lat, &lon, &pob) != 6) break;
        //printf("%lf %d\n",lat,pob);

        if (pr == NULL && PLr == NULL) {
            PLr = creaL(edo_id, mun_id, loc_id, lat, lon, pob);
            pr = PLr;
        } else {
            pr = insertaL(pr, edo_id, mun_id, loc_id, lat, lon, pob);
        }



    }
    printf("cuentaLoc: %d\n", cuentaLoc);
    fclose(fh);
    return cuentaLoc;
}

/**
 * 
 * @param pl
 * @param estado_id
 * @param municipio_id
 * @param localidad_id
 * @param lat
 * @param lon
 * @param pob
 * @return 
 */
PLocalidad insertaL(PLocalidad pl, int estado_id, int municipio_id, int localidad_id, double lat, double lon, int pob) {


    pl->Pnext = creaL(estado_id, municipio_id, localidad_id, lat, lon, pob);

    return pl->Pnext;
}

/**
 * 
 * @param estado_id
 * @param municipio_id
 * @param localidad_id
 * @param lat
 * @param lon
 * @param pob
 * @return 
 */
PLocalidad creaL(int estado_id, int municipio_id, int localidad_id, double lat, double lon, int pob) {

    PLocalidad pr = (PLocalidad) malloc(sizeof (Localidad));
    cuentaLoc++;
    pr->estado_id = estado_id;
    pr->municipio_id = municipio_id;
    pr->localidad_id = localidad_id;

    pr->lat = M_PI * lat / 180.0;
    pr->lon = M_PI * lon / 180.0;

    pr->poblacion = pob;


    return pr;


}

/**
 * 
 * @param pr
 */
void liberaL(PLocalidad pr) {

    if (pr != NULL) {
        liberaL(pr->Pnext);
        cuentaLoc--;
        free(pr);
    }

}