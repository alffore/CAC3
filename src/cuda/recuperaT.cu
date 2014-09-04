/**
* @file recuperaT.c
*
* @author AAFR <alffore@gmail.com>
*/

#include "cac3.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void liberaT(PTipoRec pr);
int recuperaT(void);
PTipoRec insertaT(char * stipo);
PTipoRec creaT(char * stipo);

extern PRecurso PRr;

PTipoRec PTr=NULL;
int cuentaT;


/**
 * @brief Función que recorre los recursos y recupera los distintos tipos
 *
 */
int recuperaT(void){
	cuentaT=0;

	PRecurso prc=PRr;

	do{

		insertaT(prc->stipo_infra);

		prc=prc->Pnext;

	}while(prc!=NULL);

	printf("cuentaT: %d\n", cuentaT);
	return cuentaT;
}


/**
 *
 */
PTipoRec insertaT(char* stipo){

	int cuenta=0;
	PTipoRec ptr=PTr;
	PTipoRec ptra=PTr;

	if(PTr==NULL){
		PTr=creaT(stipo);
		return PTr;
	}

	while(ptr!=NULL){

		if(strcmp(ptr->stipo,stipo)==0){
			//ptr->cuenta++;
			cuenta++;
		}

		ptra=ptr;
		ptr=ptr->Pnext;
	}

	if(cuenta==0){
		ptra->Pnext=creaT(stipo);
	}

	return ptra->Pnext;

}


/**
 *
 */
PTipoRec creaT(char* stipo){

	PTipoRec pr=(PTipoRec)malloc(sizeof(PTipoRec));

	pr->stipo=stipo;
	//pr->cuenta=1;
	pr->Pnext=NULL;

	cuentaT++;
	return pr;
}


/**
 * @brief Función que libera la memoria
 *
 */
void liberaT(PTipoRec pr) {

    if (pr != NULL) {
        liberaT(pr->Pnext);
        cuentaT--;
        free(pr);
    }

}
