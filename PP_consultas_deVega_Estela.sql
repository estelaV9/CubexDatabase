/*******REALIZADO POR : ESTELA DE VEGA MARTIN 1ºDAM***********/
/**********************CONSULTAS CUBE_X***********************/

/*---------------------TABLA CONTENIDOS------------------------
|  CONDICION  |                   CONSULTAS                   |
|      1      |  CONSULTA --> 2, 3, 5, 6, 7, 8, 9, 10, 11, 12 |
|      2      |  CONSULTA --> 1, 2, 3, 7, 8, 9, 10, 12, 13    |
|      3      |  CONSULTA --> 1, 3, 4, 6, 7, 8, 9, 10, 11, 13 |
|      4      |  CONSULTA --> 3, (7), (8), (9), (10)          |
|      5      |  CONSULTA --> 1(RIGHT), 4(LEFT), 11(RIGHT)    |
|      6      |  CONSULTA --> 4, 6, 7, 8, 9, 10, 11, 13       |
|      7      |  CONSULTA --> 6, 8, 10                        |
|      8      |  CONSULTA --> 3, 5, 8, 9, 10, 13              |
---------------------------------------------------------------*/

/*CONSULTA 1. SELECCIONAR TODOS USUARIOS DESDE EL PRIMER ID HASTA EL ULTIMO Y 
CALCULAR MANUALMENTE EL NIVEL Y LA EXPERIENCIA QUE TIENEN DICHOS USUARIOS, SIN 
USAR EL ATRIBUTO LEVEL_USER. 
SE SUMAN 25 PUNTOS DE EXPERIENCIA POR CADA 5 TIEMPOS REGISTRADOS POR ESE USUARIO. 
CUANDO EL USUARIO ACUMULA 100 PUNTOS DE EXPERIENCIA, SE LE OTORGA UN NUEVO NIVEL.*/
SELECT C.NAME_USER, TRUNC(COUNT(S.ID_SCRAMBLE) * 25 / 100) AS NumNivel,
    COUNT(S.ID_SCRAMBLE) * 25 AS EXPERIENCIA                
FROM SCRAMBLE S 
-- PARA QUE SALGAN TODOS LOS USUARIOS SE APLICA EL RIGHT JOIN
RIGHT JOIN CUBE_USERS C ON S.ID_USER = C.ID_USER
    -- QUE EL ID_USER ESTE ENTRE EL MAXIMO Y EL MINIMO DEL ID DE USUARIO
AND S.ID_USER BETWEEN (SELECT MIN(ID_USER) FROM CUBE_USERS) AND 
    (SELECT MAX(ID_USER) FROM CUBE_USERS)
GROUP BY C.NAME_USER
ORDER BY C.NAME_USER;
/*RESULTADO
AlexMx	2	275
AlgorithmAce	0	0
AlgorithmArtist	0	0
blue985	3	300
CubeChamp	0	50
CubeConnoisseur	0	0
CubeEnthusiast	0	25
CuberExtraordinaire	0	25
Cubero89	0	0
CubingExpert	0	25
CubingFanatic	0	0
CubingSensation	0	0
CubistChallenger	3	375
CubistChampion	0	0
ElJoaki	0	25
FastFingerCuber	0	0
FastFingers	0	0
NinjaRubik	0	25
PuzzleMaestro	0	0
PuzzleNinja	0	25
PuzzlePhenom	0	25
PuzzlePro	0	0
PuzzleProdigy	0	25
PuzzleSavant	0	0
PuzzleWhisperer	0	25
PuzzleWhiz	0	25
QuickCubeMaster	0	0
QuickSolver	3	375
QuickTwister	2	250
QuickTwistExpert	0	0
RapidCuber	0	0
RapidRotation	3	375
RubikGenius99	0	0
RubikMaster	4	400
RubikRiddler	0	25
RubikWhizKid	0	25
SolveGenius	0	25
SolveMaestro	0	0
SolveSavvy	0	25
SpeedCuber23	0	50
SpeedCubingGuru	0	0
SpeedCubist	3	300
SpeedySolver	0	0
SpeedySolver17	0	0
TwistyGuru	0	25
TwistyPro	2	275
TwistyTactician	2	275
TwistyTornado	0	0
TwistyTyphoon	0	25
TwistyWizard	0	25*/



