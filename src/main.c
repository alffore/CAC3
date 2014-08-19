/* 
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
extern void abreArchivoSSQL(char * snomarch);
extern void cierraArchivoSSQL(void);
extern int calculoSD(void);

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
/*    int i = 0;*/

    if (argc > 2) {

        
        printf("%s\n",*(argv + 1));
        recuperaInfoLoc(*(argv + 1));
        
        printf("%s\n",*(argv + 2));
        recuperaInfoRC(*(argv + 2));
        recuperaT();
        
        
        abreArchivoSSQL("salida_cac3.sql");
        calculoSD();
        cierraArchivoSSQL();

                
        liberaL(PLr);
        liberaT(PTr);
        liberaR(PRr);
        
      
    } else {
        fprintf(stderr, "CAC3.exe  <archivo_localidades> <archivo_recursos>\n");
    }




    return (EXIT_SUCCESS);
}

