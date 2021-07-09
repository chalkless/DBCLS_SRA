#!/usr/bin/perl

# mk.study2wtaxon.pl
# Nakazato T.
# '15-03-20-Fri.    Ver. 0.1

use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);

$debug = 1;

my %opts = ( taxon=>"taxonomy.tree.tab", study=>"study2.tab" );
Getopt::Long::GetOptions(\%opts, qw( taxon=s study=s ));

$file_taxon = $opts{"taxon"};
$file_study = $opts{"study"};

open (TAXON, $file_taxon) or die $!;
while (defined ($line_taxon = <TAXON>)) {
    $line_taxon =~ s/[\r\n]//g;

    @ele_taxon = split(/\t/, $line_taxon);

    $taxon_id = $ele_taxon[0];
    $tree_id  = $ele_taxon[1];

    $taxonid2tree{$taxon_id} = $tree_id;
}
close (TAXON);

open (STUDY, $file_study) or die $!;
while (defined ($line_study = <STUDY>)) {
    $line_study =~ s/[\r\n]//g;

    @ele_study = split(/\t/, $line_study);

    $taxon_id_out = $ele_study[6];
    $tree_id_out  = $taxonid2tree{$taxon_id_out};

    splice(@ele_study, 7, 0, $tree_id_out);

    print join("\t", @ele_study)."\n";
}
close (STUDY);