/*CONSULTA 2. SELECCIONAR EL GANADOR DEL CAMPEONATO 122 DE LA CATEGORIA 3X3X3.
PARA DETERMINAR UN GANADOR, SE EVALUARA LA MEDIA DE TIEMPOS, SIENDO EL PARTICIPANTE
CON LA MEDIA MAS BAJA EL GANADOR DE DICHO CAMPEONATO.*/
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
/*RESULTADO
AlexMx*/
    
    
    
/*CONSULTA 3. OBTENER EL NOMBRE Y CALCULAR MANUALMENTE EL PROMEDIO DE TIEMPOS 
DEL USUARIO ASOCIADO AL ID_AVERAGE 3. USAR DE LA TABLA AVERAGE : EL ID
Y EL NUMERO DE TIEMPOS DE ESA MEDIA.
LA MEDIA DE LOS CUBOS SE CALCULA SUMANDO TODOS LOS TIEMPOS, RESTANDO EL MENOR Y
MAYOR TIEMPO Y DIVIENDOLO ENTRE EL NUMERO TOTAL DE TIEMPOS MENOS EL MAYOR Y MENOR.*/
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
/*RESULTADO
TwistyTactician	0	18,593*/



/*CONSULTA 4. SACAR EL MEJOR Y PEOR TIEMPO REGISTRADO POR CADA USUARIO.
SI UN USUARIO NO HA REGISTRADO NINGUN TIEMPO, SE MOSTRARA ':' EN LUGAR DEL TIEMPO.*/
SELECT C.NAME_USER AS NOMBRE, 
        CONCAT(CONCAT(MAX(S.MINUTES1), ':'), MAX(S.SECONDS1)) AS PEORTIEMPO, 
        CONCAT(CONCAT(MIN(S.MINUTES1), ':'), MIN(S.SECONDS1)) AS MEJORTIEMPO
FROM CUBE_USERS C
-- SE HACE USO DEL LEFT PARA ASEGURAR QUE TODOS LOS USUARIOS ESTEN PRESENTES EN 
-- EL RESULTADO
LEFT JOIN SCRAMBLE S ON C.ID_USER = S.ID_USER
GROUP BY C.NAME_USER
ORDER BY C.NAME_USER;
/*RESULTADO
AlexMx	0:16,938	0:3,532
AlgorithmAce	:	:
AlgorithmArtist	:	:
blue985	9:34,183	0:3,454
CubeChamp	59:12,432	0:1,493
CubeConnoisseur	:	:
CubeEnthusiast	0:8,332	0:8,332
CuberExtraordinaire	0:20,432	0:20,432
Cubero89	:	:
CubingExpert	0:17,472	0:17,472
CubingFanatic	:	:
CubingSensation	:	:
CubistChallenger	1:55,255	0:4,223
CubistChampion	:	:
ElJoaki	1:49,432	1:49,432
FastFingerCuber	:	:
FastFingers	:	:
NinjaRubik	0:3,234	0:3,234
PuzzleMaestro	:	:
PuzzleNinja	7:,161	7:,161
PuzzlePhenom	0:24,578	0:24,578
PuzzlePro	:	:
PuzzleProdigy	0:14,112	0:14,112
PuzzleSavant	:	:
PuzzleWhisperer	0:8,124	0:8,124
PuzzleWhiz	0:40,432	0:40,432
QuickCubeMaster	:	:
QuickSolver	1:59,284	0:,922
QuickTwister	0:19,213	0:3,211
QuickTwistExpert	:	:
RapidCuber	:	:
RapidRotation	2:55,682	0:,223
RubikGenius99	:	:
RubikMaster	56:59,992	0:4,23
RubikRiddler	0:15,543	0:15,543
RubikWhizKid	65:42,663	65:42,663
SolveGenius	0:9,345	0:9,345
SolveMaestro	:	:
SolveSavvy	5:43,222	5:43,222
SpeedCuber23	2:7,432	0:3,239
SpeedCubingGuru	:	:
SpeedCubist	2:49,149	0:,998
SpeedySolver	:	:
SpeedySolver17	:	:
TwistyGuru	3:23,677	3:23,677
TwistyPro	1:43,243	0:,798
TwistyTactician	68:43,142	0:3,224
TwistyTornado	:	:
TwistyTyphoon	0:7,543	0:7,543
TwistyWizard	1:34,223	1:34,223*/



