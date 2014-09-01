/**
 * @file  main.c
 * @author AAFR
 *
 * Created on November 19, 2012, 1:36 PM
 */
#include "cac3.h"
#include <stdio.h>
#include <stdlib.h>


extern int recuperaInfoRC(char * sarchivo);
extern int recuperaT(void);
extern int recuperaInfoLoc(char * sarchivo);


extern void liberaR(PRecurso pr);
extern void liberaL(PLocalidad pr);
extern void liberaT(PTipoRec pr);

extern int calculoSD(void);

extern PRecurso PRr;
extern PLocalidad PLr;
extern PTipoRec PTr;



int main(int argc, char **argv){
	if (argc > 2) {


	        printf("%s\n",*(argv + 1));
	        recuperaInfoLoc(*(argv + 1));

	        printf("%s\n",*(argv + 2));
	        recuperaInfoRC(*(argv + 2));

	        recuperaT();


	        //realiza el calculo
	        calculoSD();



	        liberaL(PLr);
	        liberaT(PTr);
	        liberaR(PRr);


	    } else {
	        fprintf(stderr, "CAC3.exe  <archivo_localidades> <archivo_recursos>\n");
	    }


	    return (EXIT_SUCCESS);
}
