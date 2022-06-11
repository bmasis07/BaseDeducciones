
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
        IF salario > v_izquierda AND (salario <= v_derecha OR ISNULL(v_derecha) = 1) THEN
			SET impuesto_linea = (salario - v_izquierda) * (v_porcentaje / 100);
            SET impuesto_total = impuesto_total + impuesto_linea;
			select v_izquierda as izquierdo, v_derecha as derecho, impuesto_linea as impuesto_linea, impuesto_total as impuesto_acumulado;
            LEAVE get_rangos;
		ELSEIF salario > v_derecha THEN
			SET impuesto_linea = (v_derecha-v_izquierda) * (v_porcentaje / 100);
            SET impuesto_total = impuesto_total + impuesto_linea;
			select v_izquierda as izquierdo, v_derecha as derecho, impuesto_linea as impuesto_linea, impuesto_total as impuesto_acumulado;
        END IF;
        
        
	  END LOOP get_rangos;

	  CLOSE rangos_cursor;
END//

CALL IMPRIMIR(900000);
DROP PROCEDURE IMPRIMIR





SELECT COUNT(*) FROM CALCULO_DEDUCCION;



SELECT extremo_izquierdo, extremo_derecho, porcentaje
FROM CONFIGURACION_RANGO_SALARIO_IMPUESTO_RENTA
ORDER BY orden;


