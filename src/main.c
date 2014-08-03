/* 
 * @file  main.c
 * @author AAFR
 *
 * Created on November 19, 2012, 1:36 PM
 */

#include "cac2.h"
#include <stdio.h>
#include <stdlib.h>


extern int recuperaInfoRC(char * sarchivo);
extern int recuperaInfoLoc(char * sarchivo);
extern void abreArchivoSSQL(char * snomarch);
extern void cierraArchivoSSQL(void);
extern int calculoSD(void);

extern void liberaR(PRecurso pr);
extern void liberaL(PLocalidad pr);


extern PRecurso PRr;
extern PLocalidad PLr;




/**
 * @brief 
 * 
 */
int main(int argc, char** argv) {
/*    int i = 0;*/

    if (argc > 2) {
/*
        for (i = 0; i < argc; i++) {
            printf("%ṣ\n", *(argv + i));
        }
*/


        
        printf("%s\n",*(argv + 1));
        recuperaInfoLoc(*(argv + 1));
        
        printf("%s\n",*(argv + 2));
        recuperaInfoRC(*(argv + 2));
        
        
        abreArchivoSSQL("salida_cac2.sql");
        calculoSD();
        cierraArchivoSSQL();

        
        
        liberaL(PLr);
        liberaR(PRr);

      
    } else {
        fprintf(stderr, "cac2  <archivo_localidades> <archivo_recursos>\n");
    }




    return (EXIT_SUCCESS);
}

