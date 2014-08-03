/**
 * @file salida.c
 * 
 * @author AAFR
 */

#include "cac2.h"
#include <stdio.h>
#include <stdlib.h>


FILE * fh;

void abreArchivoSSQL(char * snomarch);
void cierraArchivoSSQL(void);
void insertaDato(PLocalidad ploc, PRecurso pr, double dist);

/**
 * 
 * @param snomarch
 */
void abreArchivoSSQL(char * snomarch) {
    fh = fopen(snomarch, "w");
}

/**
 * 
 */
void cierraArchivoSSQL(void) {
    fclose(fh);
}

/**
 * 
 * @param ploc
 * @param pr
 * @param dist
 * @param stipo
 */
void insertaDato(PLocalidad ploc, PRecurso pr, double dist) {

    if (pr == NULL)return;

    fprintf(fh, "INSERT INTO cac3 (estado_id,municipio_id,localidad_id,recurso,"
            "pobtot,dist,estadod_id,municipiod_id,localidadd_id,recurso_id) VALUES (%d,%d,%d,'%s',%d,%7.5lf,%d,%d,%d,%d);\n"
            , ploc->estado_id, ploc->municipio_id, ploc->localidad_id,
            pr->stipo_infra, ploc->poblacion, dist, pr->estado_id, pr->municipio_id, pr->localidad_id, pr->id);
}