/*CONSULTA 5. SACAR EL GANADOR DE TODAS LAS COMPETICIONES, DESDE LA 220 HASTA LA 250.
PARA DETERMINAR EL GANADOR, SE COMPARARA LOS DOS TIEMPOS DE LOS DOS COMPETIDORES
Y SE DECLARARA COMO GANADOR AL QUE REGISTRO EL TIEMPO MAS BAJO. SI SE HA HECHO EL
TIEMPO MAS BAJO PERO HA HECHO UN DNF SE DECLARARA GANADOR AL OTRO CONTRINCANTE.
CALCULANDOSE A MANO SIN MIRAR EL ATRIBUTO WINNER.*/
SELECT 
    CASE    
    -- SI NO HAY COMENTARIOS ENTONCES
        WHEN S.COMMENTS1 IS NULL AND S.COMMENTS2 IS NULL THEN
            CASE 
            -- SE COMPARA EL MENOR TIEMPO Y SI LO HA REALIZADO EL CUBER1 SE LE 
            -- DECLARA GANADOR, SI NO SERA EL CUBER2
                WHEN MENOR = S.MINUTES1 * 60 + S.SECONDS1 THEN 
                    C.CUBER1 || ' ' || TRUNC(MENOR/60) || ':' || 
                        MOD(TRUNC(MENOR, 3), 60)
                WHEN MENOR = S.MINUTES2 * 60 + S.SECONDS2 THEN 
                    C.CUBER2 || ' ' || TRUNC(MENOR/60) || ':' || 
                        MOD(TRUNC(MENOR, 3), 60)
            END
        -- SI EL USUARIO1 HACE UN +2
        WHEN COMMENTS1 LIKE '+2' THEN
            CASE 
            --SE COMPARA EL MENOR TIEMPO Y SI COINCIDE CON EL TIEMPO DEL CUBER1 +2
            -- SE LE DECLARARA GANADOR, SI NO SERA CUBER2
                WHEN MENOR = (S.MINUTES1 * 60 + S.SECONDS1 + 2) THEN 
                    C.CUBER1 || ' ' || TRUNC(MENOR/60) || ' : ' || 
                        MOD(TRUNC(MENOR, 3), 60)                
                WHEN MENOR = S.MINUTES2 * 60 + S.SECONDS2 THEN 
                    C.CUBER2 || ' ' || TRUNC(MENOR/60) || ' : ' || 
                        MOD(TRUNC(MENOR, 3), 60)
            END
        -- SI EL USUARIO2 HACE UN +2
        WHEN COMMENTS2 LIKE '+2' THEN
            CASE 
            --SE HACE LO MISMO PERO SE LE SUMA +2 AL CUBER2
                WHEN MENOR = S.MINUTES1 * 60 + S.SECONDS1 THEN 
                    C.CUBER1 || ' ' || TRUNC(MENOR/60) || ' : ' || 
                        MOD(TRUNC(MENOR, 3), 60)
                WHEN MENOR = (S.MINUTES2 * 60 + S.SECONDS2 + 2) THEN 
                    C.CUBER2 || ' ' || TRUNC(MENOR/60) || ' : ' || 
                        MOD(TRUNC(MENOR, 3), 60)
            END
        -- SI AMBOS USUARIOS HACEN +2, SE COMPARARA EL MENOR TIEMPO SUAMNDOLES +2
        WHEN COMMENTS1 LIKE '+2' AND COMMENTS2 LIKE '+2' THEN
            CASE 
                WHEN MENOR = S.MINUTES1 * 60 + S.SECONDS1 + 2 THEN 
                    C.CUBER1 || ' ' || TRUNC(MENOR/60) || ' : ' || 
                        MOD(TRUNC(MENOR, 3), 60)
                WHEN MENOR = S.MINUTES2 * 60 + S.SECONDS2 + 2 THEN 
                    C.CUBER2 || ' ' || TRUNC(MENOR/60) || ' : ' || 
                        MOD(TRUNC(MENOR, 3), 60)
            END   
        -- SI EL USUARIO 1 HACE UN DNF, SE DECLARA GANADOR AL USUARIO 2
        WHEN S.COMMENTS1 LIKE 'DNF' THEN 
                    C.CUBER2 || ' ' || TRUNC(MENOR/60) || ' : ' || 
                        MOD(TRUNC(MENOR, 3), 60)
        -- SI EL USUARIO 2 HACE UN DNF, SE DECLARA GANADOR AL USUARIO 1
        WHEN S.COMMENTS2 LIKE 'DNF' THEN 
                    C.CUBER1 || ' ' || TRUNC(MENOR/60) || ' : ' || 
                        MOD(TRUNC(MENOR, 3), 60)
        -- SI AMBOS HAN HECHO DNF ENTONCES, SE DECLARA GANADOR QUIEN HAYA OBTENIDO 
        -- MENOR TIEMPO
        WHEN COMMENTS1 LIKE 'DNF' AND COMMENTS2 LIKE 'DNF' THEN
            CASE 
                WHEN MENOR = S.MINUTES1 * 60 + S.SECONDS1 THEN 
                    C.CUBER1 || ' ' || TRUNC(MENOR/60) || ' : ' || 
                        MOD(TRUNC(MENOR, 3), 60)
                WHEN MENOR = S.MINUTES2 * 60 + S.SECONDS2 THEN 
                    C.CUBER2 || ' ' || TRUNC(MENOR/60) || ' : ' || 
                        MOD(TRUNC(MENOR, 3), 60)
            END        
    END AS WINNER
    
