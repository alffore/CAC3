#include <libpq-fe.h>
#include "cac3.h"


const char scc[]="hostaddr=127.0.0.1 port=5432 dbname=nuevadbrenic user=userrenic";

PGconn *conn=NULL;
PGresult *res=NULL;


int abreConexion(void);
int cierraConexion(void);
int insertaQuery(char * squery);
int insertaDatoDB(PLocalidad ploc, PRecurso pr, double dist);

/**
 * 
 * @param ploc
 * @param pr
 * @param dist
 * @param stipo
 */
int insertaDatoDB(PLocalidad ploc, PRecurso pr, double dist) {

    if (pr == NULL)return 1;

	char squery[1000];

        sprintf(squery, "INSERT INTO cac4 (estado_id,municipio_id,localidad_id,recurso,pobtot,dist,estadod_id,municipiod_id,localidadd_id,recurso_id) VALUES (%d,%d,%d,'%s',%d,%7.5lf,%d,%d,%d,%d);\n"
		    , ploc->estado_id, ploc->municipio_id, ploc->localidad_id,pr->stipo_infra, ploc->poblacion, dist, pr->estado_id, pr->municipio_id, pr->localidad_id, pr->id);

	return insertaQuery(squery);

}


/**
 *
 *
 *
 */
int insertaQuery(char* squery){


	res=PQsendQuery(conn,squery);

	if(PQresultStatus(res)!= PGRES_COMMAND_OK){
		fprintf(stderr,"Error en la insercion del Query: %s\n", PQresultErrorMessage(res));
		PQclear(res);
	return 1;		
	}

	PQclear(res);

	return 0;
}

/**
 * @breif Funcion que abre una conexion a la BD
 *
 *
 */
int abreConexion(void){

	conn=PQconnectdb(scc);

	if(PQstatus(conn)!= CONNECTION_OK){
		fprintf(stderr,"Conexion a BD fallo: %s\n",PQerrorMessage(conn));
		cierraConexion();
		return 1;
	}

	PQsetnonblocking(conn, 1);


	return 0;
}


/**
 *
 * 
 */
int cierraConexion(void){

	if(conn!=NULL){
		PQflush(conn);
		PQfinish(conn);
	}


	return 0;
}
