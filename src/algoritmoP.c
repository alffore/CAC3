#include "cac2.h"
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


extern double RT;

/**
 * @brief Esta funcion calcula la distancia entre una localidad y un recurso
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

        for (t = 0; t < tam_tipos; t++) {

            pr = PRr;
            prmin = NULL;
            dist = M_PI*RT;
            daux=dist;
            while (pr != NULL) {
             

                if (strcmp(tipoi[t], pr->stipo_infra) == 0) {

                    daux = distLR(ploc, pr);
                    if (daux < dist) {
                        dist = daux;
                        prmin = pr;
                    }
                }
                pr = pr->Pnext;
            }


            insertaDato(ploc, prmin, dist);
        }

        ploc = ploc->Pnext;
    }

    return 1;
}
