/**
 * @file  main.c
 * @author AAFR <alffore@gmail.com>
 *
 * Created on November 19, 2012, 1:36 PM
 */

#include "cac3.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


extern int recuperaInfoRC(char * sarchivo);
extern int recuperaT(void);
extern int recuperaInfoLoc(char * sarchivo);



extern void abreArchivoSSQL(char * snomarch);
extern void cierraArchivoSSQL(void);

extern int abreConexion(void);
extern int cierraConexion(void);

extern int calculoSD(char *saltipo);

extern void liberaR(PRecurso pr);
extern void liberaL(PLocalidad pr);
extern void liberaT(PTipoRec pr);


extern PRecurso PRr;
extern PLocalidad PLr;
extern PTipoRec PTr;



/**
 * @brief 
 * 
 */
int main(int argc, char** argv) {


    if (argc > 3) {

        
        printf("%s\n",*(argv + 1));
        recuperaInfoLoc(*(argv + 1));
        
        printf("%s\n",*(argv + 2));
        recuperaInfoRC(*(argv + 2));
        recuperaT();
        
        if(strcmp(*(argv + 3),SALIDA_ARCHIVO)==0){
        	abreArchivoSSQL("salida_cac5.sql");
        	calculoSD(SALIDA_ARCHIVO);
        	cierraArchivoSSQL();
	    }
	
	    if(strcmp(*(argv + 3),SALIDA_BD)==0){
	          abreConexion();
		      calculoSD(SALIDA_BD);
		      cierraConexion();
	    }

        if(strcmp(*(argv + 3),SALIDA_MIN)==0){
              abreArchivoSSQL("salida_min.txt");
		      calculoSD(SALIDA_MIN);
		      cierraArchivoSSQL();
        }

        liberaL(PLr);
        liberaT(PTr);
        liberaR(PRr);
        
      
    } else {
        fprintf(stderr, "CAC3.exe  <archivo_localidades> <archivo_recursos> <archivo=a>|<BD=b>|<minima=m>\n");
    }


    return (EXIT_SUCCESS);
}

