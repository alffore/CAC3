/* 
 * @file  cac2.h
 * @author AAFR
 *
 * Created on November 19, 2012, 1:39 PM
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
     * 
     */
    static char *tipoi[20] = {
        "museo",
        "teatro",
        "auditorio",
        "galeria",
        "libreria",
        "zona_arqueologica",
        "biblioteca",
        "centro_cultural",
        "otra_bib",
        "fototeca",
        "fonoteca",
        "patrimonio_humanidad",
        "fnme",
        "universidad",
        "museo_his"
        , "museo_ant"
        , "museo_art"
        , "museo_arq"
        , "museo_cyt"
        , "museo_esp"
    };
    
    /**
    * @brief Estructura para registrar de manera dinamica los tipos de recursos 
    */
    typedef struct TipoRec {
        char * stipo;
        struct TipoRec * Pnext;
    } TipoRec;

    typedef TipoRec * PTipoRec;
   

#ifdef	__cplusplus
}
#endif

#endif	/* CAC3_H */

