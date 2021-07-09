#!/usr/bin/perl

# mk.sra.stat.taxon.comp.pl
# Nakazato T.
# '10-11-11-Thu.    Ver. 0
# '11-08-19-Fri.    Ver. 0.1    # Error treatment for Illegal TaxonID
# '13-01-23-Wed.    Ver. 0.2    # Error treatment for empty TaxonID

use Bio::DB::Taxonomy;
use Data::Dumper;
# require "./perlPath.pm";

# perlPath::perlPath();

$file_taxon = "taxon.id2name.tab";

$debug = 1;

open (TAXON, $file_taxon) or die $!;
while (defined ($line_taxon = <TAXON>)) {
    $line_taxon =~ s/[\r\n]//g;

    my ($taxonid, $name) = split(/\t/, $line_taxon);
    $taxonid2name{$taxonid} = $name;
}
close (TAXON);


my ($opt_tmp) = shift @ARGV;
if ($opt_tmp eq "-d") {
    $debug = 2;
    $file_in = shift @ARGV;
}
else {
    $file_in = $opt_tmp;
}

open (TAXONOUT, ">>$file_taxon") or die;
open (IN, $file_in) or die $!;
while (defined ($line_in = <IN>)) {
    $line_in =~ s/[\r\n]//g;

    ($sraid, $srpid, $srxid, $srsid, $name_sci, $taxonid, $name_com) = split(/\t/, $line_in);

    if (($name_sci eq "") and ($taxonid > 0)) {
	print STDERR $line_in."\n" if $debug == 2;

	$name_sci = $taxonid2name{$taxonid};
    }

    if ($name_sci eq "") {
	if ($taxonid eq "") {
	    $name_sci = "";
	}
	else {
	    print STDERR $taxonid."\n";
	    $names_ref_hash = Bio::DB::Taxonomy->new(-source => 'entrez')->get_taxon(-taxonid => $taxonid);
	    if ($names_ref_hash ne "") {
		$names_ref = $names_ref_hash->{"_names_hash"}->{"scientific"};
		$name_sci = shift @$names_ref;
	    }
	    else {
		$name_sci = "";
	    }
	}
    }

    if ($name_sci eq "") {
	$name_sci = $name_com;
    }

    if ($name_sci eq "") {
	$name_sci = "[TaxonID] ".$taxonid;
    }

    if ($name_sci eq "") {
	$name_sci = "No data";
    }

    if ($taxonid) {
	print TAXONOUT join("\t", $taxonid, $name_sci)."\n" if $taxonid2name{$taxonid} eq "";
	$taxonid2name{$taxonid} = $name_sci;
    }

    $srsid = "-" if $srsid eq "";

    print join("\t", $sraid, $srpid, $name_sci, $srxid, $srsid)."\n";
}
close (IN);
close (TAXONOUT);
