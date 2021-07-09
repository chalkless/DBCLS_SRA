#!/usr/bin/perl

# tmpl2html.pl
# Nakazato T.
# '10-11-17-Wed.    Ver. 0


use DBI;
use POSIX 'strftime';

$debug = 1;


### initial condition --- files ###

$file_tmpl = "index.tmpl.html";
$file_type = "sra.stat.type.sort.html";
$file_plat = "sra.stat.plat.sort.html";
$file_taxon = "sra.stat.taxon.sort.html";
$file_plat_exp = "sra.stat.plat.exp.sort.html";
$file_taxon_sample = "sra.stat.taxon.sample.sort.html";

### retrieve date ###

$database = "sra";
$username = "sra";
$password = "shortread";
$socket   = "/var/run/mysql/mysql.sock";

$dsource = "DBI:mysql:$database";
$doption = "mysql_socket=".$socket;

$dbh = DBI->connect($dsource.";".$doption, $username, $password);

$sql_date = "select DATE_FORMAT(UPDATE_DATE,'%Y-%m-%d') from study2 order by UPDATE_DATE desc limit 1";

$sth = $dbh->prepare($sql_date);
$sth->execute;

$num_rows = $sth->rows;

@rslt = $sth->fetchrow_array;
$date = shift @rslt;


### main ###

open (TYPE, $file_type) or die $!;
while (defined ($line_type = <TYPE>)) {
    $line_type =~ s/<table>/<table class="stat">/;
    $line_type =~ s/(<td class="total">\d+)(<\/td>)/$1<br>(studies)$2/;

    $content_type .= $line_type;
}
close (TYPE);

open (PLAT, $file_plat) or die $!;
while (defined ($line_plat = <PLAT>)) {
    $line_plat =~ s/<table>/<table class="stat">/;
    $line_plat =~ s/(<td class="total">\d+)(<\/td>)/$1<br>(studies)$2/;

    $content_plat .= $line_plat;
}
close (PLAT);

open (TAXON, $file_taxon) or die $!;
while (defined ($line_taxon = <TAXON>)) {
    $line_taxon =~ s/<table>/<table class="stat">/;
    $line_taxon =~ s/(<td class="total">\d+)(<\/td>)/$1<br>(studies)$2/;

    $content_taxon .= $line_taxon;
}
close (TYPE);

open (PLATEXP, $file_plat_exp) or die $!;
while (defined ($line_plat_exp = <PLATEXP>)) {
    $line_plat_exp =~ s/<table>/<table class="stat">/;
    $line_plat_exp =~ s/(<td class="total">\d+)(<\/td>)/$1<br>(experiments)$2/;

    $content_plat_exp .= $line_plat_exp;
}
close (PLATEXP);

open (TAXONSMPL, $file_taxon_sample) or die $!;
while (defined ($line_taxon_sample = <TAXONSMPL>)) {
    $line_taxon_sample =~ s/<table>/<table class="stat">/;
    $line_taxon_sample =~ s/(<td class="total">\d+)(<\/td>)/$1<br>(experiments)$2/;

    $content_taxon_sample .= $line_taxon_sample;
}
close (PLATEXP);


open (TMPL, $file_tmpl) or die $!;
while (defined ($line_tmpl = <TMPL>)) {
    $line_tmpl =~ s/%%%DATE%%%/$date/;
    $line_tmpl =~ s/%%%TABLE_TYPE%%%/$content_type/;
    $line_tmpl =~ s/%%%TABLE_PLATFORM%%%/$content_plat/;
    $line_tmpl =~ s/%%%TABLE_TAXONOMY%%%/$content_taxon/;

    $line_tmpl =~ s/%%%TABLE_PLAT_EXP%%%/$content_plat_exp/;
    $line_tmpl =~ s/%%%TABLE_TAXON_SMPL%%%/$content_taxon_sample/;

    print $line_tmpl;
}
close (TMPL);
