#!/usr/bin/perl

# taxonDecoration.pl
# Nakazato T.
# '10-11-24-Wed.    Ver. 0


$debug = 1;

my ($file_in) = shift @ARGV;

open (IN, $file_in) or die $!;
while (defined ($line_in = <IN>)) {
    $line_in =~ s/[\r\n]//g;

    if ($line_in =~ /scientific_name/) {
	$line_in =~ /(.*<a href=".*?">)(.*)(<\/a>.*)/;
	$pre   = $1;
	$taxon = $2;
	$post  = $3;
	print $taxon."\n" if $debug == 2;

	$line_in = $pre."<span class=\"taxon\">".$taxon."</span>".$post if $taxon =~ /^[A-Z]/;
    }

    print $line_in."\n";
}
close (IN);


