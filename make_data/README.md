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
...
$ mysqlimport -u sra -p --local --delete sra exp_runWK.tab
```



