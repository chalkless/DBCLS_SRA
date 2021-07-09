#!/usr/bin/perl

# sort2table.pl
# Nakazato T.
# '10-11-11-Thu.    Ver. 0

use Getopt::Long;

my ($url) = "";
my ($calss) = "";
my ($total_in) = 0;

GetOptions ('url=s'   => \$url,
	    'class=s' => \$class,
	    'total=s' => \$total_in);


$debug = 1;

my ($file_in) = shift @ARGV;

$file_in =~ /sra.stat.(.*).freq.tab/;
$type = $1;

printHeader();

my ($total) = 0;

open (IN, $file_in) or die $!;
while (defined ($line_in = <IN>)) {
    $line_in =~ s/[\r\n]//g;

    $line_in =~ s/^\s+//;
    $line_in =~ /(\d+)\s(.*)/;
    $count = $1;
    $ele = $2;

    $total += $count;

    if ($url) {
	$link_pre = "<a href=\"".$url.$ele."\">";
	$link_post = "</a>";
    }

    print <<TABLE;
 <tr>
  <td>$link_pre$ele$link_post</td>
  <td>$count</td>
 </tr>
TABLE
}
close (IN);

$total = $total_in if ($total_in);
printTotal($total);

printFooter();


sub printHeader {
    print "<table>"."\n";
}

sub printTotal {
    my ($total) = @_;

    print <<TOTAL
 <tr>
  <td class="total" style="text-align: center;">Total</td>
  <td class="total">$total</td>
 </tr>
TOTAL
}

sub printFooter {
    print "</table>"."\n";
}
