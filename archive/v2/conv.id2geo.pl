#!/usr/bin/perl

# conv.id2geo.pl
# Nakazato T.
# '15-08-06-Thu.    Ver. 0

use Getopt::Long;

$debug = 1;

my ($table)   = "";
my ($file_in) = ""; 

GetOptions ('table=s' => \$table,
	    'in=s'    => \$file_in);

open (TABLE, $table) or die $!;
@tables = <TABLE>;
close (TABLE);



open (IN, $file_in) or die $!;
while (defined ($line_in = <IN>)) {
    $line_in =~ s/[\r\n]//;
    $line_in =~ s/^[\s\t]*//;

    @matched = grep {$_ =~ /$line_in\t/} @tables;

#    push @matched join("\t", "-", "-", "-", "-") if length(@matched) == 0;

    print STDERR "!!! multiple hit !!!"."\n" if length(@matched) > 1;
    $line_matched = shift @matched;
    $line_matched =~ s/[\r\n]//;
    print join("\t", $line_in, $line_matched)."\n";

    undef @matched;
}
close (IN);
