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
extern void alojaMemoriaCLyRes_D(float* h_lon_loc, float* h_lat_loc,float* h_dist_rl);
extern void alojaMemoriaCR_D(float* h_lon_rec, float* h_lat_rec,
		unsigned int *h_id_rec, size_t cuentaRecT,float* h_dist_rl);

extern void liberaMemoriaCLyRes_D(void);
extern void liberaMemoriaCR_D(void);


//funcion para checar lo correcto de la asignacion
//extern PRecurso obtenPRecurso(unsigned int id, char* stipo);


extern void iniciaCalculo_v2(float *h_dist_rl, unsigned int *h_id_rl,
		const size_t cuentaRecT);

char nombrearchivo[] = "cac4_salida.sql";
extern void abreArchivoSSQL(char * snomarch);
extern void cierraArchivoSSQL(void);

extern void insertaRes(float *h_dist_rl, unsigned int *h_id_rl, char *stipo);

//rutina para chequeo de memoria
extern void memoriaGPUUso(const char * smensaje);

int calculoSD(void);

void alojaMemoriaCopiaLoc_v2(void);
void alojaMemoriaCopiaRec(char* stipo);

void liberaMemoriaLoc_v2(void);
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

	//aloja la memoria del host
	alojaMemoriaCopiaLoc_v2();

	//aloja y copia la memoria al dispositivo
	alojaMemoriaCLyRes_D(h_lon_loc, h_lat_loc,h_dist_rl);


	if (BDEP)
		printf("tam PrecM: %ld\n", sizeof(RecM));

	// para cada tipo de recurso se ejecuta un "kernel"
	PTipoRec pt = PTr;

	abreArchivoSSQL(nombrearchivo);
	while (pt != NULL) {
//if(strcmp(pt->stipo_infra,"museo_art")==0){
		alojaMemoriaCopiaRec(pt->stipo_infra);

		if (BDEP)
			printf("\nTema: %s (%u)\n", pt->stipo_infra, cuentaRecT);

		alojaMemoriaCR_D(h_lon_rec, h_lat_rec, h_id_rec, cuentaRecT,h_dist_rl);

		//checamos memoria antes de ejecucion de kernel
		//if (BDEP)memoriaGPUUso("memoria antes de kernels");

		//llamada a kernel
		iniciaCalculo_v2(h_dist_rl, h_id_rl, cuentaRecT);

		//imprime resultados
		insertaRes(h_dist_rl, h_id_rl, pt->stipo_infra);

		liberaMemoriaCR_D();
		liberaMemoriaRec();
//}
		pt = pt->Pnext;
	}
	cierraArchivoSSQL();

	if (BDEP)
		memoriaGPUUso("memoria despues de kernels");

	//liberamos memoria en el device
	liberaMemoriaCLyRes_D();

	//liberamos la memoria empleada host
	liberaMemoriaLoc_v2();

	cudaDeviceReset();
	return 0;
}

/**
 * @brief Función que aloja la memoria necesaria para las coordenadas de las localidades, distancia e id del recurso seleccionado
 *
 */

void alojaMemoriaCopiaLoc_v2(void) {

	int i = 0;

	cudaHostAlloc((void**) &h_lon_loc, sizeof(float) * cuentaLoc,
			cudaHostAllocDefault);
	cudaHostAlloc((void**) &h_lat_loc, sizeof(float) * cuentaLoc,
			cudaHostAllocDefault);

	h_id_loc = (unsigned int *) malloc(sizeof(unsigned int) * cuentaLoc);

	//alojamos memoria para los resultados en el host
	h_id_rl = (unsigned int*) malloc(sizeof(unsigned int) * cuentaLoc);
	h_dist_rl = (float *) malloc(sizeof(float) * cuentaLoc);



	PLocalidad ploc = PLr;

	while (ploc != NULL) {

		*(h_lon_loc + i) = (float) ploc->lon;
		*(h_lat_loc + i) = (float) ploc->lat;
		*(h_id_loc + i) = ploc->id_loc;
		ploc = ploc->Pnext;
		i++;
	}

}

/**
 * @brief Función que aloja la cantidad de memoria necesaria para los recursos de cierto tipo
 */
void alojaMemoriaCopiaRec(char *stipo) {

	int i = 0;

	cuentaRecT = cuentaRecTipo(stipo);

	h_lon_rec = (float *) malloc(sizeof(float) * cuentaRecT);
	h_lat_rec = (float *) malloc(sizeof(float) * cuentaRecT);

	h_id_rec = (unsigned int *) malloc(sizeof(unsigned int) * cuentaRecT);

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

	//rutina checa
	/*int jc=cuentaRecT/2;

	PRecurso pc= obtenPRecurso(*(h_id_rec + jc),stipo);

	if(*(h_lon_rec + jc)!=(float)pc->lon || *(h_lat_rec + jc)!=(float)pc->lat ){
		fprintf(stderr,"Error en copia recursos HOST [cuenta: %d,jc: %d,i max:%d, rec rec:%s, id rec: %d, id sol:%d]\n",cuentaRecT,jc,i,pc->stipo_infra,pc->id,*(h_id_rec + jc));
	}*/

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

/**
 * @brief Función que libera la memoria asociada a las localidadess y la utilizada en los calculos asi como los resultados
 */

void liberaMemoriaLoc_v2(void) {

	cudaFreeHost(h_lon_loc);
	cudaFreeHost(h_lat_loc);

	free(h_id_loc);

	//libera memoria local de resultados
	free(h_id_rl);
	free(h_dist_rl);

}

/**
 * @brief Funcion que libera la memoria utilizada en los recursos
 */
void liberaMemoriaRec(void) {
	if (h_lon_rec != NULL)
		free(h_lon_rec);
	if (h_lat_rec != NULL)
		free(h_lat_rec);
	if (h_id_rec != NULL)
		free(h_id_rec);
}