FROM 
    -- TABLA DERIVABA PARA COMPARAR LOS 2 TIEMPOS EN FUNCION DE LOS COMENTARIOS
    (SELECT ID_COMPE,   
        CASE
            WHEN COMMENTS1 IS NULL AND COMMENTS2 IS NULL THEN
                LEAST(MINUTES1 * 60 + SECONDS1, MINUTES2 * 60 + SECONDS2)
            WHEN COMMENTS1 LIKE '+2' THEN
                LEAST(MINUTES1 * 60 + SECONDS1 + 2, MINUTES2 * 60 + SECONDS2)
            WHEN COMMENTS2 LIKE '+2' THEN
                LEAST(MINUTES1 * 60 + SECONDS1, MINUTES2 * 60 + SECONDS2 + 2)
            WHEN COMMENTS1 LIKE '+2' AND COMMENTS2 LIKE '+2' THEN
                LEAST(MINUTES1 * 60 + SECONDS1 + 2, MINUTES2 * 60 + SECONDS2 + 2)
            
            WHEN COMMENTS1 LIKE 'DNF' OR COMMENTS2 LIKE 'DNF' THEN
                LEAST(MINUTES1 * 60 + SECONDS1, MINUTES2 * 60 + SECONDS2 )
        END AS MENOR
    FROM SCRAMBLE
    WHERE ID_COMPE BETWEEN 220 AND 250
    ) MENOR    
INNER JOIN COMPETITION C ON MENOR.ID_COMPE = C.ID_COMPE
INNER JOIN SCRAMBLE S ON S.ID_COMPE = C.ID_COMPE 
WHERE C.ID_COMPE BETWEEN 220 AND 250;
/*RESULTADO
blue985 2:31,333
AlexMx 0 : 16,741
MAX PARK 3:12,78
MATS VALK 0 : 32,534
SEUNGBEOM CHO (TYMON) 0:1,295
PATRICK PONCE 0 : ,761
SpeedCubist 2 : 15,463
PHILIPP WEYER 0:1,542
RAMI SBAHI 5:45,232
LUCAS ETTER 0:3,725
SpeedCuber23 2 : 3,239
DREW BRADS 54 : 11,946
SpeedCuber23 0 : 7,432
ElJoaki 1:49,432
MAX SIAUW 0 : 3,432
FELIKS ZEMDEGS 0:20,174
MAX PARK 0:3,233
MATS VALK 0 : 16,432
blue985 0 : 7,153
ElJoaki 0:24,435
FELIKS ZEMDEGS 56:24,334
SolveMaestro 0:8,143
PuzzleProdigy 0 : 14,112
TwistyTyphoon 0:7,543
CubingFanatic 0:2,421
PuzzlePhenom 3 : 12,854
RubikRiddler 0:15,543
RubikWhizKid 65:42,663
MAX PARK 62:12,985
PuzzleMaestro 0 : 19,956*/



/*CONSULTA 6. OBTENER UNA LISTA DE TODOS LOS USUARIOS, JUNTO CON SU DESCUENTO 
Y LA FECHA DE REGISTRO DE LA APLICACION. EL DESCUENTO SE CALCULARA UNICAMENTE 
PARA LOS USUARIOS QUE SON MIEMBROS, LOS DEMAS USUARIOS TENDRAN UN DESCUENTO DE 0. 
EL CALCULO DEL DESCUENTO SE BASA EN QUE SE OTORGARA UN DESCUENTO DE 10 EUROS 
DESPUES DE 6 MESES DE PERTENENCIA, VALIDO PARA COMPETICIONES EXCLUSIVAS.*/
SELECT C.NAME_USER AS NAME_USER, 
    TO_CHAR(0, '99G999L') AS DISCOUNTS,
    TO_CHAR(REGISTRATION_DATE, 'DD Month YYYY') AS FECHA 
