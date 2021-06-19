- https://ftp.ncbi.nlm.nih.gov/sra/reports/Metadata/ にメタデータやSRA_Accessions.tabが置かれている。

```
NCBI_SRA_Metadata_20210608.tar.gz      2021-06-08 12:50  2.1G
...

NCBI_SRA_Metadata_Full_20210603.tar.gz 2021-06-04 10:58  5.1G  
SRA_Accessions.tab                     2021-06-08 12:50   10G
...
```
- Fullあり/なしの違いはよくわからないが、Fullでないと全部入っていないようだ
- しかし、Fullをほどくと90GBくらいになる。。。（ファイル数が多すぎてlsすらなかなか返ってこない）
```
1. Accession
2. Submission
3. Status
4. Updated
5. Published
6. Received
7. Type
8. Center
9. Visibility
10. Alias
11. Experiment
12. Sample
13. Study
14. Loaded
15. Spots
16. Bases
17. Md5sum
18. BioSample
19. BioProject
20. ReplacedBy
```
cutコマンドだと列の入れ替えができないのでawkで
```
$ awk -F"       " '{print $2 "  " $13 " " $12}' /share/data/sra_meta/Metadata/SRA_Accessions.tab | grep -v "-"|grep "^.RA" | uniq > SRA.APS.210610.tab
$ awk -F"       " '{print $2 "  " $13 " " $11}' /share/data/sra_meta/Metadata/SRA_Accessions.tab | grep -v "-"|grep "^.RA" | uniq > SRA.APX.210610.tab
$ awk -F"       " '{print $2 "  " $11 " " $12}' /share/data/sra_meta/Metadata/SRA_Accessions.tab | grep -v "-"|grep "^.RA" | uniq > SRA.AXS.210610.tab
$ grep ^.RR /share/data/sra_meta/Metadata/SRA_Accessions.tab| awk -F"   " '{print $2 "  " $11 " " $1}' | grep -v "-"|grep "^.RA" | uniq > SRA.AXR.210610.tab
```

```
ln -s SRA.APS.210610.tab study_expWK.tab
...
ln -s SRA.AXR.210610.tab exp_runWK.tab
```

```
$ mysql -u sra -p -b sra < ./sql/phase1.sql
```

```
...
$ mysqlimport -u sra -p --local --delete sra exp_runWK.tab
```
Experimentが11桁になっていたり、RUNやSAMPLEが12桁になっていたり。

```
$ mysql -u sra -p -b sra < ./sql/phase2.sql
```
```
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
```
見直ししたい



study/exp/run/sample/submissionのparse

submissionのparseはupdated/published/receivedとあるのでpublishedとupdated両方出したい
```
Accession       Submission      Status  Updated Published       Received       Type     Center  Visibility      Alias   Experiment      Sample  Study   Loaded Spots    Bases   Md5sum  BioSample       BioProject      ReplacedBy
DRA000001       DRA000001       live    2021-02-05T15:52:14Z    2010-03-24T03:10:22Z    2009-06-20T02:48:01Z    SUBMISSION      KEIO    public  DRA000001      -        -       -       -       -       -       247a10cb6254caa26f2ca64f49bc0271        -       -       -
DRP000001       DRA000001       live    2020-08-25T15:30:25Z    2015-07-31T15:20:44Z    2009-06-20T02:48:02Z    STUDY   KEIO    public  DRP000001       -      -        -       -       -       -       2072beecdd9e29f6cbd5903cff0de32c       -        PRJDA38027      -
DRR000001       DRA000001       live    2021-02-05T15:52:14Z    2010-03-24T03:10:22Z    2009-06-20T02:48:04Z    RUN     KEIO    public  2008-09-12.BEST195-Lane7        DRX000001       DRS000001       DRP000001       1       10148174       730668528        252bccb8e87c5a3010bead90ce5f5614        SAMD00016353    PRJDA38027      -
DRS000001       DRA000001       live    2015-03-26T21:32:35Z    2010-03-24T03:10:22Z    2009-06-20T02:48:03Z    SAMPLE  BioSample       public  SAMD00016353   -        -       -       -       -       -       764b0110478fa0755d9d81887339ce59        SAMD00016353    -       -
DRX000001       DRA000001       live    2015-01-30T13:21:34Z    2010-03-24T03:10:22Z    2009-06-20T02:48:03Z    EXPERIMENT      KEIO    public  DRX000001      -        DRS000001       DRP000001       -       -       -       1389579d7a3e83b5100ab5bd07e00873        SAMD00016353    PRJDA38027      -
DRA000002       DRA000002       live    2021-02-12T21:15:54Z    2010-03-24T03:11:55Z    2009-08-04T07:37:02Z    SUBMISSION      KEIO    public  DRA000002      -        -       -       -       -       -       c4e77d833c5ac18a4dd8756fcb5dbead        -       -       -
```

