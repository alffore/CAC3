/*
 * algoritmo.cu
 *
 *  Created on: 31/08/2014
 *      Author: AAFR <alffore@gmail.com>
 */

#include "cac3.h"
#include "utils.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <cuda.h>

//coordenadas geograficas de las localidades
float *h_lon_loc = NULL;
float *h_lat_loc = NULL;
unsigned int *h_id_loc = NULL;

//coordenadas geograficas e id de los recursos
float *h_lon_rec = NULL;
float *h_lat_rec = NULL;
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
extern void alojaMemoria_CLyRes_D(float* h_lon_loc, float* h_lat_loc,
		float * h_dist_rl, const size_t cuentaLocR);
extern void alojaMemoriaCR_D(float* h_lon_rec, float* h_lat_rec,
		unsigned int *h_id_rec, size_t cuentaRecT, float* h_dist_rl,
		const size_t cuentaLocR);

extern void liberaMemoria_CLyRes_D(void);
extern void liberaMemoriaCR_D(void);

extern void iniciaCalculo_v2(float *h_dist_rl, unsigned int *h_id_rl,
		const size_t cuentaRecT, const size_t cuentaLocR);

char nombrearchivo[] = "cac4_salida";
extern void abreArchivoSSQL(const char * snomarch);
extern void cierraArchivoSSQL(void);

extern void insertaRes(float *h_dist_rl, unsigned int *h_id_rl, char *stipo);

//rutina para chequeo de memoria
extern void memoriaGPUUso(const char * smensaje);

int calculoSD(void);

void alojaMemoriaCopiaLoc_v3(const size_t cantidad, int offset);
void alojaMemoriaCopiaRec(char* stipo);

void liberaMemoriaLoc_v3(void);
void liberaMemoriaRec(void);
int cuentaRecTipo(char *stipo);

/**
 *
 */
int calculoSD(void) {

	checkCudaErrors(cudaSetDevice(0));
	cudaDeviceReset();
	if (BDEP)
		memoriaGPUUso("memoria antes de todo");

	//inicamos loop de objetos

	int pasosLoc = cuentaLoc / MAX_LOCS;
	int resLoc = cuentaLoc % MAX_LOCS;
	int p = 0;
	size_t cuentaLocR;
	int offset = 0;

	if (resLoc == 0)
		pasosLoc--;

	if (BDEP)
		printf("pasosLoc: %d, resLoc: %d\n", pasosLoc, resLoc);
	do {

		//determinamos paso y offeset
		if (resLoc > 0) {

			if (p == pasosLoc) {
				cuentaLocR = resLoc;
			} else {
				cuentaLocR = MAX_LOCS;
			}

			offset = p * MAX_LOCS;
		} else {
			cuentaLocR = MAX_LOCS;
			offset = p * MAX_LOCS;
		}
		if (BDEP)
			printf("p: %d, cuentaLocR: %ld, offset: %d\n", p, cuentaLocR,
					offset);

		//aloja la memoria del host
		alojaMemoriaCopiaLoc_v3(cuentaLocR, offset);

		//aloja y copia la memoria al dispositivo
		alojaMemoria_CLyRes_D(h_lon_loc, h_lat_loc, h_dist_rl, cuentaLocR);

		// para cada tipo de recurso se ejecuta un "kernel"
		PTipoRec pt = PTr;

		char * snombrea;
		snombrea = (char*) malloc(sizeof(char) * 20);
		sprintf(snombrea, "%s_%d.sql", nombrearchivo, p);
		abreArchivoSSQL(snombrea);

		while (pt != NULL) {

			 alojaMemoriaCopiaRec(pt->stipo_infra);

			 if (BDEP)
			 printf("\nTema: %s (%u)\n", pt->stipo_infra, cuentaRecT);

			 alojaMemoriaCR_D(h_lon_rec, h_lat_rec, h_id_rec, cuentaRecT,
			 h_dist_rl, cuentaLocR);

			 //checamos memoria antes de ejecucion de kernel
			 //if (BDEP)memoriaGPUUso("memoria antes de kernels");

			 //llamada a kernel
			  iniciaCalculo_v2(h_dist_rl, h_id_rl, cuentaRecT, cuentaLocR);

			 //imprime resultados
			  insertaRes(h_dist_rl, h_id_rl, pt->stipo_infra);

			 liberaMemoriaCR_D();
			 liberaMemoriaRec();

			pt = pt->Pnext;
		}

		cierraArchivoSSQL();
		free(snombrea);

		if (BDEP)
			memoriaGPUUso("memoria despues de kernels");

		//liberamos memoria en el device
		liberaMemoria_CLyRes_D();

		//liberamos la memoria empleada host
		liberaMemoriaLoc_v3();

		p++;

	} while (p <= pasosLoc);

	cudaDeviceReset();
	checkCudaErrors(cudaGetLastError());
	return 0;
}

