#!/opt/local/bin/perl

# mk.tree.pl
# Nakazato T.
# '12-06-14-Thu.    Ver. 0

$debug = 1;

$file_in = shift @ARGV;
open (IN, $file_in) or die $!;
while (defined ($line_in = <IN>)) {
    $line_in =~ s/[\r\n]//g;

    my ($taxon_id, $parent_id, $species_id, $name, $name_parent, $name_species, $rank, $group) = split(/\t/, $line_in);

    $child2parent{$taxon_id} = $parent_id;
    $self2species{$taxon_id} = $species_id;
    $id2annot{$taxon_id} = join("\t", $name, $rank, $group);
}
close (IN);

foreach $each_taxonid (sort {$a <=> $b} (keys (%child2parent))) {
    $each_parent = $child2parent{$each_taxonid};
    $each_annot = $id2annot{$each_taxonid};
    $each_species = $self2species{$each_taxonid};

    if ($each_parent eq "1") {
	$tree = "1";
    }
    else {	
	$tree = join(":",
		     sprintf("%07d", $each_parent),
		     sprintf("%07d", $each_taxonid));
    }

    # make full tree
    while ($each_parent ne "1") {
	$taxonid_nest = $each_parent;
	$each_parent = $child2parent{$taxonid_nest};

	$tree = join(":", sprintf("%07d", $each_parent), $tree);
    }

    print join("\t", $each_taxonid, $tree, $each_species, $each_annot)."\n";
}
