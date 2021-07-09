#!/usr/bin/perl

# mk.sra2geo.pl
# Nakazato T.
# '15-08-05-Wed.    Ver. 0

$debug = 1;

my $dir = shift @ARGV;

procdir($dir);

sub procdir {
    my ($dir) = @_;

    chdir($dir);
    my @files = reverse(sort (glob("*")));

    foreach $file (@files) {
        if (-d $file) {
            procdir($file);
            chdir ("..") or die $!;
        }
        elsif (-f $file) {
	    if ($file =~ /study.xml$/) {

		open (IN, $file) or die $!;
		while (defined ($line_in = <IN>)) {
		    $line_in =~ s/[\r\n]//g;

		    if ($line_in =~ /<STUDY .* accession="(.RP\d{6})"/) {
			$id_srp = $1;
		    }
		    elsif ($line_in =~ /<EXTERNAL_ID namespace="BioProject">(.*)<\/EXTERNAL_ID>/) {
			$id_biopj = $1;
		    }
		    elsif ($line_in =~ /<EXTERNAL_ID namespace="GEO">(.*)<\/EXTERNAL_ID>/) {
			$id_geo = $1;
		    }
		    elsif ($line_in =~ /<URL>http:\/\/www.ebi.ac.uk\/arrayexpress\/experiments\/(.*)<\/URL>/) {
			$id_ae = $1;
		    }
		}
		close(IN);

		$id_srp = "-" if $id_srp eq "";
		$id_biopj = "-" if $id_biopj eq "";
		$id_geo = "-" if $id_geo eq "";
		$id_ae  = "-" if $id_ae  eq "";

		print join("\t", $id_srp, $id_biopj, $id_geo, $id_ae)."\n"  if (
($id_srp ne "-") or ($id_biopj ne "-") or ($id_geo ne "-") or ($id_ae ne "-"));

		$id_srp = "";
		$id_biopj = "";
		$id_geo = "";
		$id_ae  = "";
	    }
	}
    }
}




