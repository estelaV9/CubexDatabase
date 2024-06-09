# CubexDatabase 🔷
Base de datos de una aplicación sobre cubos de Rubik. Con su modelo e/r, base de datos, consultas y ejercicios PL/SQL.

## Proyecto de Base de Datos - Primer Trimestre 📊
### Introducción
Este proyecto de base de datos fue desarrollado como parte del primer trimestre del curso de DAM. <br>
El objetivo principal de mi proyecto fue diseñar y desarrollar una base de datos relacional basada en un modelo entidad-relación (ER) sobre una aplicación de cubos de Rubik. <br>

### Modelo Entidad-Relación (ER)
Aquí puedes encontrar el diagrama del modelo entidad-relación del proyecto : <br>

![Modelo Entidad-Relación](https://github.com/estelaV9/CubexDatabase/blob/main/modeloER_CubeX.png) <br>

## Proyecto de Base de Datos - Segundo Trimestre 🗃️
### Introducción
Este proyecto de base de datos es el paso a tablas del modelo entidad-relación del primer trimestre. <br>
Se reformó el modelo entidad-relación, quedando así : <br>

![Modelo Entidad-Relación](https://github.com/estelaV9/CubexDatabase/blob/main/modeloER_CubeX_Reformado.png) <br>

### Base de Datos
La [base de datos](https://github.com/estelaV9/CubexDatabase/blob/master/DF_deVega_Estela.sql) consta de varias tablas que representan las entidades y relaciones definidas en el modelo ER. <br>

### Consultas
He desarrollado varias [consultas SQL](https://github.com/estelaV9/CubexDatabase/blob/master/PP_consultas_deVega_Estela.sql) para el proyecto. Como por ejemplo: <br>

   ```sql
   CONSULTA 1. OBTENER EL NOMBRE Y CALCULAR MANUALMENTE EL PROMEDIO DE TIEMPOS 
   DEL USUARIO ASOCIADO AL ID_AVERAGE 3. USAR DE LA TABLA AVERAGE : EL ID
   Y EL NUMERO DE TIEMPOS DE ESA MEDIA.
   LA MEDIA DE LOS CUBOS SE CALCULA SUMANDO TODOS LOS TIEMPOS, RESTANDO EL MENOR Y
   MAYOR TIEMPO Y DIVIENDOLO ENTRE EL NUMERO TOTAL DE TIEMPOS MENOS EL MAYOR Y MENOR.

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
       END AS AVG_SEGUNDOS
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
   ```

## Proyecto de Base de Datos - Tercer Trimestre 📋
### Introducción
Desarrollé [ejercicios de PL/SQL](https://github.com/estelaV9/CubexDatabase/blob/main/PLSQL_deVega_Estela.sql) basado en la [base de datos](https://github.com/estelaV9/CubexDatabase/blob/master/DF_deVega_Estela.sql) del segundo trimestre, con los siguientes requisitos : <br>
Realizar al menos 2 funciones y 3 procedimientos utilizando : 
   - IF – CASE.
   - Bucles.
   - Cursores implícitos y explícitos.

Realiza además un trigger para automatizar que se lance al menos alguno de los bloques de código anteriores. <br>
Realiza un trigger para automatizar la actualización de el/los atributo derivados que tiene tu base de datos. <br>

### Ejercicios
Se desarrolló ejercicios como por ejemplo :

   ```sql
   EJERCICIO 4. CREAR UN PROCEDIMIENTO LLAMADO "insertTimesChamp" QUE PERMITA INSERTAR TIEMPOS
   DE UN USUARIO EN UN CAMPEONATO Y, POSTERIORMENTE, MOSTRAR EL GANADOR DE ESE 
   CAMPEONATO. PARA OBTENER EL GANADOR SE LLAMARA A UNA FUNCION QUE RETORNE EL NOMBRE
   DEL QUE HAYA HECHO LA MENOR MEDIA. EL GANADOR SE MOSTRARA PASADOS LOS CINCO 
   TIEMPOS DE CADA USUARIO.
   /* CREAR UNA FUNCION QUE DEVUELVA EL NOMBRE DEL USUARIO QUE TENGA LA MENOR
   MEDIA DE TIEMPOS DE UN CAMPEONATO DE UNA CATEGORIA */
   CREATE OR REPLACE FUNCTION nomUserMinTime (P_ID_CHAMP CHAMPIONSHIP.ID_CHAMP%TYPE,
       P_ID_CATEGORY CUBE_TYPE.ID_TYPE%TYPE)
   RETURN VARCHAR2
   IS 
       V_NAME CUBE_USERS.NAME_USER%TYPE;
   BEGIN
       SELECT NAME_USER INTO V_NAME FROM CUBE_USERS
               WHERE ID_USER = (
                   SELECT DISTINCT ID_USER
                   FROM SCRAMBLE
                   WHERE ID_AVERAGE = (
                       SELECT DISTINCT ID_AVERAGE
                       FROM AVERAGE
                       WHERE AVG_MINUTES * 60 + AVG_SECONDS = (
                           SELECT MIN(AVG_MINUTES * 60 + AVG_SECONDS)
                           FROM AVERAGE
                           WHERE ID_AVERAGE IN ( 
                               SELECT DISTINCT ID_AVERAGE
                               FROM SCRAMBLE
                               WHERE ID_TYPE = P_ID_CATEGORY
                               AND ID_CHAMP = P_ID_CHAMP
                           )
                       )
                   )
               );
       RETURN V_NAME;
   END nomUserMinTime;
   /
   
   CREATE OR REPLACE PROCEDURE insertTimesChamp (
       P_ID_CHAMP CHAMPIONSHIP.ID_CHAMP%TYPE,
       P_ID_USER USER_CHAMP_COMPETE.ID_USER%TYPE, 
       P_SCRAMBLE SCRAMBLE.DESCRIPTION_SCRAMBLE%TYPE,
       P_NAME_CATEGORY CUBE_TYPE.NAME_TYPE%TYPE,
       P_MINUTES SCRAMBLE.MINUTES1%TYPE,
       P_SECONDS SCRAMBLE.SECONDS1%TYPE,
       P_ID_AVERAGE SCRAMBLE.ID_AVERAGE%TYPE,
       P_COMMENTS SCRAMBLE.COMMENTS1%TYPE DEFAULT null
   ) 
   IS
       V_ID_CATEGORY CUBE_TYPE.ID_TYPE%TYPE;
       V_WINNER CUBE_USERS.NAME_USER%TYPE;
       V_MIN_TIME NUMBER;
       V_MAX_ID_SCRAMBLE SCRAMBLE.ID_SCRAMBLE%TYPE;
       V_EXISTS AVERAGE.ID_AVERAGE%TYPE;
       V_SCRAMBLE_COUNT SCRAMBLE.ID_SCRAMBLE%TYPE;
       V_AVG_EXISTS SCRAMBLE.ID_AVERAGE%TYPE;
       CURSOR C_CHECK_CHAMP IS
           SELECT ID_CHAMP FROM CHAMPIONSHIP WHERE ID_CHAMP = P_ID_CHAMP;
       V_CH_CHAMP C_CHECK_CHAMP%ROWTYPE;
       
       CURSOR C_CHECK_USER_CHAMP IS
           SELECT ID_USER FROM USER_CHAMP_COMPETE WHERE ID_CHAMP = P_ID_CHAMP 
                                                   AND ID_USER = P_ID_USER;
       V_CH_USERCHAMP C_CHECK_USER_CHAMP%ROWTYPE;
       
       CURSOR C_CHECK_CATEGORY IS
           SELECT ID_TYPE FROM CUBE_CHAMP_PERTENECE WHERE ID_CHAMP = P_ID_CHAMP AND ID_TYPE = 
               (SELECT ID_TYPE FROM CUBE_TYPE WHERE NAME_TYPE = P_NAME_CATEGORY);
       V_CH_CATEGORY C_CHECK_CATEGORY%ROWTYPE;
       
       CURSOR C_CHECK_IDAVERAGE IS
           SELECT ID_AVERAGE FROM SCRAMBLE WHERE ID_CHAMP = P_ID_CHAMP 
                               AND ID_USER = P_ID_USER AND ID_TYPE = V_ID_CATEGORY;
       V_CH_IDAVERAGE C_CHECK_IDAVERAGE%ROWTYPE;
   BEGIN
   
      -- VERIFICAR SI EL ID DE CAMPEONATO EXISTE
       OPEN C_CHECK_CHAMP;
       FETCH C_CHECK_CHAMP INTO V_CH_CHAMP;
       IF C_CHECK_CHAMP%NOTFOUND THEN
           CLOSE C_CHECK_CHAMP;
           RAISE_APPLICATION_ERROR(-20001, 'Error: El ID de campeonato no existe.');
       END IF;
       CLOSE C_CHECK_CHAMP;
       
       -- VERIFICAR SI EL ID DE USUARIO PERTENECE AL CAMPEONATO
       OPEN C_CHECK_USER_CHAMP;
       FETCH C_CHECK_USER_CHAMP INTO V_CH_USERCHAMP;
       IF C_CHECK_USER_CHAMP%NOTFOUND THEN
           CLOSE C_CHECK_USER_CHAMP;
           RAISE_APPLICATION_ERROR(-20002, 'Error: El usuario no pertenece al campeonato especificado.');
       END IF;
       CLOSE C_CHECK_USER_CHAMP;
       
       -- VERIFICAR SI LA CATEGORÍA PERTENECE AL CAMPEONATO
       OPEN C_CHECK_CATEGORY;
       FETCH C_CHECK_CATEGORY INTO V_CH_CATEGORY;
       IF C_CHECK_CATEGORY%NOTFOUND THEN
           CLOSE C_CHECK_CATEGORY;
           RAISE_APPLICATION_ERROR(-20003, 'Error: La categoría no pertenece al 
               campeonato especificado.');
       END IF;
       CLOSE C_CHECK_CATEGORY;
       
       -- OBTENER ID_TYPE PARA LA CATEGORÍA
       SELECT ID_TYPE INTO V_ID_CATEGORY FROM CUBE_TYPE WHERE NAME_TYPE LIKE P_NAME_CATEGORY;
       
      -- VERIFICAR SI EL USUARIO YA TIENE UN ID_AVERAGE EN ESTA CATEGORÍA
      OPEN C_CHECK_IDAVERAGE;
       FETCH C_CHECK_IDAVERAGE INTO V_CH_IDAVERAGE;
       IF V_CH_IDAVERAGE.ID_AVERAGE != P_ID_AVERAGE THEN
           CLOSE C_CHECK_IDAVERAGE;
           RAISE_APPLICATION_ERROR(-20004, 'Error: El usuario ya tiene un ID_AVERAGE 
               distinto en esta categoría para este campeonato.');
       END IF;
       CLOSE C_CHECK_IDAVERAGE;
       
       -- VERIFICAR SI EL USUARIO YA TIENE CINCO TIEMPOS EN ESTA CATEGORÍA
       SELECT COUNT(ID_SCRAMBLE) INTO V_SCRAMBLE_COUNT 
       FROM SCRAMBLE 
       WHERE ID_CHAMP = P_ID_CHAMP AND ID_USER = P_ID_USER AND ID_TYPE = V_ID_CATEGORY;
       
       IF V_SCRAMBLE_COUNT >= 5 THEN
           RAISE_APPLICATION_ERROR(-20005, 'Error: El usuario ya tiene cinco tiempos 
               en esta categoría para este campeonato.');
       ELSE IF V_SCRAMBLE_COUNT = 4 THEN 
           -- ACTUALIZAR EL GANADOR DEL CAMPEONATO
           UPDATE CUBE_CHAMP_PERTENECE SET WINNER =
               nomUserMinTime(P_ID_CHAMP, V_ID_CATEGORY) 
           WHERE ID_CHAMP = P_ID_CHAMP AND ID_TYPE = V_ID_CATEGORY;
           
           -- SELECCIONAR EL GANADOR
           SELECT WINNER INTO V_WINNER  FROM CUBE_CHAMP_PERTENECE 
               WHERE ID_CHAMP = P_ID_CHAMP AND ID_TYPE = V_ID_CATEGORY;
           -- MOSTRAR EL GANADOR DEL CAMPEONATO
           DBMS_OUTPUT.PUT_LINE('El ganador del campeonato ' || P_ID_CHAMP || ' es el usuario ' || V_WINNER);
           END IF;
       END IF;
       
       -- SI NO EXISTE EL ID DEL AVERAGE, SE CREARA UNO
       SELECT COUNT(ID_AVERAGE) INTO V_EXISTS FROM AVERAGE WHERE ID_AVERAGE = P_ID_AVERAGE;
       IF V_EXISTS = 0 THEN
           INSERT INTO AVERAGE (ID_AVERAGE, PERIOD_AVG) VALUES (P_ID_AVERAGE, 0);
       END IF;
   
       -- INSERTAR EL TIEMPO EN LA TABLA SCRAMBLE
       SELECT MAX(ID_SCRAMBLE) INTO V_MAX_ID_SCRAMBLE FROM SCRAMBLE; 
       INSERT INTO SCRAMBLE (ID_SCRAMBLE, ID_USER, ID_TYPE, DESCRIPTION_SCRAMBLE, 
           MINUTES1, SECONDS1, COMMENTS1, ID_AVERAGE, ID_CHAMP, REGISTRATION_DATE)
       VALUES (V_MAX_ID_SCRAMBLE + 1, P_ID_USER, V_ID_CATEGORY, P_SCRAMBLE, P_MINUTES,
           P_SECONDS, P_COMMENTS, P_ID_AVERAGE, P_ID_CHAMP, SYSDATE);
       
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               DBMS_OUTPUT.PUT_LINE('Error: No se encontraron datos.');
           WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
   END insertTimesChamp;
   /
   ```

## Licencia 📜
Este proyecto está bajo la [Licencia MIT](https://github.com/estelaV9/CubexDatabase/blob/master/license.txt).<br> 

>_IES Ribera de Castilla._