```
$ ext.xml2tab.pl

print OUTSTUDY join("\t", $ra, $rp, $title, $type, $update)."\n" ...
print OUTEXP join("\t", $ra, $rp, $rx, $title, $platform)."\n" ...
print OUTSAMPLE join("\t", $ra, $rs, $name, $title, $desc, $taxon_id)."\n";

```




```
$ mysqlimport -u sra -p --local --delete sra update_manual/210610/studyWK.tab
$ mysqlimport -u sra -p --local --delete sra update_manual/210610/expWK.tab
$ mysqlimport -u sra -p --local --delete sra update_manual/210610/sampleWK.tab
```
```
$ grep ^.RA /share/data/sra_meta/Metadata/SRA_Accessions.tab | perl -F"\t" -lane '$F[4] =~ s/T.*//; print join("\t", $F[0], $F[4])' > submissionWK.tab
```
```
$ mysqlimport -u sra -p --local --delete sra update_manual/210610/submissionWK.tab
```

```
$ mysql -u sra -p -b sra < sql/phase3.sql
$ mysql -u sra -p -b sra < sql/fwd.sql
```



## 生物種によるSRAデータの検索...のためのデータ作成
- mk.study2wtaxon.sh
```
$ less mk.study2wtaxon.sql
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
```

- taxdump.tar.gz/taxcat.tar.gz を解凍（定期的にダウンロードしている?）
- taxonomyを処理: ext.node.pl/mk.tree.pl →　taxonomy.node.$DATE.tab/taxonomy.tree.$DATE.tab
```
print join("\t", $each_taxonid, $tree, $each_species, $each_annot)."\n";
66420   0000001:...::0066420 66420   Papilio xuthus  species Invertebrates
($id2annot{$taxon_id} = join("\t", $name, $rank, $group);)
```
- taxontree/taxonomy.tree.sqlでSQLにつっこむ
```
create table if not exists taxonomy_tree (
       taxon_id varchar(7),
       tree_id varchar(400),
       taxon_id_species varchar(7),
       taxon_name varchar(200),
       rank varchar(30),
       taxon_group varchar(30)
);

load data local infile 'taxonomy.tree.tab' replace into table taxonomy_tree;
```
- MySQL で study2テーブルをstudy2.tabに吐く
- mk.study2wtaxon.pl: taxonomy.tree.tab + study.tab →study2wtaxon.tab
- study2wtaxon.tab をSQLにつっこむ

- study2 テーブルは
  - fwd.sql でstudy2WKテーブルから名前変換
  - study2WK テーブルはphase3.sqlで作成
```
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
```
- studyWK + experiment3WK → study2K
- studyWK
```
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
INSERT INTO experiment3WK select A.RP,A.RX,coalesce(A.TITLE,'&lt;NO DATA&gt;') as TITLE,A.RS,A.TAXON_ID,coalesce(C.scientific_name,'&lt;NO DATA&gt;') as scientific_name,coalesce(A.COMMON_NAME,'&lt;NO DATA&gt;') as COMMON_NAME,coalesce(A.SAMPLES,concat('<DESCRIPTION>',A.DESCRIPTION),'&lt;NO DATA&gt;') as WORD,A.SAMPLES,A.DESCRIPTION,B.summary,A.RA,A.PLATFORM,coalesce(D.SIZE,0) from experiment2WK A left join sum_run2WK B on (A.RX = B.RX) left join taxidWK C on (A.TAXON_ID = C.taxid) left join sizeWK D on (A.RX=D.RX AND A.RA=D.RA) ;
```
- experiment2 + sum_run2WK + taxidWK + sizeWK → experiment3WK

- 出力
```
 var columns = [
    {key: "ra",  label: "SRA ID", sortable: true, formatter: YAHOO.widget.DataTable.formatLink1 },
    {key: "rp",  label: "Study ID", sortable: true, formatter: YAHOO.widget.DataTable.formatLink2 },
    {key: "study_title",    label: "Study Title",     sortable: true},
    {key: "study_type",     label: "Study Type",      sortable: true},
    {key: "taxon_id",       label: "Taxon ID",        sortable: true,   formatter: YAHOO.widget.DataTable.formatLink5 },
    {key: "scientific_name",    label: "Taxon Name",  sortable: true},
    {key: "exps",        label: "Exps",            sortable: true,  formatter: YAHOO.widget.DataTable.formatLink3 },
    {key: "runs",        label: "Runs",            sortable: true, formatter: YAHOO.widget.DataTable.formatLink4 },
    {key: "update_date",   label: "Update",         sortable: true}
  ];
```
- 検索例: http://test-sra.dbcls.jp/cgi-bin/taxon2study.cgi?taxon_id=8782