FROM CUBE_USERS C
WHERE C.ROLE_USER LIKE 'USER'

UNION 
                
SELECT C.NAME_USER AS NAME_MEMBER, 
    TO_CHAR(((M.DISCOUNT + 10) 
    * TRUNC(MONTHS_BETWEEN(SYSDATE, M.REGISTRATION_DATE)/6)), '99G999L') 
        AS DISCOUNT,
    TO_CHAR(M.REGISTRATION_DATE, 'DD Month YYYY') AS FECHA 
FROM CUBE_USERS C, MEMBERS M 
WHERE C.ID_USER = M.ID_USER
ORDER BY NAME_USER;
/*RESULTADO
AlexMx	             0€	03 Noviembre  2023
AlgorithmAce	            20€	09 Agosto     2023
AlgorithmArtist	             0€	24 Diciembre  2023
blue985	            60€	02 Febrero    2023
CubeChamp	             0€	15 Febrero    2024
CubeConnoisseur	             0€	02 Noviembre  2023
CubeEnthusiast	             0€	18 Marzo      2024
CuberExtraordinaire	             0€	15 Marzo      2023
Cubero89	            20€	08 Mayo       2023
CubingExpert	             0€	30 Marzo      2024
CubingFanatic	             0€	22 Febrero    2024
CubingSensation	             0€	08 Enero      2024
CubistChallenger	            20€	31 Agosto     2023
CubistChampion	            20€	23 Mayo       2023
ElJoaki	            60€	10 Febrero    2023
FastFingerCuber	             0€	01 Enero      2024
FastFingers	             0€	18 Septiembre 2023
NinjaRubik	             0€	27 Marzo      2024
PuzzleMaestro	             0€	04 Marzo      2024
PuzzleNinja	            20€	27 Junio      2023
PuzzlePhenom	             0€	20 Mayo       2023
PuzzlePro	             0€	02 Febrero    2024
PuzzleProdigy	            20€	04 Agosto     2023
PuzzleSavant	            20€	27 Agosto     2023
PuzzleWhisperer	             0€	12 Noviembre  2023
PuzzleWhiz	             0€	22 Marzo      2024
QuickCubeMaster	             0€	05 Agosto     2023
QuickSolver	            60€	14 Marzo      2023
QuickTwister	            60€	04 Febrero    2023
QuickTwistExpert	             0€	18 Septiembre 2023
RapidCuber	             0€	11 Abril      2024
RapidRotation	             0€	16 Febrero    2024
RubikGenius99	             0€	18 Septiembre 2023
RubikMaster	            20€	17 Junio      2023
RubikRiddler	             0€	05 Agosto     2023
RubikWhizKid	             0€	10 Junio      2023
SolveGenius	             0€	19 Febrero    2024
SolveMaestro	             0€	12 Abril      2024
SolveSavvy	             0€	05 Abril      2024
SpeedCuber23	             0€	11 Febrero    2024
SpeedCubingGuru	             0€	10 Junio      2023
SpeedCubist	             0€	20 Marzo      2024
SpeedySolver	             0€	24 Febrero    2024
SpeedySolver17	             0€	20 Mayo       2023
TwistyGuru	             0€	24 Diciembre  2023
TwistyPro	             0€	04 Enero      2024
TwistyTactician	             0€	12 Noviembre  2023
TwistyTornado	             0€	10 Junio      2023
TwistyTyphoon	             0€	05 Abril      2023
TwistyWizard	             0€	10 Febrero    2024*/   
 
 
    
/*CONSULTA 7. CALCULAR EL DESCUENTO ACUMULADO PARA LOS MIEMBROS QUE PARTICIPARON 
EN LA COMPETICION DE MIEMBROS 122, SIN USAR EL ATRIBUTO DISOUNT, INCREMENTANDO
10 EUROS EN EL DISCOUNT POR CADA 6 MESES QUE ES SOCIO.*/
    -- CAMBIO UN PARTICIPANTE YA QUE NO TIENE DESCUENTO PARA ENTRAR 
     UPDATE USER_CHAMP_COMPETE SET ID_USER = 49 WHERE ID_USER = 32;
SELECT ID_USER, TO_CHAR(((DISCOUNT + 10) 
    * TRUNC(MONTHS_BETWEEN(SYSDATE, REGISTRATION_DATE)/6)) - 
        (SELECT PRICE FROM CHAMPIONSHIP WHERE ID_CHAMP = 122), '99G999L') 
        AS DISCOUNT
