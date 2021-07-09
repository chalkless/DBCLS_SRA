DROP TABLE IF EXISTS sum_expWK;
CREATE TABLE sum_expWK(
	RP varchar(12) primary key,
	summary integer
);
CREATE TABLE IF NOT EXISTS sum_exp(
        RP varchar(12) primary key,
        summary integer
);
insert into sum_expWK(RP,summary) select RP,count(*) from study_expWK group by RP; 

DROP TABLE IF EXISTS sum_runWK;
CREATE TABLE sum_runWK(
	RP varchar(12) primary key,
	summary integer
);
CREATE TABLE IF NOT EXISTS sum_run(
        RP varchar(12) primary key,
        summary integer
);
insert into sum_runWK(RP,summary) select A.RP,count(*) from study_expWK A,exp_runWK B where A.RX = B.RX AND A.RA=B.RA  group by A.RP; 

DROP TABLE IF EXISTS sum_run2WK;
CREATE TABLE sum_run2WK(
	RX varchar(12) primary key,
	summary integer
);
CREATE TABLE IF NOT EXISTS sum_run2(
        RX varchar(12) primary key,
        summary integer
);
insert into sum_run2WK(RX,summary) select RX,count(*) from exp_runWK group by RX; 

DROP TABLE IF EXISTS study_typeWK;
CREATE TABLE study_typeWK(
	id integer auto_increment primary key,
	typetext text
);
CREATE TABLE IF NOT EXISTS study_type(
        id integer auto_increment primary key,
        typetext text
);


insert into study_typeWK(typetext) values('Transcriptome Analysis');
insert into study_typeWK(typetext) values('Metagenomics');
insert into study_typeWK(typetext) values('Epigenetics');
insert into study_typeWK(typetext) values('Resequencing');
insert into study_typeWK(typetext) values('Gene Regulation Study');
insert into study_typeWK(typetext) values('Population Genomics');
insert into study_typeWK(typetext) values('RNASeq');
insert into study_typeWK(typetext) values('Cancer Genomics');
insert into study_typeWK(typetext) values('Forensic or Paleo-genomics');
insert into study_typeWK(typetext) values('Synthetic Genomics');
insert into study_typeWK(typetext) values('Whole Genome Sequencing');
insert into study_typeWK(typetext) values('Other');
