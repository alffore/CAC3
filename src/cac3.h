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

    /**
     * @brief Estructura que registra un recuro y sus caracteristicas
     */
    typedef struct Recurso {
        char * stipo_infra;
        int id;
        double lon;
        double lat;

        int estado_id;
        int municipio_id;
        int localidad_id;

        struct Recurso* Pnext;

    } Recurso;


    typedef Recurso * PRecurso;

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

    } Localidad;

    typedef Localidad * PLocalidad;

    
    /**
    * @brief Estructura para registrar de manera dinamica los tipos de recursos 
    */
    typedef struct TipoRec {
        char * stipo;
        
        struct TipoRec * Pnext;
    } TipoRec;

    typedef TipoRec * PTipoRec;
   

#define SALIDA_ARCHIVO "a"

#define SALIDA_BD "b"


#ifdef	__cplusplus
}
#endif

#endif	/* CAC3_H */

