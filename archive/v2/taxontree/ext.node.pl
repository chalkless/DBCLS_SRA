#!/opt/local/bin/perl

# ext.node.pl
# Nakazato T.
# '12-06-13-Wed.    Ver. 0

$debug = 1;

$filename_node = "nodes.dmp";
$filename_name = "names.dmp";
$filename_cat  = "categories.dmp";

embl_code2group();

#$file_node = shift @ARGV;
$dir = shift @ARGV;

extName($dir.$filename_name);
extCat($dir.$filename_cat);

$file_node = $dir.$filename_node;
open (NODE, $file_node) or die $!;
while (defined ($line_node = <NODE>)) {
    $line_node =~ s/[\r\n]//g;
    my @ele = split(/\s*\|\s*/, $line_node);
    print join("", @ele)."\n" if $debug == 2;

    $tax_id = $ele[0];
    $parent_id = $ele[1];
    $species_id = $taxid_2species{$tax_id};

    $name = $taxid2name{$tax_id};
    $name_parent = $taxid2name{$parent_id};
    $name_species = $taxid2name{$species_id};

    $rank = $ele[2];
    $embl_code = $ele[4];
    $group = $code2group{$embl_code};

    print join("\t", $tax_id, $parent_id, $species_id, $name, $name_parent, $name_species, $rank, $group)."\n";
}
close (NODE);


sub embl_code2group {
    $code2group{"0"} = "Bacteria";
    $code2group{"1"} = "Invertebrates";
    $code2group{"2"} = "Mammals";
    $code2group{"3"} = "Phages";
    $code2group{"4"} = "Plants";
    $code2group{"5"} = "Primates";
    $code2group{"6"} = "Rodents";
    $code2group{"7"} = "Synthetic";
    $code2group{"8"} = "Unassigned";
    $code2group{"9"} = "Viruses";
    $code2group{"10"} = "Vertebrates";
    $code2group{"11"} = "Environmental";
}

sub extName {
    my ($file_name) = @_;

    open (NAME, $file_name) or die $!;
    while (defined ($line_name = <NAME>)) {
	$line_name =~ s/[\r\n]//g;

	my @ele = split(/\s*\|\s*/, $line_name);
	$tax_id = $ele[0];
	$name = $ele[1];
	$class= $ele[3];

	print join("\t", $tax_id, $name, $class)."\n" if $debug == 2;

	$taxid2name{$tax_id} = $name if $class eq "scientific name";
    }
    close (NAME);
}


sub extCat {
    my ($file_cat) = @_;

    open (CAT, $file_cat) or die $!;
    while (defined ($line_cat = <CAT>)) {
	$line_cat =~ s/[\r\n]//g;

	my (undef, $tax_id_species, $tax_id_self) = split(/\t/, $line_cat);

	$taxid_2species{$tax_id_self} = $tax_id_species;
    }
    close (CAT);
}
