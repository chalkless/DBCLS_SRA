#!/usr/bin/perl

#input options
# t: table
# x: taxonnoy file
# r: data root


use Getopt::Std;
use strict;
use DBI;

my $dbh = DBI->connect("DBI:mysql:sra","sra","shortread");

my $sql = "SELECT distinct RA,RP,coalesce(STUDY_TITLE,'<NO DATA>') as STUDY_TITLE,coalesce(STUDY_TYPE,'<NO DATA>') as STUDY_TYPE,UPDATE_DATE,coalesce(TAXON_ID,'<NO DATA>') as TAXON_ID,coalesce(SCIENTIFIC_NAME,'<NO DATA>') as SCIENTIFIC_NAME,coalesce(COMMON_NAME,'<NO DATA>') as COMMON_NAME,coalesce(PLATFORM,'<NO DATA>') as PLATFORM from study2WK A where not exists(select * from study B where A.RP=B.RP and A.RA=B.RA);";
my $sth = $dbh->prepare($sql);
$sth->execute;
my $ref;
my $count = 1;
while($ref=$sth->fetchrow_hashref) {
    my $rss = "";
    $rss =<< "EOF";
<item>
<title>$ref->{"RP"}</title>
<link>http://mars.dbcls.jp/sra/cgi-bin/studylist.cgi?ra=$ref->{"RA"}&amp;rp=$ref->{"RP"}</link>
<description>
Studies    :$ref->{"RP"} : $ref->{"STUDY_TITLE"}<br />
EOF
$rss .=  "Experiments:" . getExperiments($dbh,$ref->{"RA"},$ref->{"RP"})."<br />\n"; 
$rss .=  "Samples    :" . getSamples($dbh,$ref->{"RA"},$ref->{"RP"})."<br />\n"; 
$rss .=  "Runs       :" . getRuns($dbh,$ref->{"RA"},$ref->{"RP"})."<br />\n"; 

    $rss .=<< "EOF";
</description>
<pubDate>$ref->{"UPDATE_DATE"}</pubDate>
</item>
EOF

my $sqlStr = "INSERT INTO RSSWK(RA,RP,STUDY_TITLE,STUDY_TYPE,UPDATE_DATE,TAXON_ID,SCIENTIFIC_NAME,COMMON_NAME,PLATFORM,RSS) VALUES(".
$dbh->quote($ref->{"RA"}).",".
$dbh->quote($ref->{"RP"}).",".
$dbh->quote($ref->{"STUDY_TITLE"}).",".
$dbh->quote($ref->{"STUDY_TYPE"}).",".
$dbh->quote($ref->{"UPDATE_DATE"}).",".
$dbh->quote($ref->{"TAXON_ID"}).",".
$dbh->quote($ref->{"SCIENTIFIC_NAME"}).",".
$dbh->quote($ref->{"COMMON_NAME"}).",".
$dbh->quote($ref->{"PLATFORM"}).",".
$dbh->quote($rss).");";
    print $sqlStr."\n";
    my $sth1 = $dbh->prepare($sqlStr);
    $sth1->execute;
    $sth1->finish;
    $count++;
}
$sth->finish;


$dbh->disconnect;


exit;

sub getExperiments {
    my $dbh = shift;
    my $ra = shift;
    my $rp = shift;
    my $sql = "SELECT * from study_expWK A where A.RP='$rp' and A.RA='$ra';";
    my $sth = $dbh->prepare($sql);
    $sth->execute;
    my $ref;
    my @a;
    my $ret = "";
    while($ref=$sth->fetchrow_hashref) {
	push @a,$ref->{"RX"};
    }
    $ret = join(":",@a);
    $sth->finish;

    return $ret;

}

sub getSamples {
    my $dbh = shift;
    my $ra = shift;
    my $rp = shift;
    my $sql = "SELECT * from study_sampleWK A where A.RP='$rp' and A.RA='$ra';";
    my $sth = $dbh->prepare($sql);
    $sth->execute;
    my $ref;
    my @a;
    my $ret = "";
    while($ref=$sth->fetchrow_hashref) {
	push @a,$ref->{"RS"};
    }
    $ret = join(":",@a);
    $sth->finish;

    return $ret;

}

sub getRuns {
    my $dbh = shift;
    my $ra = shift;
    my $rp = shift;
    my $sql = "SELECT * from study_expWK A inner join exp_runWK B on (A.RX=B.RX and A.RA=B.RA)  where A.RP='$rp' and A.RA='$ra';";
    my $sth = $dbh->prepare($sql);
    $sth->execute;
    my $ref;
    my @a;
    my $ret = "";
    while($ref=$sth->fetchrow_hashref) {
	push @a,$ref->{"RR"};
    }
    $ret = join(":",@a);
    $sth->finish;

    return $ret;

}
