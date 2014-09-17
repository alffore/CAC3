/*
 * algoritmo_cuda.cu
 *
 *  Created on: 31/08/2014
 *      Author: alfonso
 */

#include "cac3.h"
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include "utils.h"

// Alojamiento de punteros en el dispositivo

//coordenadas geograficas de las localidades
float *d_lon_loc = NULL;
float *d_lat_loc = NULL;

//coordenadas geograficas de los recursos
float *d_lon_rec = NULL;
float *d_lat_rec = NULL;

//id de los recursos
unsigned int *d_id_rec = NULL;

//resultados del calculo
float *d_dist_rl = NULL;
unsigned int *d_id_rl = NULL;

//cantidad de Localidades
extern int cuentaLoc;

void alojaMemoriaCLyRes_D(float* h_lon_loc, float* h_lat_loc,
		float * h_dist_rl);
void alojaMemoriaCR_D(float* h_lon_rec, float* h_lat_rec,
		unsigned int *h_id_rec, size_t cuentaRecT, float* h_dist_rl);

void liberaMemoriaCLyRes_D(void);
void liberaMemoriaCR_D(void);

void iniciaCalculo_v2(float *h_dist_rl, unsigned int *h_id_rl,
		const size_t cuentaRecT);

__global__ void calculaDKSM(const float *d_lon_loc, const float *d_lat_loc,
		const float *d_lon_rec, const float *d_lat_rec,
		const unsigned int *d_id_rec, float *d_dist_rl, unsigned int *d_id_rl,
		const int cuentaLoc, const size_t maxall, const size_t offset);

__device__ float calculaDistancia(float lon0, float lat0, float lon1,
		float lat1);

/**
 *
 */

void iniciaCalculo_v2(float *h_dist_rl, unsigned int *h_id_rl,
		const size_t cuentaRecT) {

	int threads = THREADS;
	int blocks = MIN(BLOCKS,(cuentaLoc+threads-1) / threads);

	int numr_sh = MIN(cuentaRecT,MAX_PREC);

	int mod = cuentaRecT / numr_sh;
	int res = cuentaRecT % numr_sh;
	int m;

	if (BDEP)
		printf(
				"Threads: %d, Blocks: %d (%d), SM(PRECs): %d, MOD: %d, RES: %d\n",
				threads, blocks, (cuentaLoc + threads - 1) / threads, numr_sh,
				mod, res);

	for (m = 0; m < mod; m++) {

		if (BDEP)
			printf("Paso: %d, offset: %d\n", m, m * numr_sh);

		calculaDKSM<<<blocks, threads, sizeof(RecM) * numr_sh>>>(d_lon_loc,
				d_lat_loc, d_lon_rec, d_lat_rec, d_id_rec, d_dist_rl, d_id_rl,
				 cuentaLoc, numr_sh, m * numr_sh);

		cudaDeviceSynchronize();
		checkCudaErrors(cudaGetLastError());

	}

	if (res > 0) {
		if (BDEP)
			printf("Paso residuo por %d\n", res);

		calculaDKSM<<<blocks, threads, sizeof(RecM) * res>>>(d_lon_loc,
				d_lat_loc, d_lon_rec, d_lat_rec, d_id_rec, d_dist_rl, d_id_rl,
				 cuentaLoc, res, (m + 1) * numr_sh);

		cudaDeviceSynchronize();
		checkCudaErrors(cudaGetLastError());
	}

	//obtiene resultados
	cudaMemcpy(h_dist_rl, d_dist_rl, sizeof(float) * cuentaLoc,
			cudaMemcpyDeviceToHost);
	cudaMemcpy(h_id_rl, d_id_rl, sizeof(unsigned int) * cuentaLoc,
			cudaMemcpyDeviceToHost);
}

/**
 *
 */
