#!/usr/bin/perl


use strict;
use DBI;

package sizeParser;

sub new {
    my $pkg = shift;
    bless {
	dbh => shift,
    },$pkg;

}

sub parse {
    my $self = shift;
    my $file = shift;

    print "SIZE PARSER:FILE=".$file."\n";

    open(FILENAME,$file) or die;
    while(<FILENAME>) {
	chomp;
#	my ($size,$dir) = split(/\s+/,$_);
	my ($size, $id_submission, $id_exp) = split(/\t/, $_);
	$self->insert($id_submission, $id_exp, $size);

#	if($dir =~ /^\.\/dra\/\w\w\w\d\d\d\/(\w\w\w\d\d\d\d\d\d)\/([^\/]+)$/) {
#	    print $size.":".$1.":".$2."\n";
#	    $self->insert($1,$2,$size);
#	}
    }
    close(FILE);
    return 1;
}

sub insert() {
    my $self = shift;
    my $dbh = $self->{dbh};
    my $ra = $dbh->quote(shift);
    my $rx = $dbh->quote(shift);
    my $size = $dbh->quote(shift);

    my $query = "INSERT INTO sizeWK(RA,RX,SIZE) values(".$ra.",".$rx.",".$size.");";
    print $query ."\n";
    my $sth = $dbh->prepare($query);

    $sth->execute;

    $sth->finish;

} 

1;
