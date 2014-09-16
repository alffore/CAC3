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

void alojaMemoriaCL_D(float* h_lon_loc, float* h_lat_loc);
void alojaMemoriaCR_D(float* h_lon_rec, float* h_lat_rec,
		unsigned int *h_id_rec, size_t cuentaRecT);
void alojaMemoriaRes(void);
void liberaMemoriaCL_D(void);
void liberaMemoriaCR_D(void);
void liberaMemoriaRes(void);

void iniciaCalculo(float *h_dist_rl, unsigned int *h_id_rl,
		const size_t cuentaRecT);

/*__global__ void calculaDK(const float *d_lon_loc, const float *d_lat_loc,
 const float *d_lon_rec, const float *d_lat_rec,
 const unsigned int *d_id_rec, float *d_dist_rl, unsigned int *d_id_rl,
 const size_t cuentaRecT, const int cuentaLoc);*/

__global__ void calculaDK2(const float *d_lon_loc, const float *d_lat_loc,
		const float *d_lon_rec, const float *d_lat_rec,
		const unsigned int *d_id_rec, float *d_dist_rl, unsigned int *d_id_rl,
		const size_t cuentaRecT, const int cuentaLoc);

__global__ void calculaDKSM(const float *d_lon_loc, const float *d_lat_loc,
		const float *d_lon_rec, const float *d_lat_rec,
		const unsigned int *d_id_rec, float *d_dist_rl, unsigned int *d_id_rl,
		const size_t cuentaRecT, const int cuentaLoc, const size_t maxall);

__global__ void calculaDKSM2(const float *d_lon_loc, const float *d_lat_loc,
		const float *d_lon_rec, const float *d_lat_rec,
		const unsigned int *d_id_rec, float *d_dist_rl, unsigned int *d_id_rl,
		const size_t cuentaRecT, const int cuentaLoc, const size_t maxall);

__device__ float calculaDistancia(float lon0, float lat0, float lon1,
		float lat1);

/**
 *
 */
void iniciaCalculo(float *h_dist_rl, unsigned int *h_id_rl,
		const size_t cuentaRecT) {

	//const int maxThreadsPerBlock = MAX_THREADS_BLOCK;
	int threads = 64; //maxThreadsPerBlock;
	//int blocks = (cuentaLoc + threads - 1)/ threads;
	int blocks = MIN(30,(cuentaLoc+threads-1) / threads);

	int numr_sh = MIN(cuentaRecT,threads);

	if (BDEP)
		printf("Threads: %d, Blocks: %d (%d)\n", threads, blocks,
				(cuentaLoc + threads - 1) / threads);

	/*calculaDK2<<<blocks, threads>>>(d_lon_loc, d_lat_loc, d_lon_rec, d_lat_rec,
	 d_id_rec, d_dist_rl, d_id_rl, cuentaRecT, cuentaLoc);*/

	/*calculaDK<<<blocks, threads>>>(d_lon_loc, d_lat_loc, d_lon_rec, d_lat_rec,
	 d_id_rec, d_dist_rl, d_id_rl, cuentaRecT, cuentaLoc);*/

	/*calculaDKSM<<<blocks, threads, sizeof(RecM) * numr_sh>>>(d_lon_loc,
	 d_lat_loc, d_lon_rec, d_lat_rec, d_id_rec, d_dist_rl, d_id_rl,
	 cuentaRecT, cuentaLoc, numr_sh);*/

	calculaDKSM2<<<blocks, threads, sizeof(RecM) * numr_sh>>>(d_lon_loc,
			d_lat_loc, d_lon_rec, d_lat_rec, d_id_rec, d_dist_rl, d_id_rl,
			cuentaRecT, cuentaLoc, numr_sh);

	cudaDeviceSynchronize();
	checkCudaErrors(cudaGetLastError());

	//obtiene resultados
	cudaMemcpy(h_dist_rl, d_dist_rl, sizeof(float) * cuentaLoc,
			cudaMemcpyDeviceToHost);
	cudaMemcpy(h_id_rl, d_id_rl, sizeof(unsigned int) * cuentaLoc,
			cudaMemcpyDeviceToHost);
}

