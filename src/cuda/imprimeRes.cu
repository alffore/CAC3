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

FILE * fh;
double RT = 6378390.00;
char nombrearchivo[] = "cac4_salida.sql";

void abreArchivoSSQL(char * snomarch);
void cierraArchivoSSQL(void);
void insertaRes(float *h_dist_rl, unsigned int *h_id_rl, char *stipo);

PRecurso obtenPRecurso(int id, char* stipo);
void insertaDato(PLocalidad ploc, PRecurso pr, double dist);

/**
 *
 */
void insertaRes(float *h_dist_rl, unsigned int *h_id_rl, char * stipo) {

	abreArchivoSSQL(nombrearchivo);
	int i = 0;

	for (i = 0; i < cuentaLoc; i++) {
		insertaDato((PLr + i), obtenPRecurso(*(h_id_rl + i), stipo),
				*(h_dist_rl + i) * RT);
	}

	cierraArchivoSSQL();
}

PRecurso obtenPRecurso(int id, char* stipo) {
	PRecurso pr = PRr;

	while (pr != NULL) {

		if (pr->id == id && strcmp(pr->stipo_infra, stipo)) {
			return pr;
		}

		pr = pr->Pnext;
	}
	return NULL;
}

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

	if (pr == NULL)
		return;

	fprintf(fh,
			"INSERT INTO cac4 (estado_id,municipio_id,localidad_id,recurso,"
					"pobtot,dist,estadod_id,municipiod_id,localidadd_id,recurso_id) VALUES (%d,%d,%d,'%s',%d,%7.5lf,%d,%d,%d,%d);\n",
			ploc->estado_id, ploc->municipio_id, ploc->localidad_id,
			pr->stipo_infra, ploc->poblacion, dist, pr->estado_id,
			pr->municipio_id, pr->localidad_id, pr->id);
}
