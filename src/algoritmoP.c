#include "cac3.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

/**
* @brief Función que realiza la conjunción de la localidad con el tipo de recurso más cercano
*/
int calculoSD(char *saltipo);

extern double distLR(PLocalidad ploc, PRecurso prec);
extern void insertaDato(PLocalidad ploc, PRecurso pr, double dist);
extern int insertaDatoDB(PLocalidad ploc, PRecurso pr, double dist);
extern void insertaDatoMin(PLocalidad ploc, PRecurso pr, double dist);


extern int cuentaLoc;
extern int cuentaRec;

extern PRecurso PRr;
extern PLocalidad PLr;
extern PTipoRec PTr;


extern double RT;

/**
*
*/
int calculoSD(char *saltipo) {



    PRecurso pr = PRr;
    PRecurso prmin = NULL;

    PLocalidad ploc = PLr;
    double dist, daux;

    while (ploc != NULL) {

        PTipoRec ptr=PTr;       

        do{

            pr = PRr;
            prmin = NULL;
            dist = M_PI*RT;
            daux=dist;
            while (pr != NULL) {
             
                if (strcmp(ptr->stipo, pr->stipo_infra) == 0) {
                                        
                    daux = distLR(ploc, pr);
                    if (daux < dist) {
                        dist = daux;
                        prmin = pr;
                    }
                    printf("Tipo: %s\n Localidad: $i %i %i ::: Recurso: %i ::: Distancia: %f ::: D. min:dist\n",ptr->stipo,
                        ploc->estado_id, ploc->municipio_id,ploc->localidad_id,pr->id,daux,dist);
                }
                pr = pr->Pnext;
            }

    		if(strcmp(saltipo,SALIDA_ARCHIVO)==0){
                	insertaDato(ploc, prmin, dist);
    	    }else if(strcmp(saltipo,SALIDA_BD)==0){
    			    insertaDatoDB(ploc, prmin, dist);
    		}else if(strcmp(saltipo,SALIDA_MIN)==0){
    			    insertaDatoMin(ploc, prmin, dist);
    		}

            ptr=ptr->Pnext;

        }while(ptr!=NULL);

        ploc = ploc->Pnext;
    }

    return 1;
}
