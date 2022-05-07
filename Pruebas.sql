
use calculadora_deducciones

DELIMITER //
CREATE PROCEDURE IMPRIMIR(salario DOUBLE)
BEGIN 
    
    DECLARE impuesto_linea DOUBLE;
	DECLARE impuesto_total DOUBLE DEFAULT 0;
    
	  DECLARE v_izquierda MEDIUMINT;
	  DECLARE v_derecha MEDIUMINT;
	  DECLARE v_porcentaje TINYINT;
      
	  DECLARE fin INTEGER DEFAULT 0;


	  DECLARE rangos_cursor CURSOR FOR
		SELECT extremo_izquierdo, extremo_derecho, porcentaje
        FROM CONFIGURACION_RANGO_SALARIO_IMPUESTO_RENTA
		ORDER BY orden;


	  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 4;

	  OPEN rangos_cursor;
	  get_rangos: LOOP
		FETCH rangos_cursor INTO v_izquierda, v_derecha, v_porcentaje;
		IF fin = 4 THEN
            LEAVE get_rangos;
		END IF;
        SET impuesto_linea = 0;
        IF salario > v_izquierda AND ISNULL(v_derecha) = 1 THEN
			SET impuesto_linea = (salario - v_izquierda) * (v_porcentaje / 100);
			SET impuesto_total = impuesto_total + impuesto_linea;
			select fin as contador, impuesto_linea as linea, impuesto_total as total;
            LEAVE get_rangos;
        ELSEIF salario > v_izquierda AND (salario <= v_derecha OR ISNULL(v_derecha)) THEN
			SET impuesto_linea = (salario - v_izquierda) * (v_porcentaje / 100);
            SET impuesto_total = impuesto_total + impuesto_linea;
			select fin as contador, impuesto_linea as linea, impuesto_total as total;
            LEAVE get_rangos;
		ELSEIF salario > v_derecha THEN
			SET impuesto_linea = (v_derecha-v_izquierda) * (v_porcentaje / 100);
            SET impuesto_total = impuesto_total + impuesto_linea;
			select fin as contador, impuesto_linea as linea, impuesto_total as total;
        END IF;
        
        
	  END LOOP get_rangos;

	  CLOSE rangos_cursor;
END//

CALL IMPRIMIR(5000000);
DROP PROCEDURE IMPRIMIR





SELECT COUNT(*) FROM CALCULO_DEDUCCION;


SELECT 
		@id_valores_deduccion := valores.id_valores_deduccion,
		@ccss_patronal := deduccion_patronal.ccss,
		@aguinaldo := ROUND(deduccion_patronal.aguinaldo,2),
		@cesantia := ROUND(deduccion_patronal.cesantia,2),
		@vacaciones := ROUND(deduccion_patronal.vacaciones,2),
		@riesgos_trabajo_ins := deduccion_patronal.riesgos_trabajo_ins,
		@ccss_obrero := deduccion_obrero.ccss,
		@banco_popular := deduccion_obrero.banco_popular
    FROM VALORES_DEDUCCION valores
    INNER JOIN VALORES_DEDUCCION_OBRERO deduccion_obrero ON deduccion_obrero.id_valores_deduccion_obrero = valores.id_valores_deduccion_obrero
    INNER JOIN VALORES_DEDUCCION_PATRONAL deduccion_patronal ON deduccion_patronal.id_valores_deduccion_patronal = valores.id_valores_deduccion_patronal
    WHERE valores.vigente = 1;





DELIMITER //
CREATE FUNCTION FN_CalcularImpuestoRenta(salario DOUBLE) 
RETURNS DOUBLE
BEGIN
	DECLARE impuesto_linea DOUBLE;
	DECLARE impuesto_total DOUBLE DEFAULT 0;
    
	  DECLARE v_izquierda MEDIUMINT;
	  DECLARE v_derecha MEDIUMINT;
	  DECLARE v_porcentaje TINYINT;
      
	  DECLARE fin INTEGER DEFAULT 0;


	  DECLARE rangos_cursor CURSOR FOR
		SELECT extremo_izquierdo, extremo_derecho, porcentaje
        FROM CONFIGURACION_RANGO_SALARIO_IMPUESTO_RENTA
		ORDER BY orden;


	  DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 4;

	  OPEN rangos_cursor;
	  get_rangos: LOOP
		FETCH rangos_cursor INTO v_izquierda, v_derecha, v_porcentaje;
		IF fin = 4 THEN
            LEAVE get_rangos;
		END IF;
        SET impuesto_linea = 0;
        IF salario > v_izquierda AND ISNULL(v_derecha) = 1 THEN
			SET impuesto_linea = (salario - v_izquierda) * (v_porcentaje / 100);
        ELSEIF salario > v_izquierda AND (salario <= v_derecha OR ISNULL(v_derecha)) THEN
			SET impuesto_linea = (salario - v_izquierda) * (v_porcentaje / 100);
		ELSEIF salario > v_derecha THEN
			SET impuesto_linea = v_derecha * (v_porcentaje / 100);
        END IF;
        
        SET impuesto_total = impuesto_total + impuesto_linea;
        
	  END LOOP get_rangos;

	  CLOSE rangos_cursor;
      
    RETURN impuesto_total;
END//

