#!/usr/bin/perl

#input options
# file: file_id_table
# t: table
# x: taxonnoy file
# r: data root
# m: metadata root (fastqlist)


# use Getopt::Std;
use Getopt::Long;
# use strict;
use DBI;
use relationParser;
use sampleParser;
use studyParser;
use experimentParser;
use submissionParser;
use sizeParser;

my $socket = "/var/run/mysql/mysql.sock";

my $dbh = DBI->connect("DBI:mysql:sra;mysql_socket=$socket","sra","shortread");
my %opts = {};
my $tbl;
my $tbl_path;

GetOptions(
    "file=s" => \$tbl,
    "r" => \$root,
    "m" => \$root_meta
    );

my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime(time);
my $date = sprintf("%02d%02d%02d%02d%02d", $year-100, $mon+1, $mday, $hour, $min);

if ($tbl) {

}
else {
    my $tbl_path = "./update/".$date;
    my $tbl = $tbl_path."/sra.idTable.".$date.".tab";
    mkdir ($tbl_path, 0775);
}

# my $tbl = "./tbl/" . time;

#getopts("t:x:r:m:",\%opts);

system("mysql -u sra -pshortread -b sra < ./sql/phase1.sql");


if ($root) {

}
else {
#    $root = "/opt/data/sra/";
    $root = "/share/data/sra/";
}

if ($root_meta) {

}
else {
    $root_meta = "/share/data/sra_meta/";
}

if (-e $tbl) {

}
else {
    system("./mk.idTable.sra.3.pl $root > $tbl");
}

my $obj = relationParser->new($dbh);

$obj->parse($tbl);
#if ($tbl) {
#    $obj->parse($opts{"t"});
#} else {
#    $obj->parse($tbl);
#}

system("mysql -u sra -pshortread -b sra < ./sql/phase2.sql");

my $obj = sampleParser->new($dbh);
$obj->parse($root);

my $obj = submissionParser->new($dbh);
$obj->parse($root);

my $obj = experimentParser->new($dbh);
$obj->parse($root);

my $obj = studyParser->new($dbh);
$obj->parse($root);

system("./fastqlist2size.pl $root_meta/fastqlist > $tbl_path/exp2size.$date.tab");

my $obj = sizeParser->new($dbh);
#$obj->parse("./du-m");
$obj->parse("./$tbl_path/exp2size.$date.tab");

system("mysql -u sra -pshortread -b sra < ./sql/phase3.sql");

$dbh->disconnect;


