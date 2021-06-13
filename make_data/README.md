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