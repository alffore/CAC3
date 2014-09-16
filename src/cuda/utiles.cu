/*
 * utiles.cu
 *
 *  Created on: 07/09/2014
 *      Author: alfonso
 */

#include <stdio.h>
#include <stdlib.h>

#include <cuda.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>

void memoriaGPUUso(const char * smensaje);

/**
 *
 *
 * @see https://devtalk.nvidia.com/default/topic/487541/best-way-to-report-memory-consumption-in-cuda-/
 */
void memoriaGPUUso(const char * smensaje) {
	// show memory usage of GPU

	cudaError_t cuda_status;
	size_t free_byte;

	size_t total_byte;

	cuda_status = cudaMemGetInfo(&free_byte, &total_byte);

	if (cudaSuccess != cuda_status) {

		printf("Error: cudaMemGetInfo fails, %s \n",
				cudaGetErrorString(cuda_status));

		//exit(1);

	}

	double free_db = (double) free_byte;

	double total_db = (double) total_byte;

	double used_db = total_db - free_db;

	printf("%s ::: GPU memory usage: used = %f, free = %f MB, total = %f MB\n",smensaje,
			used_db / 1024.0 / 1024.0, free_db / 1024.0 / 1024.0,
			total_db / 1024.0 / 1024.0);
}