FROM MEMBERS
WHERE ID_USER IN (SELECT ID_USER FROM USER_CHAMP_COMPETE 
                    WHERE ID_CHAMP = 122)
ORDER BY ID_USER;
/*RESULTADO
6	10€
7	50€
37	10€
49	10€*/




/*CONSULTA 8. CALCULAR EL TIEMPO PROMEDIO DURANTE EL MES CON MAS REGISTROS DE 
TIEMPOS POR EL USUARIO CON ID 6.*/
SELECT C.NAME_USER AS NAME,
    -- CALCULAR EL PROMEDIO MINUTOS
    CASE 
        -- SI EL USUARIO HA REGISTRADO MAS DE UN DNF EN EL MES CON MAS REGISTROS,
        -- EL PROMEDIO SE ESTABLECE EN 0
        WHEN (SELECT COUNT(ID_SCRAMBLE) FROM SCRAMBLE 
              WHERE ID_USER = 6 
              AND COMMENTS1 LIKE 'DNF'
              -- OBTENER EL MES
              AND SUBSTR(REGISTRATION_DATE, 4, 2) = 
                    (SELECT SUBSTR(REGISTRATION_DATE, 4, 2) AS MES
                    FROM SCRAMBLE 
                    WHERE ID_USER = 6 
                    -- SE AGRUPA POR MES
                    GROUP BY ID_USER, SUBSTR(REGISTRATION_DATE, 4, 2)
                    -- Y SE VISUALIZA EL QUE TENGA EL MAXIMO DE LOS TIEMPOS
                    HAVING COUNT(ID_SCRAMBLE)  = 
                        -- OBTENER EL NUMERO MAXIMO DE REGISTROS DE TIEMPOS PARA EL
                        -- USUARIO 6 EN UN MES
                        (SELECT MAX(COUNT(ID_SCRAMBLE)) FROM SCRAMBLE 
                        WHERE ID_USER = 6
                        GROUP BY SUBSTR(REGISTRATION_DATE, 4, 2)))) > 1 THEN 0
        ELSE   
        -- SUMAR TODOS LOS TIEMPOS, RESTANDO EL MENOR Y MAYOR Y DIVIDIENDOLES
        -- ENTRE TANTOS REGISTROS HAYA HECHO EN ESE MES -2, DIVIDIDO ENTRE 60 PARA 
        -- OBTENER LOS MINUTOS
            TRUNC((SUM(TIEMPO) - MIN(TIEMPO) - MAX(TIEMPO)) / (COUNT(TIEMPO)- 2) / 60) 
    END AS AVG_MINUTOS,
    -- CALCULAR EL PROMEDIO SEGUNDOS
    CASE 
        -- SI HAY MAS DE 2 DNF REGISTRADOS, EL PROMEDIO SE ESTABLECE EN CERO
        WHEN (SELECT COUNT(ID_SCRAMBLE) FROM SCRAMBLE 
              WHERE ID_USER = 6 
              AND COMMENTS1 LIKE 'DNF'
              AND SUBSTR(REGISTRATION_DATE, 4, 2) = 
                    (SELECT SUBSTR(REGISTRATION_DATE, 4, 2) AS MES
                    FROM SCRAMBLE 
                    WHERE ID_USER = 6 
                    GROUP BY ID_USER, SUBSTR(REGISTRATION_DATE, 4, 2)
                    HAVING COUNT(ID_SCRAMBLE)  = 
                        (SELECT MAX(COUNT(ID_SCRAMBLE)) FROM SCRAMBLE 
                        WHERE ID_USER = 6
                        GROUP BY SUBSTR(REGISTRATION_DATE, 4, 2)))) > 1 THEN 0
        ELSE 
        -- SE OBTIENE EL RESTO DE DIVIDIR ENTRE 60 PARA OBTENER LOS SEGUNDOS
            MOD(TRUNC((SUM(TIEMPO) - MIN(TIEMPO) - MAX(TIEMPO)) 
                / (COUNT(TIEMPO)- 2), 3), 60)
    END AS AVG_SEGUNDOS
