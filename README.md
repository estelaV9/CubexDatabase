# CubexDatabase 🔷
Base de datos de una aplicacion sobre cubos de Rubik. Con su modelo e/r, base de datos y consultas.

## Proyecto de Base de Datos - Primer Trimestre 📊
### Introducción
Este proyecto de base de datos fue desarrollado como parte del primer trimestre del curso de DAM. El objetivo principal de mi proyecto fue diseñar y desarrollar una base de datos relacional basada en un modelo entidad-relación (ER) sobre una aplicación de cubos de Rubik.

### Modelo Entidad-Relación (ER)
Aquí puedes encontrar el diagrama del modelo entidad-relación del proyecto :

![Modelo Entidad-Relación](https://github.com/estelaV9/CubexDatabase/blob/master/modeloER_CubeX.png)

## Proyecto de Base de Datos - Segundo Trimestre 🗃️
### Introducción
Este proyecto de base de datos es el paso a tablas del modelo entidad-relación del primer trimestre.

### Base de Datos
La [Base de datos](https://github.com/estelaV9/CubexDatabase/blob/master/DF_deVega_Estela.sql) consta de varias tablas que representan las entidades y relaciones definidas en el modelo ER. 

### Consultas
He desarrollado varias [consultas SQL](https://github.com/estelaV9/CubexDatabase/blob/master/PP_consultas_deVega_Estela.sql) para el proyecto. Como por ejemplo:

1. CONSULTA 1: SELECCIONAR EL GANADOR DEL CAMPEONATO 122 DE LA CATEGORIA 3X3X3.
PARA DETERMINAR UN GANADOR, SE EVALUARA LA MEDIA DE TIEMPOS, SIENDO EL PARTICIPANTE
CON LA MEDIA MAS BAJA EL GANADOR DE DICHO CAMPEONATO.

   ```sql
   SELECT NAME_USER AS GANADOR_CAMPEONATO FROM CUBE_USERS
   WHERE ID_USER = (
       -- 4º POR ULTIMO SELECCIONAR     EL ID_USER QUE HA OBTENIDO LA MEDIA MAS BAJA, 
       -- LO QUE IMPLICA QUE HA GANADO EL CAMPEONATO
       SELECT DISTINCT ID_USER
       FROM SCRAMBLE
       WHERE ID_AVERAGE = (
           -- 3º SELECCIONAR EL ID_AVERAGE QUE TIENE LA MENOR MEDIA DE TIEMPO
           SELECT DISTINCT ID_AVERAGE
           FROM AVERAGE
           WHERE AVG_MINUTES * 60 + AVG_SECONDS = (
               -- 2º SELECIONAR LA MENOR MEDIA ENTRE LOS ID_AVERAGE UTILIZADOS EN EL
               -- CAMPEONATO Y EN LA CATEGORIA ESPECIFICA
               SELECT MIN(AVG_MINUTES * 60 + AVG_SECONDS)
               FROM AVERAGE
               WHERE ID_AVERAGE IN (
                   -- 1º SELECCIONAR LOS ID DE MEDIA QUE SE HAN UTILIZADO EN 
                   -- LA COMPETICION Y LA CATEGORIA ESPECIFICADA EN EL ENUNCIADO 
                   SELECT DISTINCT ID_AVERAGE
                   FROM SCRAMBLE
                   WHERE ID_TYPE = (SELECT ID_TYPE FROM CUBE_TYPE WHERE NAME_TYPE LIKE '3x3x3')
                   AND ID_CHAMP = 121
               )
           )
       )
   ); 


## Licencia 📜
Este proyecto está bajo la [Licencia MIT](https://github.com/estelaV9/CubexDatabase/blob/master/license.txt).


