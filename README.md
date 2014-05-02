=======
DBCLS_SRA
=========

DBCLS Seq Read Archive


いつまでもこのページがあるかというとそうでもないかもしれないし、
この文が消えるのかもしれない、という

### mk.idTable.sra.3.pl
* 各メタデータファイルの関係性を抽出する
* 内容
 * 自分自身のID抽出
  * Study
   * <STUDY .\*accession="(\.RP\\d{6})"
  * Experiment
   * <EXPERIMENT .\*accession="(\.RX\\d{6})"
  * Sample
   * <SAMPLE .\*accession="(\.RS\\d{6})"
  * Run
   * <RUN .\*accession="(\.RR\\d{6})"/
  * Analysis
   * <ANALYSIS .\*accession="(\.RZ\\d{6})"
