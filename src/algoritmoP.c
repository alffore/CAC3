#include "cac3.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>


int calculoSD(void);

extern double distLR(PLocalidad ploc, PRecurso prec);
extern void insertaDato(PLocalidad ploc, PRecurso pr, double dist);


extern int cuentaLoc;
extern int cuentaRec;

extern PRecurso PRr;
extern PLocalidad PLr;
extern PTipoRec PTr;


extern double RT;

/**
 * @brief Esta función calcula la distancia entre una localidad y un recurso de un cierto tipo
 * @return 
 */
int calculoSD(void) {


    int tam_tipos = 20;

    int t;
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
                }
                pr = pr->Pnext;
            }

            insertaDato(ploc, prmin, dist);

            ptr=ptr->Pnext;

        }while(ptr!=NULL);

        ploc = ploc->Pnext;
    }

    return 1;
}
