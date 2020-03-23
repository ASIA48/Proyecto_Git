USE MASTER
GO
--EXEC sp_configure filestream_access_level, 2
--RECONFIGURE
--GO
DROP DATABASE IF EXISTS Liga_Futbol_Fem
go
CREATE DATABASE Liga_Futbol_Fem
ON PRIMARY
(
    NAME = Liga_Futbol_Fem_data,
    FILENAME = 'C:\Proyecto\Liga_Futbol_Fem.mdf'
),
FILEGROUP FileStreamFG CONTAINS FILESTREAM
(
    NAME = Liga_Futbol_Fem_FileTable,
    FILENAME = 'C:\Proyecto\FileTable' 
)
LOG ON
(
    NAME = Liga_Futbol_Fem_log,
    FILENAME = 'C:\Proyecto\Log\Liga_Futbol_Fem_Log.ldf'
)
WITH FILESTREAM
(
    NON_TRANSACTED_ACCESS = FULL,
    DIRECTORY_NAME = 'Liga_Futbol_Fem'
);
GO
use Liga_Futbol_Fem
GO
------Creacion de FileTable
CREATE TABLE Imagenes_jugadoras 
AS FILETABLE
WITH 
(
    FileTable_Directory = 'FILESTREAM_Liga_Futbol_Fem',
    FileTable_Collate_Filename = database_default
);

--Una vez creado, darle click-derecho en la Filetable creada y pulsar en "Explore FileTable Directory".
--Esto nos abrirá una ruta en nuestra red compartida donde arrastraremos los ficheros que queramos que detecte la BBDD

-------Creacion de las tablas-------------

CREATE TABLE arbitro (
    cod_arb               INTEGER IDENTITY(1,1) NOT NULL,
    nom_arb               VARCHAR(80),
    ciudad_arb            VARCHAR(80),
    fech_nac_arb          DATE,
    imagenes_cod_imagen   INTEGER NOT NULL
);
ALTER TABLE arbitro ADD CONSTRAINT arbitro_pk PRIMARY KEY ( cod_arb );

CREATE TABLE clasificacion (
    cod_clasificacion   INTEGER IDENTITY(1,1) NOT NULL,
    equipo_cod_equipo   INTEGER NOT NULL,
    puntuacion          INTEGER,
    p_ganados           INTEGER,
    p_empatados         INTEGER,
    p_perdidos          INTEGER
)
;

ALTER TABLE clasificacion ADD CONSTRAINT clasificacion_pk PRIMARY KEY ( cod_clasificacion );

CREATE TABLE datos_partido_jug (
    jugadoras_cod_jug     INTEGER IDENTITY(1,1) NOT NULL,
    partido_num_partido   INTEGER NOT NULL,
    posicion_jug          VARCHAR(20),
    dorsal_jug            INTEGER,
    tarjeta_roja          SMALLINT,
    tarj_amari            SMALLINT,
    goles                 INTEGER
);

ALTER TABLE datos_partido_jug ADD CONSTRAINT datos_partido_jug_pk PRIMARY KEY ( jugadoras_cod_jug,
                                                                                partido_num_partido );

CREATE TABLE entrenador (
    cod_ent               INTEGER IDENTITY(1,1) NOT NULL,
    nom_ent               VARCHAR(80),
    ciudad_ent            VARCHAR(80),
    nacionalidad_ent      VARCHAR(80),
    fech_nac_ent          DATE,
    fech_alta_ent         DATE,
    equipo_cod_equipo     INTEGER NOT NULL,
    imagenes_cod_imagen   INTEGER NOT NULL
);

CREATE UNIQUE INDEX entrenador__idx ON
    entrenador (
        equipo_cod_equipo
    ASC );

ALTER TABLE entrenador ADD CONSTRAINT entrenador_pk PRIMARY KEY ( cod_ent );

CREATE TABLE equipo (
    cod_equipo            INTEGER IDENTITY(1,1) NOT NULL,
    nom_equipo            VARCHAR(80),
    ciudad_equipo         VARCHAR(80),
    fech_creacion         DATE,
    imagenes_cod_imagen   INTEGER NOT NULL,
    liga_cod_liga         INTEGER NOT NULL
);

ALTER TABLE equipo ADD CONSTRAINT equipo_pk PRIMARY KEY ( cod_equipo );
CREATE TABLE estadio (
    cod_estadio         INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED,
    nom_estadio         VARCHAR(80),
    aforo_estadio       INTEGER,
    ubicación_est       VARCHAR(80),
    fech_construccion   DATE
);	
CREATE TABLE imagenes (
    cod_imagen   INTEGER IDENTITY(1,1) NOT NULL,
    id_img       UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE  
--  WARNING: CHAR size not specified 
    ,
    imagen       VARBINARY(MAX) FILESTREAM
);