/**
 *
 */
void alojaMemoriaCL_D(float * h_lon_loc, float *h_lat_loc) {

	cudaMalloc((void**) &d_lon_loc, sizeof(float) * cuentaLoc);
	cudaMalloc((void**) &d_lat_loc, sizeof(float) * cuentaLoc);

	cudaMemcpy(d_lon_loc, h_lon_loc, sizeof(float) * cuentaLoc,
			cudaMemcpyHostToDevice);
	cudaMemcpy(d_lat_loc, h_lat_loc, sizeof(float) * cuentaLoc,
			cudaMemcpyHostToDevice);
}

/**
 *
 */
void alojaMemoriaRes() {
	cudaMalloc((void**) &d_dist_rl, sizeof(float) * cuentaLoc);
	cudaMalloc((void**) &d_id_rl, sizeof(unsigned int) * cuentaLoc);
}

/**
 *
 */
void alojaMemoriaCR_D(float * h_lon_rec, float *h_lat_rec,
		unsigned int *h_id_rec, size_t cuentaRecT) {

	cudaMalloc((void**) &d_lon_rec, sizeof(float) * cuentaRecT);
	cudaMalloc((void**) &d_lat_rec, sizeof(float) * cuentaRecT);
	cudaMalloc((void**) &d_id_rec, sizeof(unsigned int) * cuentaRecT);

	cudaMemcpy(d_lon_rec, h_lon_rec, sizeof(float) * cuentaRecT,
			cudaMemcpyHostToDevice);
	cudaMemcpy(d_lat_rec, h_lat_rec, sizeof(float) * cuentaRecT,
			cudaMemcpyHostToDevice);
	cudaMemcpy(d_id_rec, h_id_rec, sizeof(unsigned int) * cuentaRecT,
			cudaMemcpyHostToDevice);
}

/**
 *
 */
void liberaMemoriaCL_D(void) {
	cudaFree(d_lon_loc);
	cudaFree(d_lat_loc);
}

void liberaMemoriaCR_D(void) {
	cudaFree(d_lon_rec);
	cudaFree(d_lat_rec);
	cudaFree(d_id_rec);
}

void liberaMemoriaRes(void) {
	cudaFree(d_id_rl);
	cudaFree(d_dist_rl);

}

// Sección de Kernel del algoritmo
/**
 *
 */
/*__global__ void calculaDK(const float *d_lon_loc, const float *d_lat_loc,
 const float *d_lon_rec, const float *d_lat_rec,
 const unsigned int *d_id_rec, float *d_dist_rl, unsigned int *d_id_rl,
 const size_t cuentaRecT, const int cuentaLoc) {

 int myId = threadIdx.x + blockDim.x * blockIdx.x;

 if (myId > cuentaLoc)
 return;

 //inicialización arranque de kernel
 *(d_dist_rl + myId) = calculaDistancia(*(d_lon_loc + myId),
 *(d_lat_loc + myId), *d_lon_rec, *d_lat_rec);
 *(d_id_rl + myId) = *d_id_rec;

 for (unsigned int i = 1; i < cuentaRecT; i++) {

 float daux = calculaDistancia(*(d_lon_loc + myId), *(d_lat_loc + myId),
 *(d_lon_rec + i), *(d_lat_rec + i));

 if (daux < *(d_dist_rl + myId)) {
 *(d_dist_rl + myId) = daux;
 *(d_id_rl + myId) = *(d_id_rec + i);
 }

 }

 }
 */

