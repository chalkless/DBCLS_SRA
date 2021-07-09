CREATE TABLE IF NOT EXISTS view_all (
	pmid int(11),
	article_title text,
	journal tinytext,
	vol varchar(20),
	issue varchar(20),
	page varchar(20),
	date varchar(15),
	sra_id_orig text,
	sra_id char(9),
	sra_title text,
	taxon_id int(11),
	platform text,
	study_type text
);

CREATE TABLE IF NOT EXISTS pmid2sra (
	pmid varchar(8),
	sra_id char(9)
);

CREATE TABLE IF NOT EXISTS pmid2sra2 (
	pmid varchar(8),
	sra_id char(9),
	sra_id_orig char(9)
);

CREATE TABLE IF NOT EXISTS article (
	pmid varchar(8),
	title text,
	journal tinytext,
	vol varchar(20),
	issue varchar(20),
	page varchar(20),
	date varchar(15)
);