/**
 * @brief Función que aloja la memoria necesaria para las coordenadas de las localidades, distancia e id del recurso seleccionado
 *
 */

void alojaMemoriaCopiaLoc_v3(const size_t cuentaLocR, int offset) {

	cudaHostAlloc((void**) &h_lon_loc, sizeof(float) * cuentaLocR,
			cudaHostAllocDefault);
	cudaHostAlloc((void**) &h_lat_loc, sizeof(float) * cuentaLocR,
			cudaHostAllocDefault);

	/*h_lon_loc=(float *)malloc(sizeof(float) * cuentaLocR);
	 h_lat_loc=(float *)malloc(sizeof(float) * cuentaLocR);*/

	h_id_loc = (unsigned int *) malloc(sizeof(unsigned int) * cuentaLocR);

	//alojamos memoria para los resultados en el host
	h_id_rl = (unsigned int*) malloc(sizeof(unsigned int) * cuentaLocR);
	h_dist_rl = (float *) malloc(sizeof(float) * cuentaLocR);

	PLocalidad ploc = PLr;
	int i = offset;
	int j = 0;
	while (ploc != NULL && j < cuentaLocR) {

		*(h_lon_loc + i) = (float) ploc->lon;
		*(h_lat_loc + i) = (float) ploc->lat;
		*(h_id_loc + i) = ploc->id_loc;
		j++;

		ploc = ploc->Pnext;
		i++;
	}

}

/**
 * @brief Función que libera la memoria asociada a las localidades y la utilizada en los calculos asi como los resultados
 */
void liberaMemoriaLoc_v3(void) {

	cudaFreeHost(h_lon_loc);
	cudaFreeHost(h_lat_loc);
	/*free(h_lon_loc);
	 free(h_lat_loc);*/

	free(h_id_loc);

	//libera memoria local de resultados
	free(h_id_rl);
	free(h_dist_rl);

}

/**
 * @brief Función que aloja la cantidad de memoria necesaria para los recursos de cierto tipo
 */
void alojaMemoriaCopiaRec(char *stipo) {

	int i = 0;

	cuentaRecT = cuentaRecTipo(stipo);

	cudaHostAlloc((void**) &h_lon_rec, sizeof(float) * cuentaRecT,
			cudaHostAllocDefault);
	cudaHostAlloc((void**) &h_lat_rec, sizeof(float) * cuentaRecT,
			cudaHostAllocDefault);

	cudaHostAlloc((void**) &h_id_rec, sizeof(unsigned int) * cuentaRecT,
			cudaHostAllocDefault);

	/*h_lon_rec = (float *) malloc(sizeof(float) * cuentaRecT);
	 h_lat_rec = (float *) malloc(sizeof(float) * cuentaRecT);

	 h_id_rec = (unsigned int *) malloc(sizeof(unsigned int) * cuentaRecT);*/

	PRecurso pr = PRr;
	while (pr != NULL) {
		if (strcmp(pr->stipo_infra, stipo) == 0) {
			*(h_lon_rec + i) = (float) pr->lon;
			*(h_lat_rec + i) = (float) pr->lat;
			*(h_id_rec + i) = pr->id;
			i++;
		}
		pr = pr->Pnext;
	}

}

/**
 * @brief Funcion que libera la memoria utilizada en los recursos
 */
void liberaMemoriaRec(void) {

	if (h_lon_rec != NULL)
		cudaFreeHost(h_lon_rec);
	if (h_lat_rec != NULL)
		cudaFreeHost(h_lat_rec);
	if (h_id_rec != NULL)
		cudaFreeHost(h_id_rec);

	/*if (h_lon_rec != NULL)
	 free(h_lon_rec);
	 if (h_lat_rec != NULL)
	 free(h_lat_rec);
	 if (h_id_rec != NULL)
	 free(h_id_rec);*/
}

/**
 * @brief Función que cuenta la cantidad recurso de un tipo
 */
int cuentaRecTipo(char *stipo) {

	int cuenta = 0;

	PRecurso pr = PRr;
	while (pr != NULL) {
		if (strcmp(pr->stipo_infra, stipo) == 0) {
			cuenta++;
		}
		pr = pr->Pnext;
	}

	return cuenta;
}

