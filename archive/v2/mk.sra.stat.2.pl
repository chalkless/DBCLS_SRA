#!/usr/bin/perl

# mk.sra.stat.2.pl
# Nakazato T.
# '10-10-15-Fri.    Ver. 0

use DBI;
use POSIX 'strftime';
# require "./perlPath.pm";

# perlPath::perlPath();

# print STDERR $_."\n" foreach @INC;

$debug = 1;

$database = "sra";
$username = "sra";
$password = "shortread";
$socket   = "/var/run/mysql/mysql.sock";

$dsource = "DBI:mysql:$database";
$doption = "mysql_socket=".$socket;

$dbh = DBI->connect($dsource.";".$doption, $username, $password);

$sql_type = "select RA, RP, STUDY_TYPE from study";
$sql_plat = "select RA, RP, RX, PLATFORM from experiment2";
$sql_taxon = "select RA, RP, RX, RS, scientific_name, TAXON_ID, COMMON_NAME from experiment2 left join taxid on experiment2.TAXON_ID=taxid.taxid";

foreach $ele ("type", "plat", "taxon") {
    $sql_pre = 'sql_'.$ele;
    $sql = ${$sql_pre};
    $sth = $dbh->prepare($sql);
    $sth->execute;

    $num_rows = $sth->rows;

    $date = getDate();
    $file_out = "sra.stat.".$ele.".".$date.".pre.tab";
    $file_out = "sra.stat.".$ele.".pre.tab";

    open (OUT, ">$file_out") or die $!;
    for ($i = 0; $i < $num_rows; $i++) {
	@rslt = $sth->fetchrow_array;
	grep { $_ = '' unless defined($_) } @rslt;
	print OUT join("\t", @rslt)."\n";
    }
    close (OUT);
}

sub getDate {
    my $date = strftime "%y%m%d%H%M", localtime;
}