ALTER TABLE imagenes ADD CONSTRAINT imagenes_pk PRIMARY KEY ( cod_imagen );

CREATE TABLE jugadoras (
    cod_jug               INTEGER IDENTITY(1,1) NOT NULL,
    nom_jug               VARCHAR(80),
    ciudad_jug            VARCHAR(80),
    nacionalidad          VARCHAR(80),
    fech_nac_jug          DATE,
    fech_alta_jug         DATE,
    altura                INTEGER,
    peso                  INTEGER,
    equipo_cod_equipo     INTEGER NOT NULL,
    imagenes_cod_imagen   INTEGER NOT NULL
);

ALTER TABLE jugadoras ADD CONSTRAINT jugadoras_pk PRIMARY KEY ( cod_jug );

CREATE TABLE liga (
    cod_liga            INTEGER IDENTITY(1,1) NOT NULL,
    nombre_liga         VARCHAR(80),
    nivel_liga          VARCHAR(80)
);

ALTER TABLE liga ADD CONSTRAINT liga_pk PRIMARY KEY ( cod_liga );

CREATE TABLE partido (
    num_partido           INTEGER IDENTITY(1,1) NOT NULL,
    fecha_partido         DATE,
    n_gol_e1              INTEGER,
    n_gol_e2              INTEGER,
    resultado             VARCHAR(20),
    equipo_cod_equipo     INTEGER NOT NULL,
    equipo_cod_equipo1    INTEGER NOT NULL,
    arbitro_cod_arb       INTEGER NOT NULL,
    estadio_cod_estadio   INTEGER NOT NULL
);

ALTER TABLE partido ADD CONSTRAINT partido_pk PRIMARY KEY ( num_partido );

ALTER TABLE arbitro
    ADD CONSTRAINT arbitro_imagenes_fk FOREIGN KEY ( imagenes_cod_imagen )
        REFERENCES imagenes ( cod_imagen );

ALTER TABLE clasificacion
    ADD CONSTRAINT clasificacion_equipo_fk FOREIGN KEY ( equipo_cod_equipo )
        REFERENCES equipo ( cod_equipo );

ALTER TABLE datos_partido_jug
    ADD CONSTRAINT datos_partido_jug_jugadoras_fk FOREIGN KEY ( jugadoras_cod_jug )
        REFERENCES jugadoras ( cod_jug );

ALTER TABLE datos_partido_jug
    ADD CONSTRAINT datos_partido_jug_partido_fk FOREIGN KEY ( partido_num_partido )
        REFERENCES partido ( num_partido );

ALTER TABLE entrenador
    ADD CONSTRAINT entrenador_equipo_fk FOREIGN KEY ( equipo_cod_equipo )
        REFERENCES equipo ( cod_equipo );

ALTER TABLE entrenador
    ADD CONSTRAINT entrenador_imagenes_fk FOREIGN KEY ( imagenes_cod_imagen )
        REFERENCES imagenes ( cod_imagen );

ALTER TABLE equipo
    ADD CONSTRAINT equipo_imagenes_fk FOREIGN KEY ( imagenes_cod_imagen )
        REFERENCES imagenes ( cod_imagen );

ALTER TABLE equipo
    ADD CONSTRAINT equipo_liga_fk FOREIGN KEY ( liga_cod_liga )
        REFERENCES liga ( cod_liga );

ALTER TABLE jugadoras
    ADD CONSTRAINT jugadoras_equipo_fk FOREIGN KEY ( equipo_cod_equipo )
        REFERENCES equipo ( cod_equipo );

ALTER TABLE jugadoras
    ADD CONSTRAINT jugadoras_imagenes_fk FOREIGN KEY ( imagenes_cod_imagen )
        REFERENCES imagenes ( cod_imagen );

ALTER TABLE partido
    ADD CONSTRAINT partido_arbitro_fk FOREIGN KEY ( arbitro_cod_arb )
        REFERENCES arbitro ( cod_arb );

ALTER TABLE partido
    ADD CONSTRAINT partido_equipo_fk FOREIGN KEY ( equipo_cod_equipo )
        REFERENCES equipo ( cod_equipo );

ALTER TABLE partido
    ADD CONSTRAINT partido_equipo_fkv2 FOREIGN KEY ( equipo_cod_equipo1 )
        REFERENCES equipo ( cod_equipo );

ALTER TABLE partido
    ADD CONSTRAINT partido_estadio_fk FOREIGN KEY ( estadio_cod_estadio )
        REFERENCES estadio ( cod_estadio );