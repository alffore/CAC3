/*
 * algoritmo.cu
 *
 *  Created on: 31/08/2014
 *      Author: AAFR <alffore@gmail.com>
 */

#include "cac3.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

//coordenadas geograficas de las localidades
float *h_lon_loc = NULL;
float *h_lat_loc = NULL;

//coordenadas geograficas de los recursos
float *h_lon_rec = NULL;
float *h_lat_rec = NULL;

//id de los recursos
unsigned int *h_id_rec = NULL;

//resultados del calculo
float *h_dist_rl = NULL;
unsigned int *h_id_rl = NULL;

unsigned int cuentaRecT;

extern int cuentaLoc;
extern PLocalidad PLr;
extern PRecurso PRr;
extern PTipoRec PTr;

//funciones de interfaz con GPU
extern void alojaMemoriaCL_D(float* h_lon_loc, float* h_lat_loc);
extern void alojaMemoriaCR_D(float* h_lon_rec, float* h_lat_rec,
		unsigned int *h_id_rec, size_t cuentaRecT);
extern void alojaMemoriaRes(void);
extern void liberaMemoriaCL_D(void);
extern void liberaMemoriaCR_D(void);
extern void liberaMemoriaRes(void);

extern void iniciaCalculo(float *h_dist_rl, unsigned int *h_id_rl,
		const size_t cuentaRecT);


extern void insertaRes(float *h_dist_rl,unsigned int *h_id_rl,char *stipo);


int calculoSD(void);
void alojaMemoriaCopiaLoc(void);
void alojaMemoriaCopiaRec(char* stipo);
void liberaMemoriaLoc(void);
void liberaMemoriaRec(void);
int cuentaRecTipo(char *stipo);

/**
 *
 */
int calculoSD(void) {

	//aloja la memoria del host
	alojaMemoriaCopiaLoc();

	//aloja y copia la memoria al dispositivo
	alojaMemoriaCL_D(h_lon_loc, h_lat_loc);
	alojaMemoriaRes();

	// para cada tipo de recurso se ejecuta un "kernel"
	PTipoRec pt = PTr;
	while (pt != NULL ) {

		printf("Tema: %s\n",pt->stipo);

		alojaMemoriaCopiaRec(pt->stipo);
		alojaMemoriaCR_D(h_lon_rec, h_lat_rec, h_id_rec, cuentaRecT);

		//llamada a kernel
		iniciaCalculo(h_dist_rl,h_id_rl,cuentaRecT);


		//imprime resultados
		insertaRes(h_dist_rl,h_id_rl,pt->stipo);

		liberaMemoriaCR_D();
		liberaMemoriaRec();

		pt = pt->Pnext;
	}

	//liberamos memoria en el device
	liberaMemoriaRes();
	liberaMemoriaCL_D();

	//liberamos la memoria empleada host
	liberaMemoriaLoc();

	return 0;
}

/**
 * @brief Funcion que aloja la memoria necesaria para las coordenadas de las localidades, distancia e id del recurso seleccionado
 */
void alojaMemoriaCopiaLoc(void) {

	int i = 0;
	h_lon_loc = (float *) malloc(sizeof(float) * cuentaLoc);
	h_lat_loc = (float *) malloc(sizeof(float) * cuentaLoc);

	//alojamos memoria para los resultados en el host
	h_id_rl = (unsigned int*) malloc(sizeof(unsigned int) * cuentaLoc);
	h_dist_rl = (float *) malloc(sizeof(float) * cuentaLoc);

	PLocalidad ploc = PLr;

	while (ploc != NULL ) {

		*(h_lon_loc + i) = (float) ploc->lon;
		*(h_lat_loc + i) = (float) ploc->lat;

		ploc = ploc->Pnext;
		i++;
	}

}

/**
 * @brief Función que aloja la cantida de memoria necesaria para los recursos de cierto tipo
 */
void alojaMemoriaCopiaRec(char *stipo) {

	int i = 0;

	cuentaRecT = cuentaRecTipo(stipo);

	h_lon_rec = (float *) malloc(sizeof(float) * cuentaRecT);
	h_lat_rec = (float *) malloc(sizeof(float) * cuentaRecT);

	h_id_rec = (unsigned int *) malloc(sizeof(unsigned int) * cuentaRecT);

	PRecurso pr = PRr;
	while (pr != NULL ) {
		if (strcmp(pr->stipo_infra, stipo) == 0) {
			*(h_lon_rec + i) = (float) pr->lon;
			*(h_lat_rec + i) = (float) pr->lat;
			*(h_id_rec + i) =  pr->id;
			i++;
		}
		pr = pr->Pnext;
	}
}

/**
 * @brief Función que cuenta la cantidad recurso de un tipo
 */
int cuentaRecTipo(char *stipo) {

	int cuenta = 0;

	PRecurso pr = PRr;
	while (pr != NULL ) {
		if (strcmp(pr->stipo_infra, stipo) == 0) {
			cuenta++;
		}
		pr=pr->Pnext;
	}

	return cuenta;
}

/**
 * @brief Funcion que  libera la memoria asociada a las localidadess y la utilizada en los calculos asi como los resultados
 */
void liberaMemoriaLoc(void) {

	free(h_lon_loc);
	free(h_lat_loc);

	//libera memoria local de resultados
	free(h_id_rl);
	free(h_dist_rl);

}

/**
 * @brief Funcion que libera la memoria utilizada en los recursos
 */
void liberaMemoriaRec(void) {
	if(h_lon_rec!=NULL)free(h_lon_rec);
	if(h_lat_rec!=NULL)free(h_lat_rec);
	if(h_id_rec!=NULL)free(h_id_rec);
}

