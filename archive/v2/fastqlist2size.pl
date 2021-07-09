#!/usr/bin/perl

# fastqlist2size.pl
# Nakazato T.
# '13-03-01-Fri.    Ver. 0


use Math::Round;

$debug = 1;

my ($file_in) = shift @ARGV;
open (IN, $file_in) or die $!;
while (defined ($line_in = <IN>)) {
    $line_in =~ s/[\r\n]//g;

    next if $line_in =~ /^file_path/;
    my ($file, $check, $size, $time) = split(/\t/, $line_in);

    $file =~ /\/ddbj_database\/dra\/fastq\/[SED]RA\d{3}\/([SED]RA\d{6})\/([SED]RX\d{6})/;
    $id_submission = $1;
    $id_exp = $2;

    $exp2size{$id_submission."\t".$id_exp} += $size;
}
close (IN);

foreach $each_expset (sort (keys %exp2size)) {
    $size_tmp = $exp2size{$each_expset};
    $size_out = nearest(10**6, $size_tmp)/10**6;
    print join("\t", $size_out, $each_expset)."\n";
}

