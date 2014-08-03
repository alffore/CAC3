/**
 * 
 * @file recuperaInfoR.c
 * 
 * @brief Código que recuera la información de los recursos, crea un cola de ellos
 * @author AAFR
 */

#include "cac2.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>


int recuperaInfoRC(char * sarchivo);
void liberaR(PRecurso pr);
PRecurso creaR(int id, int estado_id, int municipio_id, int localidad_id, double lat, double lon, char * stipo);
PRecurso insertaR(PRecurso pr, int id, int estado_id, int municipio_id, int localidad_id, double lat, double lon, char * stipo);



PRecurso PRr = NULL;
int cuentaRec;

/**
 * @brief Función que recupera los recursos 
 * @param sarchivo
 * @return 
 */
int recuperaInfoRC(char * sarchivo) {

    cuentaRec = 0;
    PRecurso pr = PRr;

    int id, edo_id, mun_id, loc_id;
    double lat, lon;
    char stipo[20];

    FILE *fh = fopen(sarchivo, "r");
    while (!feof(fh)) {
        if (fscanf(fh, "%d %d %d %lf %lf %s %d", &edo_id, &mun_id, &loc_id, &lat, &lon, stipo, &id) != 7) break;
//printf("RECUPERADO: %d %d %d %lf %lf %s %d\n",edo_id, mun_id, loc_id, lat, lon, stipo, id);
        if (pr == NULL && PRr == NULL) {
            PRr = creaR(id, edo_id, mun_id, loc_id, lat, lon, stipo);
            pr = PRr;
        } else {
            pr = insertaR(pr, id, edo_id, mun_id, loc_id, lat, lon, stipo);
        }

    }
    printf("cuentaRec: %d\n", cuentaRec);
    fclose(fh);
    return cuentaRec;
}

/**
 * @brief Funcion que inserta un recurso al final de la Cola de Recursos
 * @param pr
 * @param id
 * @param estado_id
 * @param municipio_id
 * @param localidad_id
 * @param lat
 * @param lon
 * @param stipo
 * @return PRecurso Puntero al recurso insertado
 */
PRecurso insertaR(PRecurso pr, int id, int estado_id, int municipio_id, int localidad_id, double lat, double lon, char * stipo) {


    pr->Pnext = creaR(id, estado_id, municipio_id, localidad_id, lat, lon, stipo);

    return pr->Pnext;
}

/**
 * @param id
 * @param estado_id
 * @param municipio_id
 * @param localidad_id
 * @param lat
 * @param lon
 * @param stipo
 * @return 
 */
PRecurso creaR(int id, int estado_id, int municipio_id, int localidad_id, double lat, double lon, char * stipo) {

    PRecurso pr = (PRecurso) malloc(sizeof (Recurso));
    cuentaRec++;
    pr->id = id;
    pr->estado_id = estado_id;
    pr->municipio_id = municipio_id;
    pr->localidad_id = localidad_id;

    pr->lat = M_PI * lat / 180.0;
    pr->lon = M_PI * lon / 180.0;

    pr->stipo_infra = malloc(strlen(stipo) * sizeof (char));
    strcpy(pr->stipo_infra, stipo);

    pr->Pnext = NULL;

    return pr;


}

/**
 * 
 * @param pr
 */
void liberaR(PRecurso pr) {

    if (pr != NULL) {
        free(pr->stipo_infra);

        liberaR(pr->Pnext);
        cuentaRec--;
        free(pr);
    }

}