/**
 * @brief Segundo kernel que recorre un loop del grid hasta
 */__global__ void calculaDK2(const float *d_lon_loc, const float *d_lat_loc,
		const float *d_lon_rec, const float *d_lat_rec,
		const unsigned int *d_id_rec, float *d_dist_rl, unsigned int *d_id_rl,
		const size_t cuentaRecT, const int cuentaLoc) {

	int myId = threadIdx.x + blockDim.x * blockIdx.x;

	while (myId < cuentaLoc) {

		//inicialización arranque de kernel
		*(d_dist_rl + myId) = calculaDistancia(*(d_lon_loc + myId),
				*(d_lat_loc + myId), *d_lon_rec, *d_lat_rec);
		*(d_id_rl + myId) = *d_id_rec;

		/*for (unsigned int i = 1; i < cuentaRecT; i++) {

		 float daux = calculaDistancia(*(d_lon_loc + myId),
		 *(d_lat_loc + myId), *(d_lon_rec + i), *(d_lat_rec + i));

		 if (daux < *(d_dist_rl + myId)) {
		 *(d_dist_rl + myId) = daux;
		 *(d_id_rl + myId) = *(d_id_rec + i);
		 }

		 }*/
		myId += blockDim.x * gridDim.x;
	}

}

/**
 *
 */

__global__ void calculaDKSM(const float *d_lon_loc, const float *d_lat_loc,
		const float *d_lon_rec, const float *d_lat_rec,
		const unsigned int *d_id_rec, float *d_dist_rl, unsigned int *d_id_rl,
		const size_t cuentaRecT, const int cuentaLoc, const size_t maxall) {

	int myId = threadIdx.x + blockDim.x * blockIdx.x;

	int min_id;
	float min_dist;
	int offset = 0;
	//float daux;

	if (myId > cuentaLoc)
		return;

	min_dist = calculaDistancia(*(d_lon_loc + myId), *(d_lat_loc + myId),
			*d_lon_rec, *d_lat_rec);
	min_id = *d_id_rec;

	extern __shared__ RecM rec[];

	while (offset < cuentaRecT) {

		if (myId < maxall) {
			rec[myId].lon = *(d_lon_rec + myId + offset);
			rec[myId].lat = *(d_lat_rec + myId + offset);
			rec[myId].id = *(d_id_rec + myId + offset);
		}
		__syncthreads();

		for (int i = 0; i < maxall; i++) {

			/*daux = calculaDistancia(*(d_lon_loc + myId), *(d_lat_loc + myId),
			 rec[i].lon, rec[i].lat);

			 if (min_dist > daux) {
			 min_dist = daux;
			 min_id = rec[i].id;
			 }*/

		}

		*(d_dist_rl + myId) = min_dist;
		*(d_id_rl + myId) = min_id;

		__syncthreads();
		offset += MIN(maxall,cuentaRecT-1-offset);
	}

}

__global__ void calculaDKSM2(const float *d_lon_loc, const float *d_lat_loc,
		const float *d_lon_rec, const float *d_lat_rec,
		const unsigned int *d_id_rec, float *d_dist_rl, unsigned int *d_id_rl,
		const size_t cuentaRecT, const int cuentaLoc, const size_t maxall) {

	int myId = threadIdx.x + blockDim.x * blockIdx.x;

	int min_id;
	float min_dist;

	float daux;

	if (myId > cuentaLoc)
		return;

	min_dist = calculaDistancia(*(d_lon_loc + myId), *(d_lat_loc + myId),
			*d_lon_rec, *d_lat_rec);
	min_id = *d_id_rec;

	extern __shared__ RecM rec[];

	if (myId < maxall) {
		rec[myId].lon = *(d_lon_rec + myId);
		rec[myId].lat = *(d_lat_rec + myId);
		rec[myId].id = *(d_id_rec + myId);
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

		//if (min_dist < *(d_dist_rl + myId)) {
			*(d_dist_rl + myId) = min_dist;
			*(d_id_rl + myId) = min_id;
		//}

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