void alojaMemoriaCLyRes_D(float * h_lon_loc, float *h_lat_loc,
		float *h_dist_rl) {

	//coordenadas de Localidades
	cudaMalloc((void**) &d_lon_loc, sizeof(float) * cuentaLoc);
	cudaMalloc((void**) &d_lat_loc, sizeof(float) * cuentaLoc);

	//resultados
	cudaMalloc((void**) &d_dist_rl, sizeof(float) * cuentaLoc);
	cudaMalloc((void**) &d_id_rl, sizeof(unsigned int) * cuentaLoc);

	//copia de informacion de localidades
	cudaMemcpy(d_lon_loc, h_lon_loc, sizeof(float) * cuentaLoc,
			cudaMemcpyHostToDevice);
	cudaMemcpy(d_lat_loc, h_lat_loc, sizeof(float) * cuentaLoc,
			cudaMemcpyHostToDevice);

}

/**
 *
 */
void alojaMemoriaCR_D(float * h_lon_rec, float *h_lat_rec,
		unsigned int *h_id_rec, size_t cuentaRecT, float* h_dist_rl) {

	cudaMalloc((void**) &d_lon_rec, sizeof(float) * cuentaRecT);
	cudaMalloc((void**) &d_lat_rec, sizeof(float) * cuentaRecT);
	cudaMalloc((void**) &d_id_rec, sizeof(unsigned int) * cuentaRecT);

	cudaMemcpy(d_lon_rec, h_lon_rec, sizeof(float) * cuentaRecT,
			cudaMemcpyHostToDevice);
	cudaMemcpy(d_lat_rec, h_lat_rec, sizeof(float) * cuentaRecT,
			cudaMemcpyHostToDevice);
	cudaMemcpy(d_id_rec, h_id_rec, sizeof(unsigned int) * cuentaRecT,
			cudaMemcpyHostToDevice);

	//incializa las distancias para fijar una lacance maximo a minimizar
	for (int j = 0; j < cuentaLoc; j++) {
		*(h_dist_rl + j) = 100.0f;
	}

	//copia de informacion de distancias
	cudaMemcpy(d_dist_rl, h_dist_rl, sizeof(float) * cuentaLoc,
			cudaMemcpyHostToDevice);
}

/**
 *
 */
void liberaMemoriaCLyRes_D(void) {
	cudaFree(d_lon_loc);
	cudaFree(d_lat_loc);

	cudaFree(d_id_rl);
	cudaFree(d_dist_rl);
}

/**
 *
 */
void liberaMemoriaCR_D(void) {
	cudaFree(d_lon_rec);
	cudaFree(d_lat_rec);
	cudaFree(d_id_rec);
}

// Sección de Kernel del algoritmo
/**
 *
 */

__global__ void calculaDKSM(const float *d_lon_loc, const float *d_lat_loc,
		const float *d_lon_rec, const float *d_lat_rec,
		const unsigned int *d_id_rec, float *d_dist_rl, unsigned int *d_id_rl,
		const int cuentaLoc, const size_t maxall, const size_t offset) {

	int myId = threadIdx.x + blockDim.x * blockIdx.x;

	if (myId > cuentaLoc)
		return;

	int min_id;
	float min_dist = *(d_dist_rl + myId);

	float daux;

	extern __shared__ RecM rec[];

	if (myId < maxall) {
		rec[myId].lon = *(d_lon_rec + myId + offset);
		rec[myId].lat = *(d_lat_rec + myId + offset);
		rec[myId].id = *(d_id_rec + myId + offset);
	}

	__syncthreads();

	while (myId < cuentaLoc) {
		for (int i = 0; i < maxall; i++) {

			daux = calculaDistancia(*(d_lon_loc + myId), *(d_lat_loc + myId),
					rec[i].lon, rec[i].lat);

			if (min_dist > daux) {
				min_dist = daux;
				min_id = rec[i].id;
			}

		}

		*(d_dist_rl + myId) = min_dist;
		*(d_id_rl + myId) = min_id;

		myId += blockDim.x * gridDim.x;
	}

}

/**
 *
 */__device__ float calculaDistancia(float lon0, float lat0, float lon1,
		float lat1) {

	return acosf(
			sinf(lat0) * sinf(lat1)
					+ cosf(lat0) * cosf(lon0) * cosf(lat1) * cosf(lon1)
					+ cosf(lat0) * sinf(lon0) * cosf(lat1) * sinf(lon1));

}
