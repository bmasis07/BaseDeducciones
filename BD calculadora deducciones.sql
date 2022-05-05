
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