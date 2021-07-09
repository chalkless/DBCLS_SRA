#!/usr/bin/perl

# sort2json.pl
# Nakazato T.
# '10-11-11-Thu.    Ver. 0      Original: sort2table.pl
# '14-01-10-Fri.    Ver. 0.1    copy: sort2json.pl


use Getopt::Long;

my ($url) = "";
my ($class) = "";
my ($label) = "";
my ($total_in) = 0;

GetOptions ('url=s'   => \$url,
	    'class=s' => \$class,
	    'label=s' => \$label,
	    'total=s' => \$total_in);


$debug = 1;

my ($file_in) = shift @ARGV;

$file_in =~ /sra.stat.(.*).freq.tab/;
$type = $1;


my ($total) = 0;

open (IN, $file_in) or die $!;
while (defined ($line_in = <IN>)) {
    $line_in =~ s/[\r\n]//g;

    $line_in =~ s/^\s+//;
    $line_in =~ /(\d+)\s(.*)/;
    $count = $1;
    $ele = $2;

    $sum += $count;

    push @data, "{\"".$label."\": \"".$ele."\", \"count\": ".$count."}";
}

if ($total_in) {
    $other = $total_in - $sum;

    $total = $total_in;

    push @data, "{\"".$label."\": \""."others"."\", \"count\": ".$other."}" if $other != 0;
}
else {
    $total = $sum;
}

$total_str = "\"total\": ".$total;

print "{\"data\": [".join(", ", @data)."], ".$total_str."}"."\n";






