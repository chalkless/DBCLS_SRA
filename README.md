=======
DBCLS_SRA
=========

DBCLS Seq Read Archive


いつまでもこのページがあるかというとそうでもないかもしれないし、
この文が消えるのかもしれない、という

### mkdat.sh
* 検索用データ作るのにこれが動く
  * DDBJだのからSRAデータをミラーしてくる
  * DDBJだのNCBIだのからBioProjectデータをミラーしてくる
  *  EBIは? BioSampleは?


### mk.idTable.sra.3.pl
* 各メタデータファイルの関係性を抽出する
* 自分自身のID抽出
  * Study: <STUDY .\*accession="(\.RP\\d{6})"
  * Experiment: <EXPERIMENT .\*accession="(\.RX\\d{6})"
  * Sample: <SAMPLE .\*accession="(\.RS\\d{6})"
  * Run: <RUN .\*accession="(\.RR\\d{6})"/
  * Analysis: <ANALYSIS .\*accession="(\.RZ\\d{6})"



* リンク
  * <EXPERIMENT_REF .*accession="(.RX\d{6})"
  * <TARGET .*accession="(.RX\d{6})"

  * <SAMPLE_DESCRIPTOR .*accession="(.RS\d{6})"
  * <STUDY_REF .*accession="(.RP\d{6})"





