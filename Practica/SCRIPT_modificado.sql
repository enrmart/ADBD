DROP TABLE SERVICIO CASCADE;
DROP TABLE INHUMACIONES CASCADE;
DROP TABLE TRASLADOS CASCADE;
DROP TABLE CESION_USO CASCADE;
DROP TABLE TASA CASCADE;
DROP TABLE OBRA CASCADE;
DROP TABLE SOLICITANTE CASCADE;
DROP TABLE UE CASCADE;
DROP TABLE BENEFICIARIO CASCADE;
/*DROP TABLE SUCESION;*/
DROP TABLE TITULAR CASCADE;
DROP TABLE TITULO CASCADE;
DROP TABLE FALLECIDO CASCADE;
DROP TYPE TIPO_UE CASCADE;
DROP TYPE TIPO_SERVI CASCADE;
DROP TYPE SEXO CASCADE;
DROP TYPE ESTADO_TITULO CASCADE;
DROP TYPE CONCEPTO_TASA CASCADE;
/*DROP TYPE TIPO_SUCESION;*/

CREATE TYPE TIPO_UE AS
ENUM('Panteon','Capilla','Sepultura','Nicho','Columbario','Osario');

CREATE TYPE TIPO_SERVI AS
ENUM('inhumación','exhumación','cremación','traslado','reduccion');

CREATE TYPE SEXO AS
ENUM('Varon','Mujer');

CREATE TYPE ESTADO_TITULO AS
ENUM('Extinto','Activo', 'Provisional');

CREATE TYPE CONCEPTO_TASA AS
ENUM('Obras','Título','Mantenimiento_UE','Servicio','ProrrogaCesionDeUso');

CREATE TYPE CARACTER_TITULO AS
ENUM('Testamentario','Intestado','Gratuito');

CREATE TABLE UE(
  id_unidad           INTEGER NOT NULL,
  tipo_ue             TIPO_UE NOT NULL,
  departamentos       INTEGER NOT NULL,
  localizacion        VARCHAR NOT NULL,
  fecha_construccion     DATE,
  unidad_predecesora  INTEGER,
  fecha_concesion     DATE NOT NULL,
  primary key(id_Unidad),
  foreign key(unidad_predecesora) references UE
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  constraint CHK_pantYcap CHECK ((tipo_ue = 'Capilla' and unidad_predecesora is NULL)
                                or(tipo_ue = 'Panteon' and unidad_predecesora is NULL))
);

CREATE TABLE BENEFICIARIO(
  nif_beneficiario      CHAR(9) NOT NULL,
  nombre                          VARCHAR,
  apellidos                       VARCHAR,
  domicilio                       VARCHAR,
  beneficiario_sustituto          CHAR(9),
  primary key(nif_beneficiario)
);

CREATE TABLE TITULAR(
  nif_titular           CHAR(9) NOT NULL,
  nombre                         VARCHAR,
  apellidos                      VARCHAR,
  domicilio                      VARCHAR,
  fecha_nacimiento                  DATE,
  primary key(nif_titular),
  constraint CHK_titular CHECK ((DATE_PART('year',CURRENT_DATE)-DATE_PART('year',fecha_nacimiento)) >= 18 )
);

CREATE TABLE TITULO(
  id_titulo           INTEGER NOT NULL,
  id_unidad           INTEGER NOT NULL,
  nif_beneficiario    CHAR(9),
  nif_titular         CHAR(9) NOT NULL,
  fecha_adjudicacion  DATE NOT NULL,
  caracter_adjudicacion CARACTER_TITULO NOT NULL,
  estado_titulo       ESTADO_TITULO,
  primary key (id_titulo),
  foreign key (id_unidad) references UE(id_unidad),
  foreign key (nif_beneficiario) references BENEFICIARIO,
  foreign key (nif_titular) references TITULAR
);

