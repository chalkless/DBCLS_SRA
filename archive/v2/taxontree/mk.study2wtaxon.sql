CREATE TABLE IF NOT EXISTS study2wtaxon (
       id int(11),
       RA varchar(9),
       RP varchar(9),
       STUDY_TITLE text,
       STUDY_TYPE text,
       UPDATE_DATE datetime,
       TAXON_ID varchar(11),
       TREE_ID varchar(400),
       SCIENTIFIC_NAME text,
       COMMON_NAME text,
       PLATFORM text
);

INSERT INTO study2wtaxon
select A.id,
       A.RA, 
       A.RP, 
       A.STUDY_TITLE, 
       A.STUDY_TYPE, 
       A.UPDATE_DATE, 
       A.TAXON_ID, 
       B.TREE_ID, 
       A.SCIENTIFIC_NAME, 
       A.COMMON_NAME, 
       A.PLATFORM 
    from study2 A left join taxonomy_tree B
    on A.TAXON_ID = B.taxon_id;
