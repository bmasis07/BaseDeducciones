
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













SELECT TABLE_NAME AS `Table`,
 ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024) AS `Size (MB)`
FROM
 information_schema.TABLES
WHERE
 TABLE_SCHEMA = "calculadora_deducciones"
ORDER BY
 (DATA_LENGTH + INDEX_LENGTH)
DESC;
  
  