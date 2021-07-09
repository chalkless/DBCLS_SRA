DROP TABLE IF EXISTS RSS;
CREATE TABLE RSS (
	id integer auto_increment primary key,
	RA varchar(9),
	RP varchar(9),
	STUDY_TITLE text,
	STUDY_TYPE text,
	UPDATE_DATE Datetime,
	TAXON_ID integer,
	SCIENTIFIC_NAME text,
	COMMON_NAME text,
	PLATFORM text,
	RSS text
	);