FROM
--TABLA DERIVADA PARA CALCULAR LOS TIEMPOS DEL USUARIO 6 EN EL MES CON MAS REGISTROS
-- SEGUN SUS COMENTARIOS 
    (SELECT S.ID_USER,   
        CASE
        -- SE CONVIERTEN EN SEGUNDOS PARA FACILITAR EL CALCULO 
            WHEN COMMENTS1 IS NULL THEN
                MINUTES1 * 60 + SECONDS1
            WHEN COMMENTS1 LIKE '+2' THEN
                (MINUTES1 * 60 + SECONDS1) + 2
            WHEN COMMENTS1 LIKE 'DNF' THEN
                0
        END AS TIEMPO
    FROM SCRAMBLE S
    WHERE S.ID_USER = 6
    AND SUBSTR(S.REGISTRATION_DATE, 4, 2) = 
        -- SELECIONAR EL MES CON MAS REGISTROS 
        (SELECT SUBSTR(REGISTRATION_DATE, 4, 2) AS MES
        FROM SCRAMBLE 
        WHERE ID_USER = 6 
        GROUP BY SUBSTR(REGISTRATION_DATE, 4, 2)
        HAVING COUNT(ID_SCRAMBLE)  = 
            (SELECT MAX(COUNT(ID_SCRAMBLE)) FROM SCRAMBLE 
            WHERE ID_USER = 6
            GROUP BY SUBSTR(REGISTRATION_DATE, 4, 2)))
) TIEMPO
INNER JOIN CUBE_USERS C ON C.ID_USER = TIEMPO.ID_USER 
GROUP BY C.NAME_USER;
/*RESULTADO
RubikMaster	0	36,542*/


/*CONSULTA 9. CALCULAR EL PORCENTAJE DE USUARIOS QUE SON SOCIOS Y 
USUARIOS NORMALES.*/
SELECT COUNT(C.ID_USER) AS TOTAL_USUARIOS, USERS.USUARIOS,
    CONCAT((USERS.USUARIOS / COUNT(C.ID_USER)) * 100, '%') AS USER_PORCENT,    
    COUNT(C.ID_USER) - USERS.USUARIOS AS NUMERO_MIEMBROS, 
    CONCAT(100 - (USERS.USUARIOS / COUNT(C.ID_USER)) * 100, '%') AS MEMBER_PORCENT 
FROM CUBE_USERS C , (SELECT COUNT(ID_USER) AS USUARIOS 
                    FROM CUBE_USERS 
                    WHERE ROLE_USER LIKE 'USER') USERS            
GROUP BY USERS.USUARIOS; 
/*RESULTADO
50	28	56%	22	44%*/
     
                    
                    
/*CONSULTA 10. CALCULAR EL PORCENTAJE DE CADA USUARIO EN RELACION AL TIPO DE 
CUBO MAS USADO.*/
SELECT S.ID_USER, U.NAME_USER,
    CONCAT(ROUND((COUNT(S.ID_TYPE) / TIPO.TOTAL_NUM_TIPO)* 100, 2), '%') AS PORCENTAJE
FROM SCRAMBLE S, CUBE_USERS U, (SELECT ID_TYPE, 
                                COUNT(ID_TYPE) AS TOTAL_NUM_TIPO
                                FROM SCRAMBLE
                                GROUP BY ID_TYPE) TIPO 
WHERE U.ID_USER = S.ID_USER
AND S.ID_TYPE = TIPO.ID_TYPE
AND S.ID_TYPE = (SELECT ID_TYPE
                FROM SCRAMBLE
                GROUP BY ID_TYPE
                -- SE SELECIONA EL ID DEL TIPO DE CUBO QUE TENGA MAS USO
                HAVING ROUND((COUNT(ID_TYPE) * 100
                    / TIPO.TOTAL_NUM_TIPO), 2) =
                        (SELECT MAX(ROUND((COUNT(ID_TYPE)
                            / TIPO.TOTAL_NUM_TIPO) * 100, 2))
                        FROM SCRAMBLE
                        GROUP BY ID_TYPE)
)
GROUP BY S.ID_USER, U.NAME_USER, TIPO.TOTAL_NUM_TIPO
ORDER BY S.ID_USER;
/*RESULTADO
1	blue985	14,81%
3	AlexMx	9,26%
6	RubikMaster	9,26%
7	QuickSolver	9,26%
17	QuickTwister	9,26%
20	SpeedCubist	11,11%
21	TwistyPro	9,26%
32	RapidRotation	9,26%
37	CubistChallenger	9,26%
41	TwistyTactician	9,26%*/



