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

1. CONSULTA 1: OBTENER EL NOMBRE Y CALCULAR MANUALMENTE EL PROMEDIO DE TIEMPOS 
DEL USUARIO ASOCIADO AL ID_AVERAGE 3. USAR DE LA TABLA AVERAGE : EL ID
Y EL NUMERO DE TIEMPOS DE ESA MEDIA.
LA MEDIA DE LOS CUBOS SE CALCULA SUMANDO TODOS LOS TIEMPOS, RESTANDO EL MENOR Y
MAYOR TIEMPO Y DIVIENDOLO ENTRE EL NUMERO TOTAL DE TIEMPOS MENOS EL MAYOR Y MENOR..
<br>
   ```sql
   SELECT 
    -- SELECCIONAR EL NOMBRE ASOCIADO AL ID_AVERAGE 3
    (SELECT NAME_USER FROM CUBE_USERS 
    WHERE ID_USER = (SELECT DISTINCT ID_USER FROM SCRAMBLE 
                    WHERE ID_AVERAGE = 3)) AS NOMBRE,
    -- CALCULAR EL PROMEDIO MINUTOS
    CASE 
        -- SI HAY MAS DE UNA ANOTACION DNF, EL PROMEDIO SE ESTABLECE EN 0
        WHEN (SELECT COUNT(ID_SCRAMBLE) FROM SCRAMBLE 
              WHERE ID_AVERAGE =  3
              AND COMMENTS1 LIKE 'DNF') > 1 THEN 0
        ELSE    
        -- SI NO, SE SUMA TODOS LOS TIEMPOS, QUITANDO EL MAYOR Y MENOR TIEMPO,
        -- DIVIDIENDOLO ENTRE LOS TIEMPOS QUE HA HECHO MENOS 2 (EL MAYOR Y MENOR)
        -- Y DIVIDIENDO TODO ESO PARA OBTENER SOLO LOS MINUTOS
            TRUNC((SUM(TIEMPO) - MIN(TIEMPO) - MAX(TIEMPO)) 
                / (A.PERIOD_AVG - 2) / 60) 
    END AS AVG_MINUTOS,
    
    -- CALCULAR EL PROMEDIO DE MINUTOS
    CASE 
        WHEN (SELECT COUNT(ID_SCRAMBLE) FROM SCRAMBLE 
              WHERE ID_AVERAGE = 3 
              AND COMMENTS1 LIKE 'DNF') > 1 THEN 0
        ELSE 
        -- SE OBTIENE EL RESTO DEL PROMEDIO PARA OBTENER SOLO LOS SEGUNDOS
            MOD(TRUNC((SUM(TIEMPO) - MIN(TIEMPO) - MAX(TIEMPO)) 
                / (A.PERIOD_AVG - 2), 3), 60)
    END AS AVG_SEGUNDO
   FROM
   -- TABLA DERIVADA PARA CALCULAR LOS TIEMPOS 
    (SELECT ID_AVERAGE,   
        CASE
        -- LOS TIEMPOS SE CONVIERTEN EN SEGUNDOS PARA HACER MAS FACIL SU CALCULO
            WHEN COMMENTS1 IS NULL THEN
                MINUTES1 * 60 + SECONDS1
            WHEN COMMENTS1 LIKE '+2' THEN
                (MINUTES1 * 60 + SECONDS1) + 2
            WHEN COMMENTS1 LIKE 'DNF' THEN
                0
        END AS TIEMPO
    FROM SCRAMBLE S
    WHERE S.ID_AVERAGE = 3
   ) TIEMPO
   INNER JOIN AVERAGE A ON TIEMPO.ID_AVERAGE = A.ID_AVERAGE
   WHERE A.ID_AVERAGE = 3
   GROUP BY A.PERIOD_AVG;


## Licencia 📜
Este proyecto está bajo la [Licencia MIT](https://github.com/estelaV9/CubexDatabase/blob/master/license.txt).


