


/*---------------------------------------------------------------------------------------------------------------*/ 
/*----------------------------------- CREACIÓN Y LLENADO DE DATOS DE LA BASE-------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------*/ 
CREATE SCHEMA calculadora_deducciones;

USE calculadora_deducciones;


CREATE TABLE ROL_DE_SISTEMA(
	id_rol_sistema TINYINT,
    nombre VARCHAR(20),
    PRIMARY KEY (id_rol_sistema)
);

INSERT INTO ROL_DE_SISTEMA(id_rol_sistema, nombre)
VALUE(1,'Administrador'),
	(2,'Propietario'),
	(3,'Recursos humanos'),
	(4,'Consulta');
    
SELECT * FROM ROL_DE_SISTEMA;

CREATE TABLE DEPARTAMENTO_EMPRESA(
	id_departamento_empresa TINYINT,
    nombre VARCHAR(30),
    PRIMARY KEY (id_departamento_empresa)
);

INSERT INTO DEPARTAMENTO_EMPRESA(id_departamento_empresa, nombre)
VALUE(1,'Gerencia'),
	(2,'Ventas'),
	(3,'Recursos humanos'),
	(4,'Producción'),
	(5,'IT');
    
SELECT * FROM DEPARTAMENTO_EMPRESA;


/*-- TABLA TEMPORAL PARA LA CARGA DE DATOS ---*/ 
DROP TABLE datos_empleados;
CREATE TABLE datos_empleados (
  cedula text NOT NULL,
  nombre text,
  apellido1 text,
  apellido2 text,
  salario double NOT NULL DEFAULT '0',
  fecha_nacimiento varchar(29) DEFAULT NULL,
  Organizacion double NOT NULL DEFAULT '0',
  Departamento double NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


/*-- INSTRUCCIÓN PARA CARGA MASIVA DE DATOS---*/ 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tbl_Empleados_full.csv' INTO TABLE datos_empleados 
  FIELDS TERMINATED BY ';' enclosed by '"'
  IGNORE 1 LINES;
  
  

DROP TABLE EMPLEADOS;
CREATE TABLE EMPLEADOS (
  id_empleado mediumint AUTO_INCREMENT,
  cedula varchar(20) NOT NULL,
  nombre varchar(30) NOT NULL,
  apellido1 varchar(30) NOT NULL,
  apellido2 varchar(30) NOT NULL,	
  contrasenia varchar(12) NOT NULL DEFAULT '',
  salario_actual double NOT NULL DEFAULT 0,
  empleado_activo BIT NOT NULL DEFAULT 1,
  porcentaje_asociacion TINYINT DEFAULT 0,
  id_rol_sistema TINYINT DEFAULT 4,
  id_departamento_empresa TINYINT DEFAULT 4,
  PRIMARY KEY (id_empleado),
  FOREIGN KEY (id_rol_sistema) REFERENCES ROL_DE_SISTEMA(id_rol_sistema),
  FOREIGN KEY (id_departamento_empresa) REFERENCES DEPARTAMENTO_EMPRESA(id_departamento_empresa)
);

  
  /*-- INSERSIÓN DE DATOS DESDE LA TABLA TEMPORAL A NUESTRA TABLA DE EMPLEADOS---*/ 
  INSERT INTO empleados(cedula, nombre, apellido1, apellido2, salario_actual)
  SELECT emp.cedula, emp.nombre, emp.apellido1, emp.apellido2 , emp.salario
  FROM datos_empleados emp;
  
  DROP TABLE HISTORIAL_DESPIDO;
  CREATE TABLE HISTORIAL_DESPIDO(
	id_historial_despido TINYINT AUTO_INCREMENT,
	id_empleado MEDIUMINT,
    fecha_despido DATE,
    motivo VARCHAR(180),
    PRIMARY KEY (id_historial_despido),
    FOREIGN KEY (id_empleado) REFERENCES EMPLEADOS(id_empleado)
);
  
  DROP TABLE HISTORIAL_SALARIAL;
    CREATE TABLE HISTORIAL_SALARIAL(
	id_historial_salarial MEDIUMINT AUTO_INCREMENT,
	id_empleado MEDIUMINT,
    salario DOUBLE,
    fecha DATE,
    PRIMARY KEY (id_historial_salarial),
    FOREIGN KEY (id_empleado) REFERENCES EMPLEADOS(id_empleado)
);

SELECT COUNT(id_historial_salarial) FROM HISTORIAL_SALARIAL;

INSERT INTO HISTORIAL_SALARIAL (id_empleado, salario, fecha)
SELECT emp.id_empleado, emp.salario_actual, CAST(NOW() AS DATE)
FROM EMPLEADOS emp;

DROP TABLE CONFIGURACION_RANGO_SALARIO_IMPUESTO_RENTA;
CREATE TABLE CONFIGURACION_RANGO_SALARIO_IMPUESTO_RENTA(
	orden TINYINT,
	extremo_izquierdo MEDIUMINT,
    extremo_derecho MEDIUMINT,
    porcentaje TINYINT
);

INSERT INTO CONFIGURACION_RANGO_SALARIO_IMPUESTO_RENTA(orden, extremo_izquierdo, extremo_derecho, porcentaje)
VALUE(1,0,863000,0),
	(2,863000,1267000,10),
	(3,1267000,2223000,15),
	(4,2223000,4445000,20),
	(5,4445000,NULL,25);
    
SELECT * FROM CONFIGURACION_RANGO_SALARIO_IMPUESTO_RENTA;

DROP TABLE VALORES_DEDUCCION_OBRERO;
CREATE TABLE VALORES_DEDUCCION_OBRERO(
	id_valores_deduccion_obrero SMALLINT AUTO_INCREMENT,
	ccss FLOAT,
    banco_popular FLOAT,
    PRIMARY KEY(id_valores_deduccion_obrero)
);

INSERT INTO VALORES_DEDUCCION_OBRERO(ccss, banco_popular)
VALUES(9.5 , 1 );

DROP TABLE VALORES_DEDUCCION_PATRONAL;
CREATE TABLE VALORES_DEDUCCION_PATRONAL(
	id_valores_deduccion_patronal SMALLINT AUTO_INCREMENT,
	ccss FLOAT,
    aguinaldo FLOAT,
    cesantia FLOAT,
    vacaciones FLOAT,
    riesgos_trabajo_ins FLOAT,
    PRIMARY KEY(id_valores_deduccion_patronal)
);

INSERT INTO VALORES_DEDUCCION_PATRONAL(ccss, aguinaldo, cesantia, vacaciones, riesgos_trabajo_ins)
VALUES(24 , 8.33, 6.33, 4.16, 1.5 );

DROP TABLE VALORES_DEDUCCION;
CREATE TABLE VALORES_DEDUCCION(
	id_valores_deduccion SMALLINT AUTO_INCREMENT,
	id_valores_deduccion_obrero SMALLINT,
	id_valores_deduccion_patronal SMALLINT,
	vigente BIT,
    fecha_vigencia DATE,
    PRIMARY KEY(id_valores_deduccion),
    FOREIGN KEY (id_valores_deduccion_obrero) REFERENCES VALORES_DEDUCCION_OBRERO(id_valores_deduccion_obrero),
    FOREIGN KEY (id_valores_deduccion_patronal) REFERENCES VALORES_DEDUCCION_PATRONAL(id_valores_deduccion_patronal)
);


INSERT INTO VALORES_DEDUCCION(id_valores_deduccion_obrero, id_valores_deduccion_patronal, vigente, fecha_vigencia)
VALUES(1 , 1, 1, CAST(NOW() AS DATE));



DROP TABLE CALCULO_DEDUCCION;
CREATE TABLE CALCULO_DEDUCCION(
	id_calculo_deduccion INT AUTO_INCREMENT,
	id_empleado MEDIUMINT,
	id_valores_deduccion SMALLINT,
	salario_base DOUBLE,
	deduccion_obrero DOUBLE,
	deduccion_patronal DOUBLE,
	impuesto_de_renta DOUBLE,
	contribucion_asociacion_solidarista DOUBLE,
    fecha_calculado DATE,
    PRIMARY KEY(id_calculo_deduccion),
    FOREIGN KEY (id_empleado) REFERENCES EMPLEADOS(id_empleado),
    FOREIGN KEY (id_valores_deduccion) REFERENCES VALORES_DEDUCCION(id_valores_deduccion)
);


/*---------------------------------------------------------------------------------------------------------------*/ 
/*----------------------------------- PROCEDIMIENTOS DE CÁLCULO DE PLANILLA -------------------------------------*/
/*---------------------------------------------------------------------------------------------------------------*/ 

DELIMITER //
CREATE PROCEDURE SP_CalcularPlanilla ()
BEGIN
    
	SELECT 
				valores.id_valores_deduccion,
				deduccion_patronal.ccss,
				ROUND(deduccion_patronal.aguinaldo,2),
				ROUND(deduccion_patronal.cesantia,2),
				ROUND(deduccion_patronal.vacaciones,2),
				deduccion_patronal.riesgos_trabajo_ins,
				deduccion_obrero.ccss,
				deduccion_obrero.banco_popular
		INTO
				@id_valores_deduccion,
                @ccss_patronal,
                @aguinaldo,
                @cesantia,
                @vacaciones,
                @riesgos_trabajo_ins,
                @ccss_obrero,
                @banco_popular
		FROM VALORES_DEDUCCION valores
		INNER JOIN VALORES_DEDUCCION_OBRERO deduccion_obrero ON deduccion_obrero.id_valores_deduccion_obrero = valores.id_valores_deduccion_obrero
		INNER JOIN VALORES_DEDUCCION_PATRONAL deduccion_patronal ON deduccion_patronal.id_valores_deduccion_patronal = valores.id_valores_deduccion_patronal
		WHERE valores.vigente = 1;
	
    SET @total_deducciones_obrero = @ccss_obrero + @banco_popular;
    SET @total_deducciones_patronales = ROUND(@ccss_patronal + @aguinaldo + @cesantia + @vacaciones + @riesgos_trabajo_ins,2);
    
    
    INSERT INTO CALCULO_DEDUCCION(id_empleado,
								id_valores_deduccion,
								salario_base,
								deduccion_obrero,
								deduccion_patronal,
								impuesto_de_renta,
								contribucion_asociacion_solidarista,
								fecha_calculado)
	SELECT emp.id_empleado
			,@id_valores_deduccion
            ,emp.salario_actual
            ,(emp.salario_actual * (@total_deducciones_obrero/ 100))
            ,(emp.salario_actual * (@total_deducciones_patronales/ 100))
            ,FN_CalcularImpuestoRenta(emp.salario_actual)
            ,(emp.salario_actual * (emp.porcentaje_asociacion / 100))
            ,CAST(NOW() AS DATE)
    FROM EMPLEADOS emp
    WHERE emp.empleado_activo = 1;

END //


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
			SET impuesto_linea = (v_derecha-v_izquierda) * (v_porcentaje / 100);
        END IF;
        
        SET impuesto_total = impuesto_total + impuesto_linea;
        
	  END LOOP get_rangos;

	  CLOSE rangos_cursor;
      
    RETURN impuesto_total;
END//

SELECT FN_CalcularImpuestoRenta(11658757);



CALL SP_CalcularPlanilla();
SELECT cOUNT(*) FROM CALCULO_DEDUCCION;



SELECT TABLE_NAME AS `Table`,
 ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024) AS `Size (MB)`
FROM
 information_schema.TABLES
WHERE
 TABLE_SCHEMA = "calculadora_deducciones"
ORDER BY
 (DATA_LENGTH + INDEX_LENGTH)
DESC;
  
  