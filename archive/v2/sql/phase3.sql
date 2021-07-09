DROP TABLE IF EXISTS experiment2WK;
CREATE TABLE experiment2WK (
	RP varchar(12),
	RX varchar(12),
	TITLE text,
	RS varchar(12),
	SAMPLES text,
	DESCRIPTION text,
	TAXON_ID integer,
	COMMON_NAME text,
	RA varchar(12),
	PLATFORM text
	);
CREATE TABLE IF NOT EXISTS experiment2 (
        RP varchar(12),
        RX varchar(12),
        TITLE text,
        RS varchar(12),
        SAMPLES text,
        DESCRIPTION text,
        TAXON_ID integer,
        COMMON_NAME text,
        RA varchar(12),
        PLATFORM text
        );
INSERT INTO experiment2WK select B.RP,A.RX,A.TITLE,E.RS,E.TITLE,E.DESCRIPTION,E.TAXON_ID,E.COMMON_NAME,B.RA,A.PLATFORM from  experimentWK A left outer join study_expWK B on (A.RX=B.RX AND A.RA=B.RA) left outer join exp_sampleWK D on (A.RX=D.RX AND A.RA=D.RA) left outer join sampleWK E on (D.RS=E.RS);

DROP TABLE IF EXISTS experiment3WK;
CREATE TABLE experiment3WK (
	RP varchar(12),
	RX varchar(12),
	TITLE text,
	RS varchar(12),
	TAXON_ID integer,
	SCIENTIFIC_NAME text,
	COMMON_NAME text,
	WORD text,
	SAMPLES text,
	DESCRIPTION text,
	RUNS integer,
	RA varchar(12),
	PLATFORM text,
	SIZE integer
	);
CREATE TABLE IF NOT EXISTS experiment3 (
        RP varchar(12),
        RX varchar(12),
        TITLE text,
        RS varchar(12),
        TAXON_ID integer,
        SCIENTIFIC_NAME text,
        COMMON_NAME text,
        WORD text,
        SAMPLES text,
        DESCRIPTION text,
        RUNS integer,
        RA varchar(12),
        PLATFORM text,
        SIZE integer
        );

INSERT INTO experiment3WK select A.RP,A.RX,coalesce(A.TITLE,'&lt;NO DATA&gt;') as TITLE,A.RS,A.TAXON_ID,coalesce(C.scientific_name,'&lt;NO DATA&gt;') as scientific_name,coalesce(A.COMMON_NAME,'&lt;NO DATA&gt;') as COMMON_NAME,coalesce(A.SAMPLES,concat('<DESCRIPTION>',A.DESCRIPTION),'&lt;NO DATA&gt;') as WORD,A.SAMPLES,A.DESCRIPTION,B.summary,A.RA,A.PLATFORM,coalesce(D.SIZE,0) from experiment2WK A left join sum_run2WK B on (A.RX = B.RX) left join taxidWK C on (A.TAXON_ID = C.taxid) left join sizeWK D on (A.RX=D.RX AND A.RA=D.RA) ;

DROP TABLE IF EXISTS study2WK;
CREATE TABLE study2WK (
	id integer auto_increment primary key,
	RA varchar(12),
	RP varchar(12),
	STUDY_TITLE text,
	STUDY_TYPE text,
	UPDATE_DATE Datetime,
	TAXON_ID integer,
	SCIENTIFIC_NAME text,
	COMMON_NAME text,
	PLATFORM text
	);
CREATE TABLE IF NOT EXISTS study2 (
        id integer auto_increment primary key,
        RA varchar(12),
        RP varchar(12),
        STUDY_TITLE text,
        STUDY_TYPE text,
        UPDATE_DATE Datetime,
        TAXON_ID integer,
        SCIENTIFIC_NAME text,
        COMMON_NAME text,
        PLATFORM text
        );

INSERT INTO study2WK(RA,RP,STUDY_TITLE,STUDY_TYPE,UPDATE_DATE,TAXON_ID,SCIENTIFIC_NAME,COMMON_NAME,PLATFORM) select distinct A.RA,A.RP,A.STUDY_TITLE,A.STUDY_TYPE,A.UPDATE_DATE,B.TAXON_ID,B.SCIENTIFIC_NAME,B.COMMON_NAME,B.PLATFORM from studyWK A left outer join experiment3WK B on (A.RP = B.RP);