CREATE TABLE OBRA(
  id_unidad         INTEGER NOT NULL,
  licencia          INTEGER NOT NULL,
  fecha_inicio                  DATE,
  fecha_fin                     DATE,
  primary key (id_Unidad,licencia),
  foreign key (id_Unidad) references UE
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

CREATE TABLE FALLECIDO(
  nif_fallecido        CHAR(9) NOT NULL,
  id_titulo            INTEGER NOT NULL,
  nombre                        VARCHAR,
  apellidos                     VARCHAR,
  sexo                              BIT,
  domicilio                     VARCHAR,
  lugar_fallecimiento           VARCHAR,
  fecha_defuncion           TIMESTAMPTZ,
  primary key (nif_fallecido),
  foreign key (id_titulo) references TITULO(id_titulo),
  constraint CHK_defun48 CHECK((DATE_PART('hour',fecha_defuncion)-DATE_PART('hour',CURRENT_DATE))<=48),
  constraint CHK_defun24 CHECK((DATE_PART('hour',fecha_defuncion)-DATE_PART('hour',CURRENT_DATE))>=24)
);

CREATE TABLE SOLICITANTE(
  nif_solicitante     CHAR(9) NOT NULL,
  nombre              VARCHAR,
  apellidos           VARCHAR,
  direccion           VARCHAR,
  primary key (nif_solicitante)
);

CREATE TABLE SERVICIO(
  id_servicio       INTEGER NOT NULL UNIQUE,
  nif_solicitante   CHAR(9) NOT NULL,
  id_unidad         INTEGER NOT NULL,
  nif_fallecido      CHAR(9) NOT NULL,
  fecha        TIMESTAMPTZ NOT NULL,
  certificado       BIT NOT NULL,
  parte_anatomica   VARCHAR,
  tipo_servicio     TIPO_SERVI,
  primary key(id_servicio),
  foreign key(id_unidad) references UE
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  foreign key(nif_solicitante) references SOLICITANTE,
  foreign key(nif_fallecido) references FALLECIDO
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

CREATE TABLE INHUMACIONES(
  id_servicio INTEGER NOT NULL,
  ubicacion VARCHAR,
  hora TIME,
  primary key(id_servicio),
  foreign key(id_servicio) references SERVICIO(id_servicio)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

CREATE TABLE TRASLADOS(
  id_servicio INTEGER NOT NULL,
  ubicacion_origen VARCHAR,
  ubicacion_destino VARCHAR,
  primary key(id_servicio),
  foreign key(id_servicio) references SERVICIO(id_servicio)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

CREATE TABLE CESION_USO(
  id_titulo               INTEGER NOT NULL,
  fecha_vencimiento       DATE NOT NULL,
  anualidad               BIT,
  primary key(id_titulo, fecha_vencimiento),
  foreign key(id_Titulo) references TITULO
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE TASA(
  id_tasa              INTEGER NOT NULL,
  nif_titular          CHAR(9) NOT NULL,
  fecha_vencimiento    DATE NOT NULL,
  pago                 DOUBLE PRECISION,
  concepto             CONCEPTO_TASA,
  primary key (id_tasa),
  foreign key (nif_titular) references TITULAR
);


/*UE-----------------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(1,'Nicho',1,'Sector: 3, parcela: 1','2013-05-27', NULL, '2013-07-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(2,'Panteon',1,'Sector: 8, Parcela: 4','2013-08-20', NULL, '2013-10-03');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(3,'Capilla',5,'Sector: 2, Parcela: 3','2014-05-27', NULL, '2014-10-11');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(4,'Nicho',1,'Sector: 6, Parcela: 7','2014-08-20', 3, '2014-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(5,'Nicho',1,'Sector: 5, Parcela: 2','2015-01-10', 3, '2015-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(6,'Sepultura',3,'Sector: 4, Parcela: 6','2016-09-05', 3, '2016-10-31');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(7,'Columbario',8,'Sector: 1, Parcela: 5','2017-03-19', NULL, '2017-04-11');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(8,'Capilla',10,'Sector: 9, Parcela: 9','2018-01-02', NULL, '2018-02-17');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(9,'Osario',50,'Sector: 7, Parcela: 8','2018-06-15', NULL, '2018-08-07');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(10,'Panteon',6,'Sector: 10, Parcela: 1','2018-12-24', NULL, '2019-01-13');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(11,'Nicho',1,'Sector: 10, Parcela: 1','2019-08-20', 10, '2019-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(12,'Nicho',1,'Sector: 10, Parcela: 1','2019-08-21', 10, '2019-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(13,'Nicho',1,'Sector: 10, Parcela: 1','2019-08-21', 10, '2019-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(14,'Nicho',1,'Sector: 10, Parcela: 1','2019-08-22', 10, '2019-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(15,'Nicho',1,'Sector: 10, Parcela: 1','2019-08-23', 10, '2019-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad predecesora, fecha_concesion)
VALUES(16,'Nicho',1,'Sector: 10, Parcela: 1','2019-08-23', 10, '2019-12-27');



/*TITULO-------------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(1,1,'25755093A','25765093A','2013-08-10','Gratuito','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(1,2,'19611258B','19611257B','2013-11-01','Intestado','Caducado');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(1,3,'13948179A','13948177C','2014-12-20','Gratuito','Extinto');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(2,4,'41398187D','41398187D','2015-01-10','Testamentario','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(3,5,'44510026A','44510027C','2015-04-29','Testamentario','Activo');


INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(4,7,'42580381A','42580387A','2017-04-11','Gratuito','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(5,11,'62450345B','62450345B','2019-12-17','Intestado','Caducado');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(6,12,'90988626A','90988624C','20-12-20','Gratuito','Extinto');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(7,13,'22072112D','22072110D','2019-12-30','Testamentario','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(8,10,'60929356A','22072110C','2020-02-24','Testamentario','Activo');

/*TITULAR------------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('25755093A','Antonio','Antunez Gómez','Palencia','1985-05-08');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('19611257B','Benito','Benitez Perez','Palencia','1965-02-19');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('13948177C','Carlos','Coronado','Palencia','1979-04-29');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('41398187D','Daniel','Delgado','Palencia','1982-09-02');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('44510027C','Antonio','Antunez','Palencia','1985-05-08');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('42580387A','Benito','Benitez','Palencia','1965-02-19');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('62450345B','Carlos','Coronado','Palencia','1979-04-29');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('90988624C','Daniel','Delgado','Palencia','1982-09-02');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('22072110D','Alejandro','Lopez','Palencia','1982-09-02');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('22072110C','Daniel','Delgado','Palencia','1982-09-02');

/*BENEFICIARIO-------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO BENEFICIARIO(nif_benficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('11111112A','Antonio','Benifacio', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_benficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('22222223B','Benito','Benifacio', 'Palencia', '11111112A');

INSERT INTO BENEFICIARIO(nif_benficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('33333334A','Carlos','Benifacio', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_benficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('44444445D','Daniel','Benifacio', 'Palencia', NULL)


/*OBRA----------------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(2,718,'2013-01-22','2013-08-20');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(3,769,'2013-12-19','2014-05-27');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(8,980,'2017-08-24','2018-01-02');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(12,1094,'2019-07-06','2019-09-30');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(10,1254,'2020-05-24','2020-06-13');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(11,1805,'2021-03-12','2021-03-14');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(11,1900,'2022-05-12','2022-06-09');

/*FALLECIDO-----------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO FALLECIDO(nif_fallecido,id_titulo,nombre,apellidos,sexo,domicilio,lugar_fallecimiento,fecha_defuncion)
VALUES('19611257B',1,'Benito','Benitez Perez','Varon','Palencia','Palencia', '2013-10-03');

INSERT INTO FALLECIDO(nif_fallecido,id_titulo,nombre,apellidos,sexo,domicilio,lugar_fallecimiento,fecha_defuncion)
VALUES('62450345B',1,'Benito','Benitez Perez','Varon','Palencia','Palencia', '2013-10-03');

INSERT INTO FALLECIDO(nif_fallecido,id_titulo,nombre,apellidos,sexo,domicilio,lugar_fallecimiento,fecha_defuncion)
VALUES('62450345B',1,'Benito','Benitez Perez','Varon','Palencia','Palencia', '2013-10-03');

/*SERVICIOS-----------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(1,'25755093A',2,'', ,'2013-08-20', NULL, '2013-10-03');

/*TASAS----------------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(1,'19611258B','2013-12-06',1,'Título');

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(2,'60929356A','2013-08-20',1,'Obras');

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(3,'60929356A','2014-05-27',1,'Obras');

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(4,'41398187D','2015-01-12',1,'Título');

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(5,'44510026A','2015-05-29',1,'Título');

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(6,'60929356A','2018-01-02',1,'Obras');

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(7,'60929356A','2019-10-31',1,'Obras');

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(8,'62450345B','2019-12-27',1,'Título');

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(9,'22072112D','2020-1-25',1,'Título');

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(10,'60929356A','2020-06-13',1,'Obras');

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(11,'60929356A','2020-05-30',1,'Título');

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(12,'60929356A','2021-03-14',1,'Obras');

INSERT INTO TASA(id_tasa,nif_titular,fecha_vencimiento,pago,concepto)
VALUES(13,'60929356A','2022-06-09',1,'Obras');