/*CONSULTA 11. OBTENER LOS NOMBRES DE LOS GANADORES DE LAS COMPETICIONES REALIZADAS 
DURANTE EL PERIODO DEL 1 DE ENERO DE 2024 AL 28 DE FEBRERO DE 2024. INCLUSO EN 
CASO DE QUE NO HAYA COINCIDENCIAS CON REGISTROS DE COMPETICIONES EN LA TABLA 
SCRAMBLE, SE DEBEN INCLUIR TODOS LOS POSIBLES GANADORES.*/
SELECT C.WINNER
FROM COMPETITION C
RIGHT JOIN SCRAMBLE S ON S.ID_COMPE = C.ID_COMPE
WHERE S.REGISTRATION_DATE >= TO_DATE('2024-01-01', 'YYYY-MM-DD') 
AND S.REGISTRATION_DATE <= TO_DATE('2024-02-28', 'YYYY-MM-DD')
ORDER BY  C.WINNER DESC;
/*RESULTADO
1 - 60 : NULL
SpeedCuber23
SpeedCuber23
SolveMaestro
SEUNGBEOM CHO (TYMON)
PATRICK PONCE
MAX PARK
MATS VALK
FELIKS ZEMDEGS
ElJoaki
AlexMx*/


/*CONSULTA 12. OBTENER LOS SCRAMBLES REALIZADOS POR LOS GANADORES DEL CAMPEONATO 
121.*/
SELECT DISTINCT S.ID_USER,S.DESCRIPTION_SCRAMBLE 
FROM SCRAMBLE S, CUBE_USERS C  
WHERE C.ID_USER = S.ID_USER
AND S.ID_CHAMP = 121
AND S.ID_USER IN (SELECT ID_USER FROM CUBE_USERS 
                    WHERE NAME_USER IN (SELECT WINNER FROM CUBE_CHAMP_PERTENECE
                                        WHERE ID_CHAMP = 121));
/*RESULTADO
3	U R` B R` L` U2 F B` R U` R2 F2 U` L R2 U L` F B` U B F D F` D`
3	B` R` U2 R2 F2 L2 D` R L` U R F` B2 L` B` F` D` R U2 B L2 B2 F2 U2 L
3	D U F` D` B` L2 F U L F D2 L` U2 F` U` F2 U` D` R U F2 D` B D` B`
3	U` F` L` D2 B L2 B2 R U2 F R` F B2 R2 B` L D F U` D R U2 R` F B
3	L` D F` U R` D U` F2 R B` R` D B` U` D2 L` U` B L` F` U2 B F U2 L
21	B2 L` U` F` R2 D U L` R` B2 L` D R` F2 B2 R2 L2 F2 U` F` L` B` L` B2 D`
21	L D R` F` B2 L R` B` U B2 D` L2 R2 F D` U F` B` L2 D2 R L F B D2
21	L2 B U` D B D` R` F` D2 R L` F` L2 U R` L2 F` L D U2 R2 F D2 U2 L2
21	U2 B D R2 D U F` R2 F D2 B R2 F2 D2 B2 F D2 B2 U F L R` U F` U`
21	R2 B` R2 D` R2 U B` F2 L` B R` D` R` L` F2 L` F` B` L B2 F` R` B2 D2 L`
3	B R´ B´ U´ B U´ B L R´ u l b
3	U B L` B` L R` L` B R` L` l b
3	L B` U` R` L` R` L R U` L` u l
3	L` B U` B` L R L B` L` B` l r`
3	L B` L U R B R L` R` L u r
21	B` U B R` L` R U R` B` U` B` U
21	L` B` R L` B L` B L` B` R` B r`
21	R B R` B R U B R U L` u` b`
21	L B` R L U` R U` R B L l` b*/



/*CONSULTA 13. CALCULAR EL PORCENTAJE DE USO DE CADA TIPO DE CUBO EN RELACION 
CON EL TOTAL DE USOS. (sencilla)*/
SELECT ID_TYPE, 
       CONCAT(ROUND((COUNT(ID_TYPE) / POR_TIPO.TIPO) * 100, 2), '%') 
            AS PORCENTAJE
FROM SCRAMBLE, (SELECT COUNT(ID_TYPE) AS TIPO 
                FROM SCRAMBLE) POR_TIPO
GROUP BY ID_TYPE, POR_TIPO.TIPO
ORDER BY ID_TYPE;
/*RESULTADO
1	2,68%
2	19,46%
3	,67%
4	,67%
5	1,34%
6	,67%
7	36,24%
8	14,77%
9	1,34%
10	1,34%
11	1,34%
12	,67%
13	1,34%
14	,67%
15	14,77%
16	,67%
17	,67%
20	,67%*/