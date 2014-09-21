/*
 * imprimeRes.cu
 *
 *  Created on: 31/08/2014
 *      Author: alfonso
 */

#include "cac3.h"
#include <stdio.h>
#include <stdlib.h>

extern int cuentaLoc;
extern PLocalidad PLr;
extern PRecurso PRr;

extern unsigned int *h_id_loc;


FILE * fh;
const double RT = 6378.39; //radio terrestre promedio en km


void abreArchivoSSQL(const char * snomarch);
void cierraArchivoSSQL(void);
void insertaRes(float *h_dist_rl, unsigned int *h_id_rl, char *stipo);

PRecurso obtenPRecurso(unsigned int id, char* stipo);
PLocalidad obtenPLocalidad(unsigned int id_loc);
void insertaDato(PLocalidad ploc, PRecurso pr, double dist);

/**
 *
 */
void insertaRes(float *h_dist_rl, unsigned int *h_id_rl, char * stipo) {


	int i = 0;

	for (i = 0; i < cuentaLoc; i++) {
		insertaDato(obtenPLocalidad(*(h_id_loc+i)), obtenPRecurso(*(h_id_rl + i), stipo),
				*(h_dist_rl + i) * RT);

		if(BDEP){
			printf("objeto: %d, id_rec: %d, rads: %f\n",i,*(h_id_rl + i),(*(h_dist_rl + i)));
		}
	}


}

/**
 *
 */
PRecurso obtenPRecurso(unsigned int id, char* stipo) {
	PRecurso pr = PRr;

	while (pr != NULL) {

		if (pr->id == id && strcmp(pr->stipo_infra, stipo)==0) {
			return pr;
		}

		pr = pr->Pnext;
	}
	return NULL;
}

/**
 *
 */
PLocalidad obtenPLocalidad(unsigned int id_loc){

	PLocalidad pl=PLr;

	while(pl!=NULL){
		if(pl->id_loc==id_loc){
			return pl;
		}
		pl = pl->Pnext;
	}

	return NULL;
}


/**
 *
 * @param snomarch
 */
void abreArchivoSSQL(const char * snomarch) {
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

	if (pr == NULL || ploc == NULL)
		return;

	fprintf(fh,
			"INSERT INTO cac4 (estado_id,municipio_id,localidad_id,recurso,"
					"pobtot,dist,estadod_id,municipiod_id,localidadd_id,recurso_id) VALUES (%d,%d,%d,'%s',%d,%7.5lf,%d,%d,%d,%d);\n",
			ploc->estado_id, ploc->municipio_id, ploc->localidad_id,
			pr->stipo_infra, ploc->poblacion, dist, pr->estado_id,
			pr->municipio_id, pr->localidad_id, pr->id);
}
