/*
 * @file  cac3.h
 * @author AAFR <alffore@gmail.com>
 *
 * Created on November 19, 2012, 1:39 PM
 * Actualizado en Agosto 20, 2014 8:28 AM
 */

#ifndef CAC3_H
#define	CAC3_H

#ifdef	__cplusplus
extern "C" {
#endif

#define MAX_THREADS_BLOCK 512
#define THREADS 128 //64
#define BLOCKS 1 //30
#define MAX_PREC 300 //500
#define MAX_LOCS 100
#define BDEP true
#define MIN(X,Y) ((X) < (Y) ? (X) : (Y))

/**
 * @brief Estructura que registra un recuro y sus caracteristicas
 */
typedef struct Recurso {
	char * stipo_infra;
	unsigned int id;
	double lon;
	double lat;

	int estado_id;
	int municipio_id;
	int localidad_id;

	struct Recurso* Pnext;

} Recurso;

typedef Recurso* PRecurso;

/**
 * @brief Estructura par registrar las localidades
 */
typedef struct Localidad {
	int estado_id;
	int municipio_id;
	int localidad_id;

	int poblacion;

	double lat;
	double lon;

	struct Localidad * Pnext;

	unsigned int id_loc;

} Localidad;

typedef Localidad* PLocalidad;

/**
 * @brief Estructura para registrar de manera dinamica los tipos de recursos
 */
typedef struct TipoRec {
	char * stipo_infra;
	//unsigned int cuenta;

	struct TipoRec * Pnext;
} TipoRec;

typedef TipoRec* PTipoRec;

/**
 * @brief Estructura para el Share Memory en el kernel de calculo
 */
typedef struct RecM{
	unsigned int id;
	float lat;
	float lon;
}RecM;

typedef RecM* PRecM;


#ifdef	__cplusplus
}
#endif

#endif	/* CAC3_H */

