-- TAXONOMY 
DROP TABLE IF EXISTS taxidWK;
CREATE TABLE taxidWK (
	taxid integer primary key,
	scientific_name text
	);
CREATE TABLE IF NOT EXISTS taxid (
        taxid integer primary key,
        scientific_name text
        );
LOAD DATA INFILE '/tmp/scientificname' INTO TABLE taxidWK FIELDS TERMINATED BY '\t|\t';

-- relations
DROP TABLE IF EXISTS study_expWK;
CREATE TABLE study_expWK (
	RA varchar(12),
	RP varchar(12),
	RX varchar(12), 
	primary key(RA,RP,RX)
	);
CREATE TABLE IF NOT EXISTS study_exp (
        RA varchar(12),
        RP varchar(12),
        RX varchar(12),
        primary key(RA,RP,RX)
        );

DROP TABLE IF EXISTS study_sampleWK;
CREATE TABLE study_sampleWK (
	RA varchar(12),
	RP varchar(12),
	RS varchar(12), 
	primary key(RA,RP,RS)
	);
CREATE TABLE IF NOT EXISTS study_sample (
        RA varchar(12),
        RP varchar(12),
        RS varchar(12),
        primary key(RA,RP,RS)
        );

DROP TABLE IF EXISTS exp_sampleWK;
CREATE TABLE exp_sampleWK (
	RA varchar(12),
	RX varchar(12),
	RS varchar(12), 
	primary key(RA,RX,RS)
	);
CREATE TABLE IF NOT EXISTS exp_sample (
        RA varchar(12),
        RX varchar(12),
        RS varchar(12),
        primary key(RA,RX,RS)
        );

DROP TABLE IF EXISTS exp_runWK;
CREATE TABLE exp_runWK (
	RA varchar(12),
	RX varchar(12),
	RR varchar(12), 
	primary key(RA,RX,RR)
	);
CREATE TABLE IF NOT EXISTS exp_run (
        RA varchar(12),
        RX varchar(12),
        RR varchar(12),
        primary key(RA,RX,RR)
        );

-- experiment
DROP TABLE IF EXISTS experimentWK;
CREATE TABLE experimentWK (
	RA varchar(12),
	RX varchar(12) primary key,
	TITLE text,
	PLATFORM text
	);
CREATE TABLE IF NOT EXISTS experiment (
        RA varchar(12),
        RX varchar(12) primary key,
        TITLE text,
        PLATFORM text
        );

-- sample
DROP TABLE IF EXISTS sampleWK;
CREATE TABLE sampleWK (
	RA varchar(12),
	RS varchar(12) primary key,
	TITLE text,
	DESCRIPTION text,
	TAXON_ID text,
	COMMON_NAME text
	);
CREATE TABLE IF NOT EXISTS sample (
        RA varchar(12),
        RS varchar(12) primary key,
        TITLE text,
        DESCRIPTION text,
        TAXON_ID text,
        COMMON_NAME text
        );

-- submission
DROP TABLE IF EXISTS submissionWK;
CREATE TABLE submissionWK (
	RA varchar(12) primary key,
	UPDATE_DATE Datetime
	);
CREATE TABLE IF NOT EXISTS submission (
        RA varchar(12) primary key,
        UPDATE_DATE Datetime
        );

-- study
DROP TABLE IF EXISTS studyWK;
CREATE TABLE studyWK (
	RA varchar(12),
	RP varchar(12) primary key,
	STUDY_TITLE text,
	STUDY_TYPE text,
	UPDATE_DATE Datetime
	);
CREATE TABLE IF NOT EXISTS study (
        RA varchar(12),
        RP varchar(12) primary key,
        STUDY_TITLE text,
        STUDY_TYPE text,
        UPDATE_DATE Datetime
        );

-- size
DROP TABLE IF EXISTS sizeWK;
CREATE TABLE sizeWK (
	RA varchar(12),
	RX varchar(12),
	SIZE integer,
	primary key(RA,RX)
	);
CREATE TABLE IF NOT EXISTS size (
        RA varchar(12),
        RX varchar(12),
        SIZE integer,
        primary key(RA,RX)
        );

DROP TABLE IF EXISTS RSSWK;
CREATE TABLE RSSWK (
	id integer auto_increment primary key,
	RA varchar(12),
	RP varchar(12),
	STUDY_TITLE text,
	STUDY_TYPE text,
	UPDATE_DATE Datetime,
	TAXON_ID integer,
	SCIENTIFIC_NAME text,
	COMMON_NAME text,
	PLATFORM text,
	RSS text
	);
CREATE TABLE IF NOT EXISTS RSS (
        id integer auto_increment primary key,
        RA varchar(12),
        RP varchar(12),
        STUDY_TITLE text,
        STUDY_TYPE text,
        UPDATE_DATE Datetime,
        TAXON_ID integer,
        SCIENTIFIC_NAME text,
        COMMON_NAME text,
        PLATFORM text,
        RSS text
        );


