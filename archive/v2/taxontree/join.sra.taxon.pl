#!/opt/local/bin/perl

# join.sra.taxon.pl
# Nakazato T.
# '12-06-14-Thu.    Ver. 0


$debug = 1;

my ($file_tree, $file_freq) = @ARGV;

open (TREE, $file_tree) or die $!;
while (defined ($line_tree = <TREE>)) {
    $line_tree =~ s/[\r\n]//g;

    $line_tree =~ /^(\d+)/;
    my ($taxon_id) = $1;

    $id2annot{$taxon_id} = $line_tree;
}
close (TREE);

open (FREQ, $file_freq) or die $!;
while (defined ($line_freq = <FREQ>)) {
    $line_freq =~ s/[\r\n]//g;

    my ($taxon_id, $name, $freq) = split(/\t/, $line_freq);

    $annot = $id2annot{$taxon_id};

    $annot = join("\t", $taxon_id, "-", "-", "-", "-") if $annot eq "";

    print $freq."\t", $annot."\n";
}
close (FREQ);
